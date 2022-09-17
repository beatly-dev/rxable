import 'package:path/path.dart' as p;

import '../../models/route_element.dart';

class BeatxRouteTree {
  final Map<String, BeatxRouteNode> _nodes = {};

  addNewRoute(RouteElement route) {
    final path = route.route.path;
    _nodes[path] = BeatxRouteNode(
      route: route,
      tree: this,
    );
  }

  constructTree() {
    for (final path in _nodes.keys) {
      final dir = p.dirname(path);
      final current = _nodes[path]!;
      final parent = _nodes[dir];
      if (parent != null) {
        current.parent = parent;
        parent.children.add(current);
      }
    }
  }

  BeatxRouteNode? get root => _nodes['/'];
}

class BeatxRouteNode {
  BeatxRouteNode({
    this.route,
    this.parent,
    required this.tree,
  });

  final RouteElement? route;
  BeatxRouteNode? parent;
  final BeatxRouteTree tree;
  final List<BeatxRouteNode> children = [];

  String toGoRoute() {
    return '''
GoRoute(
  
)
''';
  }
}
