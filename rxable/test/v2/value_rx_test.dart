import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';
import 'package:rxable/src/v2/value_rx.dart';

main() {
  group('ValueRx ', () {
    _Test().startFromTheBuilder();
  });
}

class _Test {
  final widgetKey = GlobalKey();
  final counterRx = ValueRx(() => 0);
  late final rootWidget = Container(
    key: widgetKey,
    child: Text('${counterRx.value}'),
  );

  _init(WidgetTester tester) async {
    await tester.pumpWidget(rootWidget);
    counterRx.bind(widgetKey.currentContext);
  }

  @isTest
  startFromTheBuilder() {
    testWidgets('starts with the builders return value', (tester) async {
      _init(tester);
    });
  }

  shouldMarkElementDirtyWhenValueIsChanged() {
    testWidgets(
      'should mark element dirty when value is changed',
      (tester) async {
        _init(tester);
      },
    );
  }
}
