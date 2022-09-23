import 'package:beatx_cli/src/core/route_element/route_tree.dart';
import 'package:beatx_cli/src/models/route_element.dart';
import 'package:test/scaffolding.dart';

main() {
  group('Go router converter ', () {
    test('', () async {
      final routeTree = BeatxRouteTree();
      routeTree.addNewRoute(RouteElement(route: route, element: element))
    });
  });
}
