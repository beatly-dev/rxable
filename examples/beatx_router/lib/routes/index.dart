import 'package:beatx_annotations/beatx_annotations.dart';
import 'package:flutter/material.dart';

@XRoute()
class MainScreen extends StatelessWidget {
  const MainScreen(
    this.title, {
    @Ignore() super.key,
    required this.$extra,
  });
  final String title;
  final int $extra;
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Hello World!'),
      ),
    );
  }
}
