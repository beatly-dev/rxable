import 'package:json_annotation/json_annotation.dart';

import '../utils/path.dart';

part 'route_node.g.dart';

/// State of the route path
/// [path] is the full path of the route
/// [parent] is the parent of the route.
/// [isRoot] is true if the route is a page rather than a layout.
@JsonSerializable()
class RouteNode {
  RouteNode({
    required this.path,
    required this.libPath,
    this.parent = '',
    this.isRoot = false,
  });
  final String libPath;
  final String path;
  final String parent;
  final bool isRoot;

  Map<String, dynamic> toJson() => _$RouteNodeToJson(this);
  factory RouteNode.fromJson(Map<String, dynamic> json) =>
      _$RouteNodeFromJson(json);

  /// Convert a file path to a route path
  /// 1. Check if the path is a root or a sub page
  /// 2. Find a parent path
  /// 3. convert flat path (e.g. /home.room.desk) to nested path (e.g. /home/room/desk)
  ///   3-1. Do not nesting if the path is wrapped with '[]'.
  ///       (e.g. /home[.room.desk] => /home.room.desk, /home[.]room.desk => /home.room/desk)
  /// 4. convert path params to go_router params. (e.g. /home/$room/desk => /home/:room/desk)
  factory RouteNode.fromLibraryPath(String path, [bool isRoot = false]) {
    final routePath = convertPathToRoute(path);
    final parent = isRoot ? '' : parentPath(routePath);
    final nestedPath = convertFlatPathToNestedPath(routePath);
    final withParams = convertPathParamToGoParam(nestedPath);

    return RouteNode(
      libPath: path,
      path: withParams,
      isRoot: isRoot || routePath == '/',
      parent: parent,
    );
  }
}
