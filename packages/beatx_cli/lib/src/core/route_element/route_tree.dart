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

  String toGoRoute() {
    final visit = <String, String>{};
    return '''
GoRoute(
)
''';
  }
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
}
