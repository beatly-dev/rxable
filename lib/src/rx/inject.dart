part of 'rx.dart';

extension InjectRx<T> on Rx<T> {
  /// Inject Rx to the widget
  Rx<T> inject(
    BuildContext context,

    /// Original builder (useful when you want to use the original build process)
    T Function(T Function() build)? builder,
  ) {
    final elm = context as Element;
    _injectedToWidget[elm] = Rx<T>(
      () => builder?.call(compute) ?? compute(),
      owner: elm,
      original: this,
      autoDispose: autoDispose,
      listenOnUnchanged: listenOnUnchanged,
      onDispose: (lastValue) {
        _injectedToWidget.remove(elm);
        onDispose?.call(lastValue);
      },
    );
    return _injectedToWidget[elm] as Rx<T>;
  }

  /// Get injected Rx from the widget
  Rx<T>? getInjected(BuildContext context) {
    Rx<T>? injected;

    context.visitAncestorElements((element) {
      if (_injectedToWidget.containsKey(element)) {
        injected = _injectedToWidget[element];
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
    _injectedToWidget[elm] = this;
    return this;
  }

  /// Remove Rx from the widget
  void uninject(BuildContext context) {
    final elm = context as Element;
    _injectedToWidget.remove(elm);
  }

  /// Get injected Rx from the widget
  R? getInjected(BuildContext context) {
    final elm = context as Element;
    return _injectedToWidget[elm] as R?;
  }
}

extension InjectAsyncRx<T, R extends AsyncRx<T>> on R {
  /// Inject Rx to the widget
  R inject(
    BuildContext context,
  ) {
    final elm = context as Element;
    _injectedToWidget[elm] = this;
    return this;
  }

  /// Remove Rx from the widget
  void uninject(BuildContext context) {
    final elm = context as Element;
    _injectedToWidget.remove(elm);
  }

  /// Get injected Rx from the widget
  R? getInjected(BuildContext context) {
    final elm = context as Element;
    return _injectedToWidget[elm] as R?;
  }
}
