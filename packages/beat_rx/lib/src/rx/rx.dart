import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/widgets.dart';

part 'future.dart';
part 'number.dart';
part 'observer.dart';
part 'string.dart';

class _BeatxSubscription extends ChangeNotifier {
  final List<BeatxRx> _observables = [];

  /// Subscribe to the observable
  void subscribe(BeatxRx obs) {
    _observables.add(obs);
    obs.addListener(notifyListeners);
  }

  /// Unsubscribe all observables
  void unsubscribeAll() {
    for (final obs in _observables) {
      if (obs is DisposableRx && !obs.hasListeners) {
        /// Drop and initilize Rx,
        /// when there is no widget listening to it anymore.
        obs.drop();
      }
      obs.removeListener(notifyListeners);
    }
  }
}

typedef Rx<T> = BeatxRx<T>;

/// Reactive data class
class BeatxRx<T> extends ChangeNotifier {
  BeatxRx(this._value, {this.listenOnUnchanged = false});
  static _BeatxSubscription? _observer;
  final bool listenOnUnchanged;

  late T _value;

  /// Get value and subscribe to the observable
  T get value {
    _observer?.subscribe(this);

    return _value!;
  }

  /// Set value and notify listeners
  set value(T newVal) {
    final previous = _value;
    _value = newVal;
    if (previous != _value || listenOnUnchanged) {
      notifyListeners();
    }
  }

  /// When you make a change to the custom class, you can call this method
  /// to rebuild the widgets.
  void rebuild() {
    notifyListeners();
  }

  @override
  String toString() {
    return value.toString();
  }
}

/// Automatically dispose any of the Rx states when the last widget
/// is disposed.
class DisposableRx<T> extends BeatxRx<T?> {
  DisposableRx(
    this.initialize, {
    this.onDispose,
    super.listenOnUnchanged,
  }) : super(null);
  bool initialized = false;

  @override
  T get value {
    if (!initialized) {
      _value = initialize();
      initialized = true;
    }
    return super.value as T;
  }

  final T Function() initialize;

  final void Function(T lastValue)? onDispose;

  /// Dispose
  void drop() {
    if (_value != null) {
      onDispose?.call(_value as T);
    }
    _value = null;
    initialized = false;
  }
}

/// A widget that rebuilds when the collection of [BeatxRx]s changes.
/// ComputedRx does not hold any object, so it does not need to be disposed.
class ComputedRx<T> extends BeatxRx<T?> {
  ComputedRx(
    this.compute, {
    super.listenOnUnchanged = false,
  }) : super(null);

  /// A function that compute the wanted value
  final T Function() compute;

  @override
  T get _value => compute();

  @override
  T get value {
    BeatxRx._observer?.subscribe(this);
    return _value;
  }

  /// ComputedRx can't assign new value.
  @override
  set value(T? newVal) {}
}

extension TransformToBeatxObservable<T> on T {
  /// Get a Rx
  BeatxRx<T> get rx => BeatxRx(this);

  /// Get a Rx, notify even when the value is not changed
  BeatxRx<T> get rxAlways => BeatxRx(this, listenOnUnchanged: true);

  /// Get a Rx, dispose when there is no widget listening to it
  DisposableRx<T> rxAutoDispose(
    void Function(T lastValue)? onDispose, {
    bool listenOnUnchanged = false,
  }) =>
      DisposableRx(
        () => this,
        onDispose: onDispose,
        listenOnUnchanged: listenOnUnchanged,
      );
}

extension TransformToComputedObservable<T> on T Function() {
  /// Get a Rx
  ComputedRx<T> get rx => ComputedRx(this);

  /// Get a Rx, notify even when the value is not changed
  ComputedRx<T> get rxAlways => ComputedRx(this, listenOnUnchanged: true);
}
