import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:path/path.dart' as p;

/// Getter for all libraries in the current project.
/// In order to get the current collection of the project,
/// using a getter rather than a variable.
AnalysisContextCollection get libraryCollection => AnalysisContextCollection(
      includedPaths: [
        p.normalize(p.absolute('lib/')),
      ],
    );
