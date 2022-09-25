part of 'rx.dart';

/// Automatically dispose any of the Rx states when the last widget
/// is disposed.
class DisposableRx<T> extends Rx<T?> {
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

extension TransformToDisposableRx<T> on T {
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
