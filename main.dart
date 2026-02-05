import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WordPair {
  final String first;
  final String second;

  WordPair(this.first, this.second);

  factory WordPair.random() {
    final words = [
      'alpha',
      'bravo',
      'charlie',
      'delta',
      'echo',
      'foxtrot',
      'golf',
      'hotel',
      'india',
      'juliet'
    ];
    final ms = DateTime.now().microsecondsSinceEpoch;
    final a = words[ms % words.length];
    final b = words[(ms >> 8) % words.length];
    return WordPair(a, b);
  }

  String get asLowerCase => '${first.toLowerCase()} ${second.toLowerCase()}';

  @override
  String toString() => '$first $second';
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      body: Column(
        children: [Text('A random idea:'), Text(appState.current.asLowerCase)],
      ),
    );
  }
}

