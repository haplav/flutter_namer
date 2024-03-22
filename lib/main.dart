import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
        title: 'My Name Generator App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

String _generateWordPair() {
  return WordPair.random().asCamelCase;
}

class MyAppState extends ChangeNotifier {
  String? _previous;
  String _current = _generateWordPair();

  String? get previous => _previous;
  String get current => _current;

  void next() {
    _previous = _current;
    _current = _generateWordPair();
    notifyListeners();
    print('Got $_current');
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var msg =
        "${appState.current} ${appState.previous != null ? ' (was ${appState.previous})' : ''}";

    return Scaffold(
      body: Column(
        children: [
          Text('A random idea:'),
          SelectableText(msg),
          ElevatedButton(
            onPressed: appState.next,
            child: Text('New Idea'),
          ),
        ],
      ),
    );
  }
}
