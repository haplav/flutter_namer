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

class MyAppState extends ChangeNotifier {
  WordPair? _current;
  var _history = <WordPair>[];
  var _favorites = <WordPair>{};

  void next() {
    if (_current != null) _history.add(_current!);
    _current = WordPair.random();
    notifyListeners();
  }

  MyAppState() {
    next();
  }

  WordPair get current => _current!;
  WordPair? get previous => _history.isNotEmpty ? _history.last : null;
  List<WordPair> get history => _history;
  Set<WordPair> get favorites => _favorites;

  void toggleFavorite() {
    if (_favorites.contains(current)) {
      _favorites.remove(current);
    } else {
      _favorites.add(current);
    }
    notifyListeners();
  }

  bool isFavorite() {
    return _favorites.contains(current);
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = _theme(context);

    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
      case 1:
        page = FavoritesPage();
      default:
        throw UnimplementedError('no widget with index $selectedIndex');
    }

    return Theme(
      data: theme,
      child: LayoutBuilder(builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  minExtendedWidth: 200,
                  destinations: [
                    NavigationRailDestination(
                      icon: const Icon(Icons.home),
                      label: const Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.favorite),
                      label: const Text('Favorites'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) => setState(() {
                    selectedIndex = value;
                  }),
                ),
              ),
              Expanded(
                child: Container(
                  color: theme.colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  ThemeData _theme(BuildContext context) {
    final orig = Theme.of(context);
    return orig.copyWith(
      textTheme: orig.textTheme.copyWith(
        bodySmall: orig.textTheme.bodySmall?.copyWith(color: orig.primaryColor),
        bodyMedium: orig.textTheme.bodyMedium?.copyWith(color: orig.primaryColor),
        bodyLarge: orig.textTheme.bodyLarge?.copyWith(color: orig.primaryColor),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var state = context.watch<MyAppState>();
    List<Widget> favoritesUI = [
      Text('You now ${state.favorites.length} favorites:', style: Theme.of(context).textTheme.bodyLarge),
    ];
    favoritesUI.addAll(state.favorites.map((f) => ListTile(
          leading: const Icon(Icons.favorite),
          title: Text(f.asPascalCase),
        )));

    return Align(
      alignment: Alignment.topLeft,
      child: SizedBox(
        width: 300,
        child: ListView(
          padding: EdgeInsets.all(20),
          children: favoritesUI,
        ),
      ),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PreviousPairLabel(appState.previous),
          BigWordPairCard(appState.current),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: appState.toggleFavorite,
                label: const Text("Like"),
                icon: Icon(appState.isFavorite() ? Icons.favorite : Icons.favorite_border),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: appState.next,
                child: const Text('New Idea'),
              ),
            ],
          ),
        ],
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
    final ThemeData theme = _theme(context);
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

  ThemeData _theme(BuildContext context) {
    final orig = Theme.of(context);
    return orig.copyWith(
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: orig.colorScheme.inversePrimary,
        selectionHandleColor: orig.colorScheme.onPrimary,
      ),
      textTheme: orig.primaryTextTheme.copyWith(
        displaySmall: orig.primaryTextTheme.displaySmall?.copyWith(
          letterSpacing: 2,
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
