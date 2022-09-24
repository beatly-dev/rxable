import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:source_gen/source_gen.dart';

import '../../constants/files.dart';
import '../../constants/type_checker.dart';
import '../../models/route_element.dart';
import '../../models/route_node.dart';

Future<RouteElement?> getSingleRouteElement(
  AnalysisContext context,
  String path,
) async {
  if (!path.isRouteFile) {
    return null;
  }
  final unitElement = await context.currentSession
      .getUnitElement(path.normalizedAbsolutePath) as UnitElementResult;
  final library = LibraryReader(unitElement.element.library);
  final annotated = library.annotatedWith(xrouteChecker);
  if (annotated.length > 1) {
    throw Exception('Only one xroute per file is allowed. file: $path');
  }
  if (annotated.isEmpty) {
    return null;
  }

  final isRoot = annotated.first.annotation.peek('isRoot')?.boolValue ?? false;
  final isLayout =
      annotated.first.annotation.peek('isLayout')?.boolValue ?? false;
  final widgetName = annotated.first.element.displayName;
  return RouteElement(
    element: annotated.first,
    info: RouteInfo.fromLibraryPath(
      path,
      widgetName: widgetName,
      isRoot: isRoot,
      isLayout: isLayout,
    ),
  );
}
