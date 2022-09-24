import 'package:json_annotation/json_annotation.dart';

import '../utils/path.dart';

part 'route_node.g.dart';

/// State of the route path
/// [routePath] is the full path of the route
/// [parentRoutePath] is the parent of the route.
/// [isRoot] is true if the route is a page rather than a layout.
@JsonSerializable()
class RouteInfo {
  RouteInfo({
    required this.libPath,
    required this.routePath,
    required this.widgetName,
    this.parentRoutePath = '',
    this.isRoot = false,
    this.isLayout = false,
  });
  final String libPath;
  final String routePath;
  final String parentRoutePath;
  final String widgetName;
  final bool isRoot;
  final bool isLayout;

  Map<String, dynamic> toJson() => _$RouteInfoToJson(this);
  factory RouteInfo.fromJson(Map<String, dynamic> json) =>
      _$RouteInfoFromJson(json);

  /// Convert a file path to a route path
  /// 1. Check if the path is a root or a sub page
  /// 2. Find a parent path
  /// 3. convert flat path (e.g. /home.room.desk) to nested path (e.g. /home/room/desk)
  ///   3-1. Do not nesting if the path is wrapped with '[]'.
  ///       (e.g. /home[.room.desk] => /home.room.desk, /home[.]room.desk => /home.room/desk)
  /// 4. convert path params to go_router params. (e.g. /home/$room/desk => /home/:room/desk)
  factory RouteInfo.fromLibraryPath(
    String path, {
    required String widgetName,
    bool isRoot = false,
    bool isLayout = false,
  }) {
    final routePath = convertPathToRoute(path);
    final parentRoutePath = isRoot ? '' : parentPath(routePath);
    final nestedPath = convertFlatPathToNestedPath(routePath);
    final withParams = convertPathParamToGoParam(nestedPath);

    return RouteInfo(
      libPath: path,
      widgetName: widgetName,
      routePath: withParams,
      isRoot: isRoot || routePath == '/',
      parentRoutePath: parentRoutePath,
    );
  }
}
