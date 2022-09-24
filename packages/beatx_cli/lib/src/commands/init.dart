import 'dart:io';

import 'package:args/command_runner.dart';

class InitRunner extends Command {
  InitRunner();

  @override
  String get name => 'init';

  @override
  String get description => 'Initialize the project';

  @override
  run() async {
    Process.run(
      'flutter',
      ['pub', 'add', 'go_router', 'beatx_annotations'],
      runInShell: true,
    );
  }
}
