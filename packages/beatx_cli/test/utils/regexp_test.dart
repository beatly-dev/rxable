import 'package:beatx_cli/src/utils/regexp.dart';
import 'package:test/test.dart';

main() {
  group('RegExp to catch path parameter', () {
    test('on no params', () async {
      final path = '/home';
      expect(pathParamRegExp.hasMatch(path), isFalse);
    });
    test('on one param', () async {
      final path = r'/$home';
      expect(pathParamRegExp.hasMatch(path), isTrue);
    });
    test('on two params', () async {
      final path = r'/$home/$room';
      expect(pathParamRegExp.hasMatch(path), isTrue);
      expect(pathParamRegExp.allMatches(path).length, equals(2));
    });
    test('on one param with \$ sign ', () async {
      final path = r'/home/$ro$om/desk';
      expect(pathParamRegExp.hasMatch(path), isTrue);
      expect(pathParamRegExp.allMatches(path).length, equals(1));
    });
    test('on a param between path', () async {
      final path = r'/home/$room/desk';
      expect(pathParamRegExp.hasMatch(path), isTrue);
      expect(pathParamRegExp.allMatches(path).length, equals(1));
    });
  });
}
