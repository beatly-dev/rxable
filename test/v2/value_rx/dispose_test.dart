import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rxable/src/v2/value_rx.dart';

Future main() async {
  group('ValueRx with autoDispose true', () {
    testWidgets('should dispose value', (tester) async {
      final t = _Test();
      await t.init(tester);
      t.counterRx.value++;
      expect(t.counterRx.hasElements, isTrue);
      await tester.pumpWidget(Container());
      expect(t.counterRx.value, equals(0));
    });
  });
  group('Compounded ValueRx with autoDispose true', () {
    testWidgets('should dispose value', (tester) async {
      final counterDisposed = <int>[];
      final counterRx = _CounterRx(
        tester,
        onDispose: (lastValue) => counterDisposed.add(lastValue),
      );

      final doubledDisposed = <int>[];
      final doubledRx = ValueRx(
        () => counterRx.value * 2,
        autoDispose: true,
        onDispose: (int lastValue) => doubledDisposed.add(lastValue),
      );
      final key = GlobalKey();
      final rootWidget = MaterialApp(
        home: Builder(
          key: key,
          builder: (context) {
            doubledRx.bind(context);
            return Text('Counter $doubledRx');
          },
        ),
      );
      await tester.pumpWidget(rootWidget);
      counterRx.value++;
      await tester.pumpAndSettle();
      await tester.pumpWidget(Container());
      expect(counterDisposed, hasLength(1));
      expect(counterDisposed[0], equals(1));
      expect(doubledDisposed, hasLength(1));
      expect(doubledDisposed[0], equals(2));
    });
  });
}

class _CounterRx extends ValueRx<int> {
  _CounterRx(
    this.tester, {
    super.onDispose,
  }) : super(() => 0, autoDispose: true);
  final WidgetTester tester;

  @override
  int get value {
    final val = super.value;
    return val;
  }
}

class _Test {
  final counterRx = ValueRx(() => 0, autoDispose: true);
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
