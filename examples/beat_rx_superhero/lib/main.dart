import 'package:beat_rx/beat_rx.dart';
import 'package:beat_rx_superhero/service/superhero.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scroll Pagination with beat_rx',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: const SuperheroList(),
    );
  }
}

class SuperheroList extends StatefulWidget with StatefulReactiveMixin {
  const SuperheroList({
    Key? key,
  }) : super(key: key);

  @override
  State<SuperheroList> createState() => _SuperheroListState();
}

final _superHeroFamily = ((int id) => Superhero.fromId(id)).rxFamily();

class _SuperheroListState extends State<SuperheroList> {
  var length = -1;
  @override
  Widget build(BuildContext context) {
    return ListView.custom(
      childrenDelegate: SliverChildBuilderDelegate(
        (_, index) {
          if (length != -1 && index >= length) {
            return null;
          }
          final id = index + 1;
          final hero = _superHeroFamily(id).bind(context);
          return hero.map(
            completed: (hero) {
              return Text(hero.name);
            },
            error: (error) {
              length = index;
              return null;
            },
            orElse: () {
              return const Center(child: CircularProgressIndicator());
            },
          );
        },
      ),
    );
  }
}
