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

WordPair _generateWordPair() {
  return WordPair.random();
}

class MyAppState extends ChangeNotifier {
  WordPair? _previous;
  WordPair _current = _generateWordPair();

  WordPair? get previous => _previous;
  WordPair get current => _current;

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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('A random idea:'),
            BigWordPairCard(appState.current),
            SelectableText(appState.previous != null
                ? "(previously ${appState.previous})"
                : ''),
            ElevatedButton(
              onPressed: appState.next,
              child: Text('New Idea'),
            ),
          ],
        ),
      ),
    );
  }
}

class BigWordPairCard extends StatelessWidget {
  const BigWordPairCard(
    this.wordPair, {
    super.key,
  });

  final WordPair wordPair;

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
      child: Theme(
        data: theme.copyWith(
          textSelectionTheme: TextSelectionThemeData(
            selectionColor: theme.colorScheme.inversePrimary,
            selectionHandleColor: theme.colorScheme.onPrimary,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: SelectableText(
            wordPair.asCamelCase,
            style: textStyle,
            semanticsLabel: "${wordPair.first} ${wordPair.second}",
            enableInteractiveSelection: true,
          ),
        ),
      ),
    );
  }
}
