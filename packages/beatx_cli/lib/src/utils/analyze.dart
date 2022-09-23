import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';

analyzeSomeFiles(
  AnalysisContextCollection collection,
  List<String> includedPaths,
) async {
  for (String path in includedPaths) {
    AnalysisContext context = collection.contextFor(path);
    await analyzeSingleFile(context, path);
  }
}

analyzeAllFiles(AnalysisContextCollection collection) async {
  for (AnalysisContext context in collection.contexts) {
    for (String path in context.contextRoot.analyzedFiles()) {
      await analyzeSingleFile(context, path);
    }
  }
}

analyzeSingleFile(AnalysisContext context, String path) async {
  final session = context.currentSession;
  final resolved = await session.getUnitElement(path) as UnitElementResult;
}
