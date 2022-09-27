part of 'rx.dart';

extension InjectRx<T> on Rx<T> {
  /// Inject Rx to the widget
  Rx<T> inject(
    BuildContext context,

    /// Original builder (useful when you want to use the original build process)
    T Function(T Function() build)? builder,
  ) {
    final elm = context as Element;
    _injected[elm] = Rx<T>(
      () => builder?.call(compute) ?? compute(),
      autoDispose: autoDispose,
      listenOnUnchanged: listenOnUnchanged,
      onDispose: (lastValue) {
        _injected.remove(elm);
        onDispose?.call(lastValue);
      },
    );
    return _injected[elm] as Rx<T>;
  }

  /// Remove Rx from the widget
  void uninject(BuildContext context) {
    final elm = context as Element;
    _injected.remove(elm);
  }

  /// Get injected Rx from the widget
  Rx<T>? getInjected(BuildContext context) {
    Rx<T>? injected;

    context.visitAncestorElements((element) {
      if (_injected.containsKey(element)) {
        injected = _injected[element] as Rx<T>?;
        return false;
      }
      return true;
    });

    /// find ancestor injection
    /// mark current Rx as searched.
    return injected;
  }
}

extension InjectFutureRx<T, R extends FutureRx<T>> on R {
  /// Inject Rx to the widget
  R inject(
    BuildContext context,
  ) {
    final elm = context as Element;
    _injected[elm] = this;
    return this;
  }

  /// Remove Rx from the widget
  void uninject(BuildContext context) {
    final elm = context as Element;
    _injected.remove(elm);
  }

  /// Get injected Rx from the widget
  R? getInjected(BuildContext context) {
    final elm = context as Element;
    return _injected[elm] as R?;
  }
}

extension InjectAsyncRx<T, R extends AsyncRx<T>> on R {
  /// Inject Rx to the widget
  R inject(
    BuildContext context,
  ) {
    final elm = context as Element;
    _injected[elm] = this;
    return this;
  }

  /// Remove Rx from the widget
  void uninject(BuildContext context) {
    final elm = context as Element;
    _injected.remove(elm);
  }

  /// Get injected Rx from the widget
  R? getInjected(BuildContext context) {
    final elm = context as Element;
    return _injected[elm] as R?;
  }
}
