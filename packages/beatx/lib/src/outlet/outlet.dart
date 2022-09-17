import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;

import 'level_provider.dart';
import 'subrouter_provider.dart';

class Outlet extends StatelessWidget {
  const Outlet({Key? key, this.placeholder}) : super(key: key);

  final Widget? placeholder;

  @override
  Widget build(BuildContext context) {
    final go = GoRouter.of(context);
    final location = go.location;
    final level = LevelProvider.of(context)?.level ?? 1;
    final subroute = SubrouteProvider.of(context);

    assert(
      subroute != null,
      'Outlet widget must have SubrouteProvier ancestor',
    );

    final paths = p.split(location);
    final currentPath = p.joinAll(paths.take(level));
    final child = paths.length > level ? paths[level] : 'index';
    final childPath = p.join(currentPath, child);

    final childWidget = subroute!.subroutes[childPath]?.call(context);

    return LevelProvider(
      level: level + 1,
      child: childWidget ?? placeholder ?? const SizedBox.shrink(),
    );
  }
}
