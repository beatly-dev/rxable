import 'package:beatx_annotations/beatx_annotations.dart';
import 'package:flutter/material.dart';

@XRoute()
class DetailsScreen extends StatelessWidget {
  const DetailsScreen({@Ignore() super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Hello World!')),
    );
  }
}
