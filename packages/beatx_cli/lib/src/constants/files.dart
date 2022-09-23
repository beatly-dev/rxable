import 'package:path/path.dart' as p;

/// Directory to store the metadata
const metadataOutputDir = '.dart_tool/beatx';

/// Entry point
const routesDir = 'lib/routes';

/// Auto-generated GoRouter file
const routeOutputPath = '$routesDir/_app_.dart';

/// Index page
const indexPageFile = '$routesDir/index.dart';

extension NormalizedAbsolutePath on String {
  /// Get the normalized absolute path
  String get normalizedAbsolutePath => p.normalize(p.absolute(this));

  /// Check if the file is a route file
  bool get isRouteFile {
    final path = normalizedAbsolutePath;
    return path.startsWith(routesDir.normalizedAbsolutePath) &&
        path.endsWith('.dart') &&
        !path.endsWith('_app_.dart') &&
        !path.endsWith('.route.dart') &&
        !path.endsWith('.freezed.dart') &&
        !path.endsWith('.beat.dart') &&
        !path.endsWith('.g.dart');
  }
}
