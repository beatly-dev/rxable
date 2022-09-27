import 'package:beat_rx/beat_rx.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

final counter = RxFamily(
  (int start) => start,
  autoDispose: true,
  onDispose: (lastValue) {
    print("last value: $lastValue");
  },
);

class _MyHomePageState extends State<MyHomePage> {
  final _fromZero = counter(0);
  final _fromOne = counter(1);
  final _fromTwo = counter(2);
  @override
  Widget build(BuildContext context) {
    context.bind([_fromZero, _fromOne]);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_fromZero',
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              '$_fromOne',
              style: Theme.of(context).textTheme.headline4,
            ),
            Builder(
                key: const ValueKey("FROMTWO"),
                builder: (context) {
                  return Text(
                    '${_fromTwo.bind(context)}',
                    style: Theme.of(context).textTheme.headline4,
                  );
                }),
            TextButton(
              onPressed: () {
                _fromZero.value++;
              },
              child: const Text("Increase fromZero"),
            ),
            TextButton(
              onPressed: () {
                _fromOne.value++;
              },
              child: const Text("Increase fromOne"),
            ),
            TextButton(
              onPressed: () {
                _fromTwo.value++;
              },
              child: const Text("Increase fromTwo"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (_) => const MyWidget(),
                ));
              },
              child: const Text("Dispose counter"),
            ),
          ],
        ),
      ),
    );
  }
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          child: const Text("go back"),
          onPressed: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (_) => const MyHomePage(title: "Flutter Demo Home Page"),
            ));
          },
        ),
      ),
    );
  }
}
