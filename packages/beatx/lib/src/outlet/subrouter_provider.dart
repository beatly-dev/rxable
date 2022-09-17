import 'package:flutter/widgets.dart';

class SubrouteProvider extends InheritedWidget {
  const SubrouteProvider({
    super.key,
    required super.child,
    required this.subroutes,
  });

  final Map<String, Widget Function(BuildContext context)> subroutes;

  static SubrouteProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SubrouteProvider>();
  }

  @override
  bool updateShouldNotify(SubrouteProvider oldWidget) {
    return true;
  }
}
