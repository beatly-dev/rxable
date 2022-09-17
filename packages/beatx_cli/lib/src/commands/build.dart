import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:args/command_runner.dart';

import '../constants/files.dart';
import '../core/route_element/beatx_route_data.dart';
import '../core/route_element/route_tree.dart';
import '../core/route_element/single_route_file.dart';
import '../models/route_element.dart';
import '../resources/collection.dart';
import '../utils/path.dart';
import '../utils/routes.dart';

class BuildRunner extends Command {
  BuildRunner();

  @override
  String get name => 'build';

  @override
  String get description => 'Build once and exit';

  @override
  run() async {
    if (!routesDirExists()) {
      initRoutesDir();
    } else if (!routeAppFileExists()) {
      initRouteAppFile();
    }

    final routes = <RouteElement>[];

    for (final context in libraryCollection.contexts) {
      /// Get all the routes from the library
      final routeFiles = context.contextRoot.analyzedFiles().where(
            (file) => file.isRouteFile,
          );

      /// Get all the route elements from the library
      final routeElements = await Future.wait(
        routeFiles.map(
          (file) => getSingleRouteElement(context, file),
        ),
      );

      // Add the route elements to the routes list
      routes.addAll(
        routeElements.where((element) => element != null).cast<RouteElement>(),
      );
    }

    final tree = BeatxRouteTree();

    /// Generate the route files
    for (final route in routes) {
      final element = route.element.element;
      if (element is! ClassElement) {
        throw Exception('''
XRoute annotation can only be used on classes.
''');
      }
      tree.addNewRoute(route);

      final path = createRouteFilePath(route.route.libPath);

      final file = File(path);

      final routeData = BeatxRotueData(route);

      await file.writeAsString(routeData.toString(), flush: true);
    }
    tree.constructTree();

    final root = tree.root;

    final routesArray = root.toGoRoute();
  }
}
