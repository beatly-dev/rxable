import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/analysis_context_collection.dart';

import '../utils/routes.dart';

class EntryGenerator {
  EntryGenerator({
    required this.context,
    required this.path,
    required this.collection,
  });

  final String path;
  final AnalysisContext context;
  final AnalysisContextCollection collection;

  run() async {
    if (!routesDirExists()) {
      initRoutesDir();
    } else if (!routeAppFileExists()) {
      initRouteAppFile();
    }
  }
}
