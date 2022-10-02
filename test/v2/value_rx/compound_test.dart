import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rxable/src/v2/value_rx.dart';

Future main() async {
  group('Compounded ValueRx', () {
    testWidgets('can be created', (tester) async {
      final test = _Test();
      await test.init(tester);
      expect(find.text('Counter 0'), findsOneWidget);
    });
    testWidgets('can modify itself', (tester) async {
      final test = _Test();
      await test.init(tester);
      test.doubledRx.value++;
      await tester.pump();
      expect(find.text('Counter 1'), findsOneWidget);
    });

    testWidgets('should have children', (tester) async {
      final test = _Test();
      await test.init(tester);
      expect(test.counterRx.hasChildren, isTrue);
    });

    testWidgets('can react to its parents', (tester) async {
      final test = _Test();
      await test.init(tester);
      test.counterRx.value++;
      await tester.pump();
      expect(find.text('Counter 2'), findsOneWidget);
    });

    testWidgets(
        'do not rebuild when the changed value by parent is same as the current',
        (tester) async {
      final test = _Test();
      await test.init(tester);
      test.doubledRx.value = 2;
      await tester.pumpAndSettle();
      expect(find.text('Counter 2'), findsOneWidget);
      test.counterRx.value++;
      expect(tester.element(find.byKey(test.key)).dirty, isFalse);
    });
  });
}

class _Test {
  final counterRx = ValueRx(() => 0);
  late final doubledRx = ValueRx(() {
    return counterRx.value * 2;
  });
  final key = GlobalKey();
  late final rootWidget = MaterialApp(
    home: Builder(
      key: key,
      builder: (context) {
        doubledRx.bind(context);
        return Text('Counter $doubledRx');
      },
    ),
  );
  Future init(WidgetTester tester) async {
    await tester.pumpWidget(rootWidget);
  }
}
