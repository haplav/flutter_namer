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
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrangeAccent),
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

    return Scaffold(
      body: Column(
        children: [
          Text('A random idea:'),
          BigCard(appState.current),
          SelectableText(appState.previous != null
              ? "(previously ${appState.previous})"
              : ''),
          ElevatedButton(
            onPressed: appState.next,
            child: Text('New Idea'),
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard(
    this.msg, {
    super.key,
  });

  final String msg;

  TextStyle? _textStyle(ThemeData theme) {
    return theme.primaryTextTheme.displaySmall?.copyWith(
      // color: theme.colorScheme.onPrimary,
      letterSpacing: 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = _textStyle(theme);

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: SelectableText(msg, style: textStyle),
      ),
    );
  }
}
