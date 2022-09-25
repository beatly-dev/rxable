part of 'rx.dart';

class FamilyRx<T, P> {
  FamilyRx(
    this.builder, {
    this.onDispose,
    this.autoDispose = false,
    this.listenOnUnchanged = false,
  });

  static final _bucket = <dynamic, Rx>{};

  /// A function that compute the wanted value
  final T Function(P input) builder;

  /// Called on a dispose
  final void Function(T lastValue)? onDispose;

  /// Dispose the Rx when there is no widget listening to it
  final bool autoDispose;

  /// Notify even when the value is not changed
  final bool listenOnUnchanged;

  Rx<T> call(P input) {
    _bucket[input] ??= Rx<T>(
      () => builder(input),
      listenOnUnchanged: listenOnUnchanged,
      autoDispose: autoDispose,
      onDispose: (lastValue) {
        _bucket.remove(input);
        onDispose?.call(lastValue);
      },
    );
    return _bucket[input]! as Rx<T>;
  }
}

extension TransformToFamilyRx<T, P> on T Function(P input) {
  /// Get a [FamilyRx]
  FamilyRx<T, P> rxFamily({
    void Function(T lastValue)? onDispose,
    bool listenOnUnchanged = false,
    bool autoDispose = false,
  }) =>
      FamilyRx<T, P>(
        this,
        autoDispose: autoDispose,
        onDispose: onDispose,
        listenOnUnchanged: listenOnUnchanged,
      );
}
