import 'dart:async';
import 'dart:collection';

import 'package:async/async.dart';
import 'package:flutter/widgets.dart';

part 'async.dart';
part 'family.dart';
part 'future.dart';
// part 'inject.dart';
part 'number.dart';
part 'observer.dart';
part 'string.dart';

/// Reactive data class
class Rx<T> extends ChangeNotifier {
  Rx(
    this.compute, {
    this.listenOnUnchanged = false,
    this.autoDispose = false,
    this.onDispose,
  });

  /// Current observer ([ReactiveBuilder]) scope
  static ReactiveStateMixin? _observer;
  static ReactiveStateMixin? _unmounter;

  /// The current [Rx] accessing this [Rx]
  static Rx? _rxAccessingNow;

  /// Notify even when the value is not changed
  final bool listenOnUnchanged;

  /// Dispose the Rx when there is no widget listening to it
  final bool autoDispose;

  /// A function that compute the initial value or a computed value from other Rx
  final T Function() compute;

  /// Called on a dispose
  final void Function(T lastValue)? onDispose;

  /// Observables dependending on this Rx
  final HashSet<Rx> _children = HashSet();

  /// Observables this Rx is depending on
  final HashSet<Rx> _parents = HashSet();

  bool _initialized = false;

  bool _dirty = false;

  /// Internal value
  late T? _value;

  /// Get value and subscribe to the observable
  T get value {
    if (_rxAccessingNow != null) {
      _children.add(_rxAccessingNow!);
      _rxAccessingNow!._parents.add(this);
    }

    if (!_initialized || _dirty) {
      final prevAccessor = _rxAccessingNow;
      // performance optimization
      if (!_initialized) {
        _rxAccessingNow = this;
      } else {
        _rxAccessingNow = null;
      }
      _value = compute();
      _rxAccessingNow = prevAccessor;
      _dirty = false;
      _initialized = true;
    }

    if (_observer != null) {
      bind(_observer!);
    }
    return _value as T;
  }

  /// Set value and notify listeners
  set value(T newVal) {
    /// Mark next rebuild as a self change
    final previous = _value;
    _value = newVal;
    if (previous != _value || listenOnUnchanged) {
      notifyListeners();
    }
  }

  bool _canDrop() {
    return _initialized &&
        _observer == null &&
        autoDispose &&
        !hasListeners &&
        _children.isEmpty &&
        _elements.isEmpty;
  }

  /// Dispose
  void drop() {
    onDispose?.call(_value as T);
    _value = null;
    _initialized = false;
    _dirty = false;
    for (final parent in _parents) {
      parent._children.remove(this);
      if (parent._canDrop()) {
        parent.drop();
      }
    }
    _parents.clear();
    _children.clear();
    _elements.clear();
  }

  /// When you make a change to the custom class, you can call this method
  /// to rebuild the widgets.
  void rebuild() {
    notifyListeners();
  }

  @override
  void notifyListeners() {
    final defunctElms = <Element>[];
    for (final elm in _elements) {
      try {
        /// If the user [Rx.bind()] with non-ReactiveStateMixin widget,
        /// then there is no way to check if the widget is unmounted.
        ///
        /// In a debug mode, this will throw an exception using [assert]
        elm.markNeedsBuild();

        /// But in the release mode, [assert] will not work.
        /// This is a tricky way to resolve the problems in release mode.
        /// When the widget is unmounted, [Element._widget] is null,
        /// and [elm.widget] will throw an exception because its getter is not null-safe.
        // ignore: unnecessary_null_comparison
        if (elm.widget == null) {
          defunctElms.add(elm);
        }
      } catch (e) {
        defunctElms.add(elm);
      }
    }

    for (final defunct in defunctElms) {
      _removeFlutterElement(defunct);
    }

    for (final child in _children) {
      if (child._dirty) continue;
      child._dirty = true;
      child.notifyListeners();
    }
    super.notifyListeners();
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    if (_canDrop()) {
      drop();
    }
  }

  void reset() {
    _value = compute();
    rebuild();
  }

  final _elements = HashSet<Element>();

  void _addFlutterElement(Element elm) {
    if (_elements.contains(elm)) {
      return;
    }
    if (elm is ReactiveStateMixin) {
      elm.addObservable(this);
    } else {
      _checkAndRemoveDefunctElm(elm);
    }
    _elements.add(elm);
  }

  void _checkAndRemoveDefunctElm(Element elm) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      try {
        // ignore: unnecessary_null_comparison
        if (elm.widget == null) {
          return _removeFlutterElement(elm);
        }
        _checkAndRemoveDefunctElm(elm);
      } catch (e) {
        _removeFlutterElement(elm);
      }
    });
  }

  void _removeFlutterElement(Element elm) {
    if (_unmounter == null && elm is ReactiveStateMixin) {
      elm._observables.remove(this);
    }
    _elements.remove(elm);
    if (_canDrop()) {
      drop();
    }
  }

  @override
  String toString() {
    return value.toString();
  }
}

extension BindRxes on BuildContext {
  /// Bind multiple Rxes
  void bind(List<Rx> rxes) {
    for (final rx in rxes) {
      rx.bind(this);
    }
  }
}

extension BindElement<T extends Rx> on T {
  /// Manually bind the widget with Rx
  T bind(BuildContext context) {
    _addFlutterElement(context as Element);
    return this;
  }

  /// Manually unbind the widget with Rx
  void unbind(BuildContext context) {
    _removeFlutterElement(context as Element);
  }
}

extension TransformToRx<T> on T {
  /// Get a Rx
  Rx<T> rx({
    bool listenOnUnchanged = false,
    bool autoDispose = false,
    void Function(T lastValue)? onDispose,
  }) =>
      Rx(
        () => this,
        autoDispose: autoDispose,
        onDispose: onDispose,
        listenOnUnchanged: listenOnUnchanged,
      );
}

extension TransformToComputedRx<T> on T Function() {
  /// Get a Rx
  Rx<T> rx({
    bool listenOnUnchanged = false,
    bool autoDispose = false,
    void Function(T lastValue)? onDispose,
  }) =>
      Rx(
        this,
        autoDispose: autoDispose,
        onDispose: onDispose,
        listenOnUnchanged: listenOnUnchanged,
      );
}
