import 'package:beatx_cli/src/utils/path.dart';
import 'package:test/test.dart';

main() {
  group('Convert path params to go_router params:', () {
    test('no param', () async {
      final path = '/home';
      expect(convertPathParamToGoParam(path), equals(path));
    });
    test('one param', () async {
      final path = r'/$home';
      expect(convertPathParamToGoParam(path), equals('/:home'));
    });

    test('two params', () async {
      final path = r'/$home/$room';
      expect(convertPathParamToGoParam(path), equals('/:home/:room'));
    });

    test('two params with gap', () async {
      final path = r'/$home/room/$desk';
      expect(convertPathParamToGoParam(path), equals('/:home/room/:desk'));
    });

    test('a param between path', () async {
      final path = r'/home/$room/desk';
      expect(convertPathParamToGoParam(path), equals('/home/:room/desk'));
    });

    test('a param at the end', () async {
      final path = r'/home/$room';
      expect(convertPathParamToGoParam(path), equals('/home/:room'));
    });

    test('one param with dollar sign ', () async {
      final path = r'/home/$ro$om/desk';
      expect(convertPathParamToGoParam(path), equals(r'/home/:ro$om/desk'));
    });

    test(r'/home/room/$id/desk', () async {
      final path = r'/home/room/$id/desk';
      expect(
        convertPathParamToGoParam(path),
        equals(r'/home/room/:id/desk'),
      );
    });
    test(r'/home/room/$id.$desk', () async {
      final path = r'/home/room/$id/$desk';
      expect(
        convertPathParamToGoParam(path),
        equals(r'/home/room/:id/:desk'),
      );
    });
  });
}
