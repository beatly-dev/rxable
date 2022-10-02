part of 'rx.dart';

class RxFamily<ValueType, InputType> {
  RxFamily(
    this.builder, {
    this.onDispose,
    this.autoDispose = false,
    this.listenOnUnchanged = false,
  });

  final _bucket = <InputType, Rx<ValueType>>{};

  /// A function that compute the wanted value
  final ValueType Function(InputType input) builder;

  /// Called on a dispose
  final void Function(ValueType lastValue)? onDispose;

  /// Dispose the Rx when there is no widget listening to it
  final bool autoDispose;

  /// Notify even when the value is not changed
  final bool listenOnUnchanged;

  Rx<ValueType> call(InputType input) {
    _bucket[input] ??= Rx(
      () => builder(input),
      onDispose: (lastValue) {
        _bucket.remove(input);
        onDispose?.call(lastValue);
      },
      autoDispose: autoDispose,
      listenOnUnchanged: listenOnUnchanged,
    );

    return _bucket[input]!;
  }
}

class AsyncRxFamily<ValueType, InputType> {
  AsyncRxFamily(
    this.builder, {
    this.onDispose,
    this.autoDispose = false,
    this.listenOnUnchanged = false,
  });

  final _bucket = <dynamic, AsyncRx<ValueType>>{};

  /// A function that compute the wanted value
  final Future<ValueType> Function() Function(InputType input) builder;

  /// Called on a dispose
  final void Function(Future<ValueType> lastValue)? onDispose;

  /// Dispose the Rx when there is no widget listening to it
  final bool autoDispose;

  /// Notify even when the value is not changed
  final bool listenOnUnchanged;

  AsyncRx<ValueType> call(InputType input) {
    _bucket[input] ??= AsyncRx<ValueType>(
      builder(input),
      onDispose: (lastValue) {
        _bucket.remove(input);
        onDispose?.call(lastValue);
      },
      autoDispose: autoDispose,
      listenOnUnchanged: listenOnUnchanged,
    );

    return _bucket[input]!;
  }
}

class FutureRxFamily<ValueType, InputType> {
  FutureRxFamily(
    this.builder, {
    this.onDispose,
    this.autoDispose = false,
    this.listenOnUnchanged = false,
  });

  final _bucket = <dynamic, FutureRx<ValueType>>{};

  /// A function that compute the wanted value
  final Future<ValueType> Function(InputType input) builder;

  /// Called on a dispose
  final void Function(Future<ValueType> lastValue)? onDispose;

  /// Dispose the Rx when there is no widget listening to it
  final bool autoDispose;

  /// Notify even when the value is not changed
  final bool listenOnUnchanged;

  FutureRx<ValueType> call(InputType input) {
    _bucket[input] ??= FutureRx<ValueType>(
      builder(input),
      onDispose: (lastValue) {
        _bucket.remove(input);
        onDispose?.call(lastValue);
      },
      autoDispose: autoDispose,
      listenOnUnchanged: listenOnUnchanged,
    );

    return _bucket[input]!;
  }
}

extension TransformToAsyncRxFamily<T, P, R extends AsyncRx<T>>
    on Future<T> Function() Function(P input) {
  /// Get a [RxFamily]
  AsyncRxFamily<T, P> rxFamily({
    void Function(Future<T> lastValue)? onDispose,
    bool listenOnUnchanged = false,
    bool autoDispose = false,
  }) =>
      AsyncRxFamily<T, P>(
        this,
        autoDispose: autoDispose,
        onDispose: onDispose,
        listenOnUnchanged: listenOnUnchanged,
      );
}

extension TransformToFutureRxFamily<T, P> on Future<T> Function(P input) {
  /// Get a [RxFamily]
  FutureRxFamily<T, P> rxFamily({
    void Function(Future<T> lastValue)? onDispose,
    bool listenOnUnchanged = false,
    bool autoDispose = false,
  }) =>
      FutureRxFamily<T, P>(
        this,
        autoDispose: autoDispose,
        onDispose: onDispose,
        listenOnUnchanged: listenOnUnchanged,
      );
}

extension TransformToRxFamily<T, P, R extends Rx<T>> on T Function(P input) {
  /// Get a [RxFamily]
  RxFamily<T, P> rxFamily({
    void Function(T lastValue)? onDispose,
    bool listenOnUnchanged = false,
    bool autoDispose = false,
  }) =>
      RxFamily<T, P>(
        this,
        autoDispose: autoDispose,
        onDispose: onDispose,
        listenOnUnchanged: listenOnUnchanged,
      );
}
