import 'package:beatx_cli/src/utils/path.dart';
import 'package:test/test.dart';

main() {
  group('find a parent path of the given path', () {
    test(r'parent of / is empty', () async {
      final path = r'/';
      expect(parentPath(path).isEmpty, isTrue);
    });
    test(r'parent of /child is /', () async {
      final path = r'/child';
      expect(parentPath(path), equals('/'));
    });

    test(r'parent of /home/room is /home', () async {
      final path = r'/home/room';
      expect(parentPath(path), equals('/home'));
    });

    test('parent of /home/myhome.something is /home', () async {
      final path = r'/home/myhome.something';
      expect(parentPath(path), equals('/home'));
    });

    test('parent of /home/room.desk/drawer is /home/room/desk', () async {
      final path = r'/home/room.desk/drawer';
      expect(parentPath(path), equals('/home/room/desk'));
    });

    test('parent of /home.room/desk.drawer is /home/room', () {
      final path = r'/home.room/desk.drawer';
      expect(parentPath(path), equals('/home/room'));
    });
  });
}
