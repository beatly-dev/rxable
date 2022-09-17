import 'package:beatx_cli/src/utils/path.dart';
import 'package:test/test.dart';

main() {
  group('Convert a dart path to a route path', () {
    test('/lib/routes/index.dart => /', () {
      final path = r'/lib/routes/index.dart';
      final route = convertPathToRoute(path);
      expect(route, equals('/'));
    });

    test('/lib/routes/home.dart => /home', () {
      final path = r'/lib/routes/home.dart';
      final route = convertPathToRoute(path);
      expect(route, equals('/home'));
    });

    test('/lib/routes/home/index.dart => /home', () {
      final path = r'/lib/routes/home/index.dart';
      final route = convertPathToRoute(path);
      expect(route, equals('/home'));
    });

    test('/lib/routes/home/room.desk.dart => /home/room.desk', () {
      final path = r'/lib/routes/home/room.desk.dart';
      final route = convertPathToRoute(path);
      expect(route, equals('/home/room.desk'));
    });
  });
}
