import 'package:source_gen/source_gen.dart';

import 'route_node.dart';

class RouteElement {
  RouteElement({
    required this.route,
    required this.element,
  });
  final RouteNode route;
  final AnnotatedElement element;

  bool get isNewPage =>
      element.annotation.peek('isNewPage')?.boolValue ?? false;

  @override
  String toString() => '''
  RouteElement(
    path: ${route.toJson()},
    element: $element,
  )
  ''';
}
