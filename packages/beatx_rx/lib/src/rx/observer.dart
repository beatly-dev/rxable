part of 'rx.dart';

/// A Helper widget to automatically rebuild the widget
/// when the [BeatxRx] changes.
/// You don't need to explicitly provide your [BeatxRx] to this widget.
class ReactiveBuilder extends StatelessWidget with StatelessReactiveMixin {
  const ReactiveBuilder({
    required this.builder,
    super.key,
  });

  /// A widget builder
  final Widget Function(BuildContext context) builder;

  @override
  Widget build(BuildContext context) => builder(context);
}

// A mixin to automatically rebuild the StatelessWidget
mixin StatelessReactiveMixin on StatelessWidget {
  @override
  StatelessElement createElement() => _ReactableStatelessElement(this);
}

class _ReactableStatelessElement extends StatelessElement
    with ObserverStateMixin {
  _ReactableStatelessElement(StatelessWidget widget) : super(widget);
}

// A mixin to automatically rebuild the StatelessWidget
mixin StatefulReactiveMixin on StatefulWidget {
  @override
  StatefulElement createElement() => _ReactableStatefulElement(this);
}

class _ReactableStatefulElement extends StatefulElement
    with ObserverStateMixin {
  _ReactableStatefulElement(StatefulWidget widget) : super(widget);
}

/// A mixin to automatically rebuild the StatefulWidget's State
mixin ObserverStateMixin on Element {
  final _BeatxSubscription _subscription = _BeatxSubscription();

  @override
  void mount(Element? parent, Object? newSlot) {
    _subscription.addListener(markNeedsBuild);
    super.mount(parent, newSlot);
  }

  @override
  void rebuild() {
    final previousObserver = BeatxRx._observer;

    _subscription.unsubscribeAll();
    BeatxRx._observer = _subscription;
    super.rebuild();
    BeatxRx._observer = previousObserver;
  }

  @override
  void unmount() {
    _subscription.unsubscribeAll();
    _subscription.removeListener(markNeedsBuild);
    super.unmount();
  }
}

/*
  Extensions
*/

extension WrapWithBeatxObserverBuilder on Widget Function(
  BuildContext context,
) {
  /// Wrap the widget with [ReactiveBuilder] to automatically rebuild
  Widget get observe => ReactiveBuilder(
        builder: this,
      );
}

extension WrapWithBeatxObserver on Widget Function() {
  /// Wrap the widget with [ReactiveBuilder] to automatically rebuild
  Widget get observe => ReactiveBuilder(
        builder: (_) => this(),
      );
}
