import 'package:flutter/material.dart';
import 'package:rx/main.dart';

class Dummy extends StatelessWidget {
  const Dummy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) {
                  return const MyHomePage(title: 'come back');
                }),
              );
            },
            child: const Text('Hello World')),
      ),
    );
  }
}
