import 'dart:async';

import 'package:beat_rx/beat_rx.dart';
import 'package:flutter/material.dart';
import 'package:rx/dummy.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

final _counter = 0.rx(
    autoDispose: true,
    onDispose: (lastValue) {
      print("Dispose counter 1 - last was $lastValue");
    });
final _counter2 = 1.rx();
final _counterFamily =
    ((mult) => mult * _counter.value).rxFamily(autoDispose: true);
final _computed = Rx(() {
  return _counter.value * 2 + _counter2.value;
});

Future<int> tester() async {
  final dep = _counter2.value;
  await Future.delayed(const Duration(seconds: 1));
  return dep;
}

final _future = tester().rx();
final _async = tester.rx();

class _MyHomePageState extends State<MyHomePage> {
  final _myDouble = _counterFamily(2);
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    print("Rebuild entire");
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text('counter1 ${_counter.bind(context)} '),
            (() => Text(
                  'counter2 $_counter2 ',
                )).observe,
            (() {
              return Text(
                'doubled counter1 ${_myDouble.value}',
              );
            }).observe,
            (() => Text(
                  'mixed counter1 and counter2 ${_computed.value}',
                )).observe,
            (() => _future.map(
                  completed: (result) {
                    return Text('Future is $result');
                  },
                  orElse: () {
                    return const Text(' Future is loading...');
                  },
                )).observe,
            (() => _async.map(
                  completed: (result) {
                    return Text('Reactive Future is $result');
                  },
                  orElse: () {
                    return const Text('Reactive Future is loading...');
                  },
                )).observe,
            CustomObserver(counter: _counter),
            ReactiveBuilder(builder: (_) {
              return Text(
                'counter1 ${_counter.value}',
              );
            })
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
              onPressed: () => _counter.value++, child: const Text('count1')),
          TextButton(
              onPressed: () => _counter2.value++, child: const Text('count2')),
          TextButton(
              onPressed: () => _myDouble.value++,
              child: const Text('increase my double')),
          TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) {
                    return const Dummy();
                  }),
                );
              },
              child: const Text('replace')),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class CustomObserver extends StatelessWidget with StatelessReactiveMixin {
  const CustomObserver({
    required this.counter,
    super.key,
  });
  final Rx<int> counter;
  @override
  Widget build(BuildContext context) {
    return Text("You clicked the button $counter times");
  }
}
