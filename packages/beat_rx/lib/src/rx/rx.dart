import 'dart:async';
import 'dart:collection';

import 'package:async/async.dart';
import 'package:flutter/widgets.dart';

part 'computed.dart';
part 'disposable.dart';
part 'future.dart';
part 'number.dart';
part 'observer.dart';
part 'string.dart';

class _RxSubscription extends ChangeNotifier {
  final HashSet<Rx> _observables = HashSet();

  /// Subscribe to the observable
  void subscribe(Rx obs) {
    if (_observables.contains(obs)) {
      return;
    }
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
    _observables.clear();
  }
}

/// Reactive data class
class Rx<T> extends ChangeNotifier {
  Rx(this._value, {this.listenOnUnchanged = false});
  static _RxSubscription? _observer;
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

extension TransformToRx<T> on T {
  /// Get a Rx
  Rx<T> get rx => Rx(this);

  /// Get a Rx, notify even when the value is not changed
  Rx<T> get rxAlways => Rx(this, listenOnUnchanged: true);
}
