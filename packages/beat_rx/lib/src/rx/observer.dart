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
  final _observables = <Rx>{};
  bool _subscribed = false;

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
  }

  @override
  void rebuild() {
    final previousObserver = Rx._observer;
    if (!_subscribed) {
      Rx._observer = this;
      _subscribed = true;
    }
    super.rebuild();
    Rx._observer = previousObserver;
  }

  void addObservable(Rx obs) {
    _observables.add(obs);
  }

  @override
  void unmount() {
    final previousObserver = Rx._unmounter;
    Rx._unmounter = this;
    for (final obs in _observables) {
      obs._removeFlutterElement(this);
    }
    Rx._unmounter = previousObserver;
    _observables.clear();
    _subscribed = false;
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
