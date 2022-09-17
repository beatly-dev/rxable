import 'package:path/path.dart' as p;

import '../constants/files.dart';
import 'regexp.dart';

String convertPathToRoute(String path) {
  final routeDirIndex = path.indexOf(routesDir);
  final libPath = path.substring(
    routeDirIndex != -1 ? path.indexOf(routesDir) + routesDir.length : 0,
  );
  final withoutExt = p.withoutExtension(libPath);
  if (withoutExt.endsWith('/index')) {
    final route = withoutExt.substring(0, withoutExt.length - 6);
    return route.isEmpty ? '/' : route;
  }
  return withoutExt;
}

/// 3. convert flat path (e.g. /home.room.desk) to nested path (e.g. /home/room/desk)
///   3-1. Do not nesting if the path is wrapped with '[]'.
///       (e.g. /home[.room.desk] => /home.room.desk, /home[.]room.desk => /home.room/desk)
String convertFlatPathToNestedPath(String path) {
  var parCount = 0;
  for (var i = 0; i < path.length; ++i) {
    final c = path[i];
    if (c == '[') {
      parCount++;
    } else if (c == ']') {
      parCount--;
    } else if (c == '.' && parCount == 0) {
      path = path.replaceRange(i, i + 1, '/');
    }
  }
  path = path.replaceAll(RegExp(r'[\[\]]'), '');
  return path;
}

/// Find a parent page path
String parentPath(String path) {
  if (path == '/') return '';
  final directory = p.dirname(path);
  return convertPathParamToGoParam(convertFlatPathToNestedPath(directory));
}

/// Convert $path param to :path param
String convertPathParamToGoParam(String path) {
  final matches = pathParamRegExp.allMatches(path);
  final buffer = StringBuffer();
  if (matches.isEmpty) {
    return path;
  }
  final nonMatched = matches.first.start;
  buffer.write(path.substring(0, nonMatched));
  var prevEnd = nonMatched;
  for (final match in matches) {
    final result = match[1]!;
    buffer.write(path.substring(prevEnd, match.start + 1));
    buffer.write(':');
    buffer.write(result.substring(1));
    prevEnd = match.end;
  }
  buffer.write(path.substring(prevEnd));
  return buffer.toString();
}

/// Convert {lib}.dart to {lib}.route.dart
String createRouteFilePath(String path) {
  return path.replaceAll('.dart', '.route.dart');
}
