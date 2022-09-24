import 'package:json_annotation/json_annotation.dart';

import '../constants/files.dart';
import '../utils/path.dart';
import 'route_element.dart';
import 'route_node.dart';

part 'route_tree.g.dart';

@JsonSerializable()
class RouteTree {
  RouteTree([Map<String, RouteNode>? nodes]) : nodes = nodes ?? {};
  final Map<String, RouteNode> nodes;
  final Set<RouteNode> rootNodes = {};
  bool constructed = false;

  addNewRoute(RouteElement route) {
    final path = route.info.routePath;
    nodes[path] = RouteNode(
      info: route.info,
      tree: this,
    );
    constructed = false;
  }

  constructTree() {
    if (constructed) return;
    for (final node in nodes.values) {
      if (node.info.isRoot) {
        rootNodes.add(node);
        continue;
      }
      final parentPath = node.info.parentRoutePath;
      if (parentPath.isEmpty) continue;
      final parent = nodes[parentPath];

      if (parent == null) {
        rootNodes.add(node);
        continue;
      }

      parent.children.add(node);
    }
    constructed = true;
  }

  @override
  String toString() {
    constructTree();
    final roots = rootNodes;
    final trees = roots.map((root) => root.toString()).join(',');
    final libs = nodes.values.map((e) {
      final path = e.info.libPath.split(routesDir).skip(1).join();
      final routePath = createRouteFilePath(path);
      return "import r'.$routePath';";
    }).join();
    return '''
import 'package:go_router/go_router.dart';
$libs

final \$routes = [
  $trees
];
''';
  }

  Map<String, dynamic> toJson() => _$RouteTreeToJson(this);
  factory RouteTree.fromJson(Map<String, dynamic> json) =>
      _$RouteTreeFromJson(json);
}

@JsonSerializable()
class RouteNode {
  RouteNode({
    required this.info,
    required this.tree,
  });

  final RouteInfo info;
  final RouteTree tree;
  final List<RouteNode> children = [];

  @override
  String toString() {
    final childRoutes = children.map((child) => child.toString()).join(',');
    return '''
GoRouteData.\$route(
  path: '${info.routePath}',
  factory: ${info.widgetName}Route.fromState,
  routes: [
    $childRoutes
  ],
)
''';
  }

  Map<String, dynamic> toJson() => _$RouteNodeToJson(this);
  factory RouteNode.fromJson(Map<String, dynamic> json) =>
      _$RouteNodeFromJson(json);
}
