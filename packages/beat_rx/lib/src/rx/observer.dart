part of 'rx.dart';

/// A Helper widget to automatically rebuild the widget
/// when the [Rx] changes.
/// You don't need to explicitly provide your [Rx] to this widget.
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
    with ReactiveStateMixin {
  _ReactableStatelessElement(StatelessWidget widget) : super(widget);
}

// A mixin to automatically rebuild the StatelessWidget
mixin StatefulReactiveMixin on StatefulWidget {
  @override
  StatefulElement createElement() => _ReactableStatefulElement(this);
}

class _ReactableStatefulElement extends StatefulElement
    with ReactiveStateMixin {
  _ReactableStatefulElement(StatefulWidget widget) : super(widget);
}

/// A mixin to automatically rebuild the StatefulWidget's State
mixin ReactiveStateMixin on Element {
  final _RxSubscription _subscription = _RxSubscription();
  final _observables = <Rx>{};

  @override
  void mount(Element? parent, Object? newSlot) {
    _subscription.addListener(markNeedsBuild);
    super.mount(parent, newSlot);
  }

  @override
  void rebuild() {
    final previousObserver = Rx._observer;

    _subscription.unsubscribeAll();
    Rx._observer = _subscription;
    super.rebuild();
    Rx._observer = previousObserver;
  }

  void addObservable(Rx obs) {
    _observables.add(obs);
  }

  void removeObservable(Rx obs) {
    _observables.remove(obs);
  }

  void dispose() {
    for (final obs in _observables) {
      obs._removeFlutterElement(this);
    }
    _observables.clear();
  }

  @override
  void unmount() {
    dispose();
    _subscription.unsubscribeAll();
    _subscription.removeListener(markNeedsBuild);
    super.unmount();
  }
}

/*
  Extensions
*/

extension WrapWithReactiveBuilderWithBuildContext on Widget Function(
  BuildContext context,
) {
  /// Wrap the widget with [ReactiveBuilder] to automatically rebuild
  Widget get observe => ReactiveBuilder(
        builder: this,
      );
}

extension WrapWithReactiveBuilderWithoutBuildContext on Widget Function() {
  /// Wrap the widget with [ReactiveBuilder] to automatically rebuild
  Widget get observe => ReactiveBuilder(
        builder: (_) => this(),
      );
}
