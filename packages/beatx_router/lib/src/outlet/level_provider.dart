import 'package:flutter/widgets.dart';

class LevelProvider extends InheritedWidget {
  const LevelProvider({super.key, required super.child, required this.level});

  final int level;

  static LevelProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LevelProvider>();
  }

  @override
  bool updateShouldNotify(LevelProvider oldWidget) {
    if (level != oldWidget.level) {
      return true;
    }
    return false;
  }
}
