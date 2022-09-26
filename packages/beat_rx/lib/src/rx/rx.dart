import 'dart:async';
import 'dart:collection';

import 'package:async/async.dart';
import 'package:flutter/widgets.dart';

part 'async.dart';
part 'family.dart';
part 'future.dart';
part 'number.dart';
part 'observer.dart';
part 'string.dart';

class _RxSubscription extends ChangeNotifier {
  final HashSet<Rx> observables = HashSet();

  /// Subscribe to the observable
  void subscribe(Rx obs) {
    if (observables.contains(obs)) {
      return;
    }
    observables.add(obs);
    obs.addListener(notifyListeners);
  }

  /// Unsubscribe all observables
  void unsubscribeAll() {
    for (final obs in observables) {
      obs.removeListener(notifyListeners);
    }
    observables.clear();
  }
}

/// Reactive data class
class Rx<T> extends ChangeNotifier {
  Rx(
    this.compute, {
    this.listenOnUnchanged = false,
    this.autoDispose = false,
    this.onDispose,
  });

  /// Current observer ([ReactiveBuilder]) scope
  static _RxSubscription? _observer;

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
    final prevAccessor = _rxAccessingNow;
    if (prevAccessor != null) {
      _children.add(prevAccessor);
      prevAccessor._parents.add(this);
    }
    _rxAccessingNow = this;
    final nextCandidate = compute();
    _rxAccessingNow = prevAccessor;

    /// Release all of the previous dependencies
    if (!_initialized || _dirty) {
      _value = nextCandidate;
      _initialized = true;
      _dirty = false;
    }

    _observer?.subscribe(this);
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
    return _observer != null &&
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
    for (final parent in _parents) {
      parent._children.remove(this);
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
        /// There is no way to check if the widget is unmounted.
        /// This is a tricky way to resolve the problems in debug mode.
        elm.widget;
        elm.markNeedsBuild();

        /// In the profile and release mode,
        /// when the widget is defunct, the [Element.dirty] field is not set.
        if (!elm.dirty) {
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
    _elements.add(elm);
  }

  void _removeFlutterElement(Element elm) {
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

extension BindElement<T extends Rx> on T {
  /// Manually bind the widget with Rx
  T bind(BuildContext context) {
    if (context is ReactiveStateMixin) {
      final reactiveElement = context;
      reactiveElement.addObservable(this);
    }
    _addFlutterElement(context as Element);
    return this;
  }

  /// Manually unbind the widget with Rx
  void unbind(BuildContext context) {
    if (context is ReactiveStateMixin) {
      final reactiveElement = context;
      reactiveElement.removeObservable(this);
    }
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
