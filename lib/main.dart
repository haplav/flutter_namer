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
    final ThemeData origTheme = Theme.of(context);
    final ThemeData theme = origTheme.copyWith(
        textTheme: origTheme.textTheme.copyWith(
      bodySmall: origTheme.textTheme.bodySmall?.copyWith(color: origTheme.primaryColor),
      bodyMedium: origTheme.textTheme.bodyMedium?.copyWith(color: origTheme.primaryColor),
      bodyLarge: origTheme.textTheme.bodyLarge?.copyWith(color: origTheme.primaryColor),
    ));

    return Theme(
      data: theme,
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BigWordPairCard(appState.current),
              PreviousPairLabel(appState.previous),
              ElevatedButton(
                onPressed: appState.next,
                child: Text('New Idea'),
              ),
            ],
          ),
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

  @override
  Widget build(BuildContext context) {
    final origTheme = Theme.of(context);
    final theme = origTheme.copyWith(
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: origTheme.colorScheme.inversePrimary,
        selectionHandleColor: origTheme.colorScheme.onPrimary,
      ),
      textTheme: origTheme.primaryTextTheme.copyWith(
        displaySmall: origTheme.primaryTextTheme.displaySmall?.copyWith(
          letterSpacing: 2,
        ),
      ),
    );
    return Theme(
      data: theme,
      child: Tooltip(
        message: "Just a random word pair idea!",
        child: Card(
          color: theme.colorScheme.primary,
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: SelectableText(
              wordPair.asPascalCase,
              style: theme.textTheme.displaySmall,
              semanticsLabel: "${wordPair.first} ${wordPair.second}",
              enableInteractiveSelection: true,
            ),
          ),
        ),
      ),
    );
  }
}

class PreviousPairLabel extends StatelessWidget {
  PreviousPairLabel(
    this.previous, {
    super.key,
  });

  final WordPair? previous;

  @override
  Widget build(BuildContext context) {
    final TextStyle? textStyle = Theme.of(context).textTheme.bodySmall;
    final double baseFontSize = textStyle?.fontSize ?? 14.0;
    return SizedBox(
      height: 3 * baseFontSize,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SelectableText(
            previous != null ? "(previously: ${previous!.asPascalCase})" : "",
            semanticsLabel: "${previous?.first} ${previous?.second}",
            style: textStyle,
          ),
        ],
      ),
    );
  }
}
