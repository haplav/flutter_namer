import 'dart:io';
import 'dart:math';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

bool isDesktop() {
  return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
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

class WordPairStorage {
  String _filename;

  WordPairStorage(this._filename);

  String get filename => _filename;

  Future<String> get localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get localFile async {
    final path = await localPath;
    return File('$path/$_filename');
  }

  Future<File> save(Iterable<WordPair> wordPairs) async {
    final contents = wordPairs.map((pair) => "${pair.first} ${pair.second}").join('\n');
    final file = await localFile;
    file.writeAsString(contents);
    return file;
  }

  Future<List<WordPair>> load() async {
    final path = await localPath;
    final file = File('$path/$_filename');
    List<WordPair> list = <WordPair>[];
    if (await file.exists()) {
      final contents = await file.readAsString();
      list = contents.split('\n').map((e) {
        var words = e.split(' ');
        return WordPair(words[0], words[1]);
      }).toList();
    }
    return list;
  }
}

class MyAppState extends ChangeNotifier {
  WordPair _current;
  var _history = <WordPair>[];
  var _favorites = <WordPair>{};
  var _favoritesStorage = WordPairStorage('favorites.txt');

  static WordPair _newPair() {
    return WordPair.random();
  }

  void next() {
    _history.insert(0, _current);
    _current = _newPair();
    notifyListeners();
  }

  MyAppState() : _current = _newPair() {
    // load favorites from file in the background
    _favoritesStorage.load().then(
      (list) {
        _favorites.addAll(list);
        notifyListeners();
        print("Loaded favorites from file ${_favoritesStorage.filename}");
      },
      onError: (error) => print('Failed to load favorites: $error'),
    );
    next();
  }

  WordPair get current => _current;
  WordPair? get previous => _history.isNotEmpty ? _history.last : null;
  List<WordPair> get history => _history;
  Set<WordPair> get favorites => _favorites;

  void toggleFavorite([WordPair? wp]) {
    wp ??= current;
    if (_favorites.contains(wp)) {
      _favorites.remove(wp);
    } else {
      _favorites.add(wp);
    }
    _favoritesStorage.save(_favorites).then((file) => print("Saved favorites to file: $file"));
    notifyListeners();
  }

  bool isFavorite([WordPair? wp]) {
    wp ??= current;
    return _favorites.contains(wp);
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

typedef PageConfig = ({
  Widget page,
  IconData icon,
  String title,
});

class _MyHomePageState extends State<MyHomePage> {
  final List<PageConfig> pages = [
    (page: GeneratorPage(), icon: Icons.home, title: 'Home'),
    (page: FavoritesPage(), icon: Icons.favorite, title: 'Favorites'),
  ];

  late PageController _pageController;

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = _theme(context);
    if (_selectedIndex < 0 || _selectedIndex > pages.length - 1) {
      throw UnimplementedError('no widget with index $_selectedIndex');
    }

    return Theme(
      data: theme,
      child: Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: MyNavigation(
                pages: pages,
                pageController: _pageController,
                mediaQueryData: MediaQuery.of(context),
                selectedIndex: _selectedIndex,
              ),
            ),
            Expanded(
              child: Container(
                color: theme.colorScheme.primaryContainer,
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (value) => setState(() => _selectedIndex = value),
                  children: pages.map((e) => e.page).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
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

class MyNavigation extends StatelessWidget {
  final List<PageConfig> pages;
  final PageController pageController;
  final MediaQueryData mediaQueryData;
  final int selectedIndex;

  const MyNavigation({
    super.key,
    required this.pages,
    required this.pageController,
    required this.mediaQueryData,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      destinations: pagesToDestinations(pages),
      extended: useExtended(mediaQueryData),
      minExtendedWidth: 175,
      onDestinationSelected: (index) => pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn,
      ),
      selectedIndex: selectedIndex,
    );
  }

  static bool useExtended(MediaQueryData mediaQueryData) {
    return isDesktop() && mediaQueryData.size.width > 600;
  }

  static List<NavigationRailDestination> pagesToDestinations(List<PageConfig> pages) {
    return pages
        .map((e) => NavigationRailDestination(
              icon: Tooltip(
                message: e.title,
                child: Icon(e.icon),
              ),
              label: Text(e.title),
            ))
        .toList(growable: false);
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var state = context.watch<MyAppState>();
    List<Widget> favoritesUI = [
      SafeArea(
        child: Text(
          'You now have ${state.favorites.length} favorites:',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    ];
    favoritesUI.addAll(state.favorites.map((f) => ListTile(
          leading: const Icon(Icons.favorite),
          title: SelectableText(f.asPascalCase),
          contentPadding: EdgeInsets.zero,
        )));

    return Align(
      alignment: Alignment.topLeft,
      child: SizedBox(
        width: 300,
        child: ListView(
          padding: EdgeInsets.all(10),
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
          Expanded(child: History()),
          SizedBox(height: 10),
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
              ElevatedButton.icon(
                onPressed: appState.next,
                icon: Icon(Icons.skip_next_rounded),
                label: const Text('Next Idea'),
              ),
            ],
          ),
          Expanded(child: SizedBox())
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

class History extends StatelessWidget {
  History({super.key});

  TextButton _historyItemButton(MyAppState appState, WordPair e, TextStyle? textStyle) {
    return TextButton.icon(
      onPressed: () => appState.toggleFavorite(e),
      icon: Icon(
        appState.isFavorite(e) ? Icons.favorite : Icons.favorite_border,
        size: 15,
      ),
      label: Text(
        e.asPascalCase,
        style: textStyle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    List<WordPair> history = appState.history;
    final TextStyle? textStyle = Theme.of(context).textTheme.bodySmall;

    return ListView.builder(
      padding: EdgeInsets.only(top: 50),
      reverse: true,
      prototypeItem: _historyItemButton(appState, appState.current, textStyle),
      itemCount: appState._history.length,
      itemBuilder: (context, index) {
        return Center(
          child: _historyItemButton(appState, history[index], textStyle),
        );
      },
    );
  }
}
