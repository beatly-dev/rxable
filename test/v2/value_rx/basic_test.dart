import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rxable/src/v2/value_rx.dart';

Future main() async {
  group('ValueRx', () {
    testWidgets('starts with the builders return value', (tester) async {
      final t = _Test();
      await t.init(tester);
      expect(t.counterRx.value, 0);
      expect(find.text('Counter 0'), findsOneWidget);
    });
    testWidgets('should change the widget', (tester) async {
      final t = _Test();
      await t.init(tester);
      t.counterRx.value++;
      await tester.pumpAndSettle();
      expect(t.counterRx.value, 1);
      expect(find.text('Counter 1'), findsOneWidget);
    });
    testWidgets(
      'should not change the widget with same value',
      (tester) async {
        final t = _Test();
        await t.init(tester);
        t.counterRx.value = t.counterRx.value;
        expect(tester.element(find.byKey(t.key)).dirty, isFalse);
      },
    );
    testWidgets(
      'should not change the widget after unbind',
      (tester) async {
        final t = _Test();
        await t.init(tester);
        t.counterRx.unbind(tester.element(find.byKey(t.key)));
        t.counterRx.value++;
        await tester.pumpAndSettle();
        expect(t.counterRx.value, 1);
        expect(find.text('Counter 1'), findsNothing);
      },
    );
    testWidgets('should remove unmounted elements', (tester) async {
      final t = _Test();
      await t.init(tester);
      expect(t.counterRx.hasElements, isTrue);
      await tester.pumpWidget(Container());
      expect(t.counterRx.hasElements, isFalse);
    });
  });
}

class _Test {
  final counterRx = ValueRx(() => 0);
  final key = GlobalKey();
  late final rootWidget = MaterialApp(
    home: Builder(
      key: key,
      builder: (context) {
        counterRx.bind(context);
        return Text('Counter $counterRx');
      },
    ),
  );
  Future init(WidgetTester tester) async {
    await tester.pumpWidget(rootWidget);
  }
}
