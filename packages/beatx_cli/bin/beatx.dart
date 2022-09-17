import 'package:args/command_runner.dart';
import 'package:beatx_cli/src/commands/build.dart';
import 'package:beatx_cli/src/commands/clean.dart';
import 'package:beatx_cli/src/commands/watch.dart';

void main(List<String> arguments) async {
  final runner = CommandRunner(
    'beatx',
    'A routing framework for flutter.',
  )
    ..addCommand(BuildRunner())
    ..addCommand(WatchRunner())
    ..addCommand(CleanRunner());

  await runner.run(arguments);
}
