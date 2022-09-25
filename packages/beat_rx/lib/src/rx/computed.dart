part of 'rx.dart';

/// A widget that rebuilds when the collection of [Rx]s changes.
/// ComputedRx does not hold any object, so it does not need to be disposed.
class ComputedRx<T> extends Rx<T?> {
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
    Rx._observer?.subscribe(this);
    return _value;
  }

  /// ComputedRx can't assign new value.
  @override
  set value(T? newVal) {}
}

extension TransformToComputedRx<T> on T Function() {
  /// Get a ComputedRx
  ComputedRx<T> get rx => ComputedRx(this);

  /// Get a ComputedRx, notify even when the value is not changed
  ComputedRx<T> get rxAlways => ComputedRx(this, listenOnUnchanged: true);
}
