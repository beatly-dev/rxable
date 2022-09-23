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

    final routeElements = <RouteElement>[];

    for (final context in libraryCollection.contexts) {
      /// Get all the routes from the library
      final routeFiles = context.contextRoot.analyzedFiles().where(
            (file) => file.isRouteFile,
          );

      // Add the route elements to the routes list
      routeElements.addAll(
        /// Get all the route elements from the library
        (await Future.wait(
          routeFiles.map(
            (file) => getSingleRouteElement(context, file),
          ),
        ))
            .where((element) => element != null)
            .cast<RouteElement>(),
      );
    }

    final tree = BeatxRouteTree();

    /// Generate the route files
    for (final route in routeElements) {
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

    final routes = tree.toGoRoute();

    print(routes);
    final routeOutputFile = File(routeOutputPath);

    await routeOutputFile.writeAsString(routes);
  }
}
