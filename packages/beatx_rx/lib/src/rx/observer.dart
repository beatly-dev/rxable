part of 'rx.dart';

/// A Helper widget to automatically rebuild the widget
/// when the [BeatxRx] changes.
/// You don't need to explicitly provide your [BeatxRx] to this widget.
class RxObserver extends StatelessRxObserver {
  const RxObserver({
    required this.builder,
    super.key,
  });

  /// A widget builder
  final Widget Function(BuildContext context) builder;

  @override
  Widget build(BuildContext context) => builder(context);
}
/*
  Statless widget
*/

/// You can extend this class to create your custom statless widget
/// which reacts to the change of the [BeatxRx].
abstract class StatelessRxObserver extends StatefulRxObserver {
  const StatelessRxObserver({super.key}) : super();

  /// A widget constructor
  Widget build(BuildContext context);

  @override
  StatefulRxObserverState createState() => _StatelessRxObserverState();
}

class _StatelessRxObserverState
    extends StatefulRxObserverState<StatelessRxObserver> {
  @override
  Widget build(BuildContext context) => widget.build(context);
}

/* 
  Base class 
*/
/// You can extend this class and [StatefulRxObserverState]
/// to create your custom stateful widget
/// which reacts to the change of the [BeatxRx].
abstract class StatefulRxObserver extends StatefulWidget {
  const StatefulRxObserver({super.key});

  @override
  StatefulElement createElement() => _RxObserverElement(this);

  @override
  StatefulRxObserverState createState();
}

/// A state class for [StatefulRxObserver]
abstract class StatefulRxObserverState<T extends StatefulRxObserver>
    extends State<T> {
  final _BeatxSubscription _subscription = _BeatxSubscription();
  @mustCallSuper
  @override
  void dispose() {
    _subscription.unsubscribeAll();
    super.dispose();
  }

  Widget _build(BuildContext context) => build(context);
}

class _RxObserverElement extends StatefulElement {
  _RxObserverElement(super.widget);

  @override
  late final StatefulRxObserverState state =
      (widget as StatefulRxObserver).createState();

  @override
  Widget build() {
    return AnimatedBuilder(
      animation: state._subscription,
      builder: (context, __) {
        final previousObserver = BeatxRx._observer;

        /// Opt-out from the previous subscription if any
        /// to prevent duplicated subscription
        state._subscription.unsubscribeAll();
        BeatxRx._observer = state._subscription;
        final child = state._build(context);
        BeatxRx._observer = previousObserver;
        return child;
      },
    );
  }
}

/*
  Extensions
*/

extension WrapWithBeatxObserverBuilder on Widget Function(
  BuildContext context,
) {
  /// Wrap the widget with [RxObserver] to automatically rebuild
  Widget get observe => RxObserver(
        builder: this,
      );
}

extension WrapWithBeatxObserver on Widget Function() {
  /// Wrap the widget with [RxObserver] to automatically rebuild
  Widget get observe => RxObserver(
        builder: (_) => this(),
      );
}
