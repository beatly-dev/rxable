import 'package:args/command_runner.dart';

class WatchRunner extends Command {
  WatchRunner();

  @override
  String get name => 'watch';

  @override
  String get description => 'Watch for changes and rebuild';

  @override
  run() async {}
}
