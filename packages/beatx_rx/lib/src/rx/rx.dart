import 'dart:async';

import 'package:flutter/widgets.dart';

part 'observer.dart';
part 'types/future.dart';
part 'types/number.dart';
part 'types/string.dart';

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

  T _value;

  T get value {
    _observer?.subscribe(this);

    return _value!;
  }

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

/// A widget that rebuilds when the collection of [BeatxRx]s changes.
class ComputedRx<T> extends BeatxRx<T> {
  ComputedRx(
    this.compute, {
    super.listenOnUnchanged = false,
  }) : super(compute());

  /// A function that compute the wanted value
  final T Function() compute;

  @override
  T get _value => compute();

  @override
  set value(T newVal) {}
}

extension TransformToBeatxObservable<T> on T {
  BeatxRx<T> get rx => BeatxRx(this);
  BeatxRx<T> get rxAlways => BeatxRx(this, listenOnUnchanged: true);
}

extension TransformToComputedObservable<T> on T Function() {
  ComputedRx<T> get rx => ComputedRx(this);
  ComputedRx<T> get rxAlways => ComputedRx(this, listenOnUnchanged: true);
}
