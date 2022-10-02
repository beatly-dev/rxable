import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rxable/src/v2/future_rx.dart';

Future main() async {
  group('FutureRx', () {
    testWidgets('can init with Future', (tester) async {
      final future = Future.value(1);
      final futureRx = FutureRx(future);
      expect(futureRx.value, equals(future));
      expect(futureRx.isLoading, isTrue);
      await tester.pumpAndSettle();
      expect(futureRx.isCompleted, isTrue);
      expect(
        futureRx.map(completed: (result) => result, orElse: () => 0),
        equals(1),
      );
    });
    testWidgets('can map future', (tester) async {
      final future = Future.value(1);
      final futureRx = FutureRx(future);
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              futureRx.bind(context);
              return futureRx.map(
                completed: (result) => Text('Completed $result'),
                orElse: () => const Text('Loading'),
              );
            },
          ),
        ),
      );
      expect(find.text('Completed 1'), findsOneWidget);
    });
    testWidgets('can rebuild widget when complete', (tester) async {
      final completer = Completer();
      final futureRx = FutureRx(completer.future);
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              futureRx.bind(context);
              return futureRx.map(
                completed: (result) => Text('Completed $result'),
                orElse: () => const Text('Loading'),
              );
            },
          ),
        ),
      );
      expect(find.text('Loading'), findsOneWidget);
      completer.complete(1);
      await tester.pumpAndSettle();
      expect(find.text('Completed 1'), findsOneWidget);
    });

    testWidgets('can rebuild widget when error', (tester) async {
      final completer = Completer();
      final futureRx = FutureRx(completer.future);
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              futureRx.bind(context);
              return futureRx.map(
                completed: (result) => Text('Completed $result'),
                error: (error) => const Text('Error'),
                orElse: () => const Text('Loading'),
              );
            },
          ),
        ),
      );
      expect(find.text('Loading'), findsOneWidget);
      completer.completeError(1);
      await tester.pumpAndSettle();
      expect(find.text('Error'), findsOneWidget);
    });

    testWidgets('can be canceled', (tester) async {
      final completer = Completer();
      final futureRx = FutureRx(completer.future);
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              futureRx.bind(context);
              return futureRx.map(
                completed: (result) => Text('Completed $result'),
                error: (error) => const Text('Error'),
                canceled: () => const Text('Canceled'),
                orElse: () => const Text('Loading'),
              );
            },
          ),
        ),
      );
      expect(find.text('Loading'), findsOneWidget);
      await futureRx.cancel();
      await tester.pumpAndSettle();
      expect(find.text('Canceled'), findsOneWidget);
    });

    testWidgets('is canceled when the widget disposed', (tester) async {
      final completer = Completer();
      final futureRx = FutureRx(completer.future, autoDispose: true);
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              futureRx.bind(context);
              return futureRx.map(
                completed: (result) => Text('Completed $result'),
                error: (error) => const Text('Error'),
                canceled: () => const Text('Canceled'),
                orElse: () => const Text('Loading'),
              );
            },
          ),
        ),
      );
      await tester.pumpWidget(Container());
      expect(futureRx.isCanceled, isTrue);
    });
  });
}
