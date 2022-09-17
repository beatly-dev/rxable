import 'package:beatx_cli/src/utils/path.dart';
import 'package:test/test.dart';

main() {
  group('convert flat path to nested path', () {
    test('/home/room/desk is /home/room/desk', () async {
      final path = r'/home/room/desk';
      expect(convertFlatPathToNestedPath(path), equals(path));
    });

    test('/home/room.desk is /home/room/desk', () async {
      final path = r'/home/room.desk';
      expect(convertFlatPathToNestedPath(path), equals('/home/room/desk'));
    });
    test('/home/room.desk/drawer is /home/room/desk/drawer', () async {
      final path = r'/home/room.desk/drawer';
      expect(
        convertFlatPathToNestedPath(path),
        equals('/home/room/desk/drawer'),
      );
    });
    test('/home/room[.]desk is /home/room.desk', () async {
      final path = r'/home/room[.]desk';
      expect(convertFlatPathToNestedPath(path), equals('/home/room.desk'));
    });
    test('/home/room[.desk] is /home/room.desk', () async {
      final path = r'/home/room[.desk]';
      expect(convertFlatPathToNestedPath(path), equals('/home/room.desk'));
    });
  });
}
