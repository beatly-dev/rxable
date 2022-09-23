import 'dart:io';

import 'package:args/command_runner.dart';

import '../constants/files.dart';

class CleanRunner extends Command {
  CleanRunner();

  @override
  String get name => 'clean';

  @override
  String get description => 'Remove all the generated files';

  @override
  run() async {
    Directory(metadataOutputDir).deleteSync(recursive: true);
    File(routeOutputPath).deleteSync();
  }
}
