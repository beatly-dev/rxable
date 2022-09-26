import 'dart:async';
import 'dart:collection';
import 'dart:developer';

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

  /// The current notifier ([Rx])
  static Rx? _notifier;

  /// The direct parent of the current notifier ([Rx])
  static Rx? _dependant;

  /// [Rx]s that current [Rx] depends on
  final _dependancies = HashSet<Rx>();

  /// The latest value of the dependant [Rx]
  /// to check if the value is changed
  final _dependantValues = <Rx, dynamic>{};

  /// Notify even when the value is not changed
  final bool listenOnUnchanged;

  /// Dispose the Rx when there is no widget listening to it
  final bool autoDispose;

  /// A function that compute the initial value or a computed value from other Rx
  final T Function() compute;

  /// Called on a dispose
  final void Function(T lastValue)? onDispose;

  /// Observables dependending on this Rx
  late final HashSet<Rx> _children = HashSet();

  bool _initialized = false;

  /// Internal value
  late T? _value;

  /// If this [Rx] depends on the current [_notifier]
  /// and the value was changed.
  bool _needUpdate() {
    return (_dependancies.contains(_notifier) &&
            _dependantValues[_notifier] != _notifier?._value) ||
        _dependancies.fold(
          false,
          (isDependent, rx) => isDependent || rx._needUpdate(),
        );
  }

  /// Get value and subscribe to the observable
  T get value {
    final needUpdate = _needUpdate();

    /// Clear the previous dependencies
    _dependancies.clear();
    final prevDep = _dependant;
    _dependant = this;
    final nextCandidate = compute();
    _dependant = prevDep;
    _dependant?._dependancies.add(this);

    /// Release all of the previous dependencies
    if (!_initialized || needUpdate) {
      _value = nextCandidate;
      _initialized = true;
      if (_notifier != null) {
        _dependantValues[_notifier!] = _notifier?._value;
      }
    }

    _observer?.subscribe(this);
    return _value as T;
  }

  /// Set value and notify listeners
  set value(T newVal) {
    /// Mark next rebuild as a self change
    _notifier = this;
    final previous = _value;
    _value = newVal;
    if (previous != _value || listenOnUnchanged) {
      notifyListeners();
    }
  }

  bool _canDrop() {
    return autoDispose &&
        !hasListeners &&
        _children.isEmpty &&
        _elements.isEmpty;
  }

  /// Dispose
  void drop() {
    onDispose?.call(_value as T);
    _value = null;
    _initialized = false;
    _children.clear();
    _elements.clear();
  }

  /// When you make a change to the custom class, you can call this method
  /// to rebuild the widgets.
  void rebuild() {
    _notifier = this;
    notifyListeners();
  }

  @override
  void notifyListeners() {
    for (final elm in _elements) {
      elm.markNeedsBuild();
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
    value = compute();
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
    if (context is! ReactiveStateMixin) {
      log('''
[WARNING] You are trying to bind a Rx to a non-Reactive widget.
Until you explicitly call [unbind(context)], auto-dispose will not work for this Rx.
''');
    } else {
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
      reactiveElement.addObservable(this);
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
