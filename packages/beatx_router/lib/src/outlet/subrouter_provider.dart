import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class SubrouteProvider extends InheritedWidget {
  const SubrouteProvider({
    super.key,
    required super.child,
    required this.subroutes,
    required this.state,
  });

  final Map<String, Widget Function(BuildContext context, GoRouterState state)>
      subroutes;
  final GoRouterState state;

  static SubrouteProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SubrouteProvider>();
  }

  @override
  bool updateShouldNotify(SubrouteProvider oldWidget) {
    return true;
  }
}
