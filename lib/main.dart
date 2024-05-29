import 'dart:collection';
import 'dart:io';

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

typedef PageConfig = ({
  Widget page,
  IconData icon,
  String title,
});

typedef PageConfigToItem<D> = D Function(PageConfig);

List<T> pagesToDestinations<T>(List<PageConfig> pages, PageConfigToItem<T> factory) {
  return pages.map((e) => factory(e)).toList(growable: false);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'My Name Generator App',
        theme: _theme(),
        home: Scaffold(
          body: MyHomePage(),
        ),
      ),
    );
  }

  ThemeData _theme() {
    var theme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrangeAccent),
    );
    var tt = theme.textTheme;
    tt = tt.apply(displayColor: theme.primaryColor);
    return theme.copyWith(textTheme: tt);
  }
}

class WordPairStorage {
  WordPairStorage(this._filename);

  String _filename;

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

  WordPair _current;
  var _history = <WordPair>[];
  var _favorites = <WordPair>{};
  var _favoritesStorage = WordPairStorage('favorites.txt');

  WordPair get current => _current;
  WordPair? get previous => _history.isNotEmpty ? _history.last : null;
  UnmodifiableListView<WordPair> get history => UnmodifiableListView(_history);
  UnmodifiableSetView<WordPair> get favorites => UnmodifiableSetView(_favorites);

  static WordPair _newPair() {
    return WordPair.random();
  }

  void next() {
    _history.insert(0, _current);
    _current = _newPair();
    notifyListeners();
  }

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

class _MyHomePageState extends State<MyHomePage> {
  final List<PageConfig> pages = [
    (page: GeneratorPage(), icon: Icons.home, title: 'Home'),
    (page: FavoritesPage(), icon: Icons.favorite, title: 'Favorites'),
  ];

  late PageController _pageController;
  int _pageIndex = 0;

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
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;

    final mainArea = Container(
      color: theme.colorScheme.primaryContainer,
      child: PageView(
        controller: _pageController,
        onPageChanged: (value) => setState(() => _pageIndex = value),
        children: pages.map((e) => e.page).toList(),
      ),
    );

    if (_pageIndex < 0 || _pageIndex > pages.length - 1) {
      throw UnimplementedError('no widget with index $_pageIndex');
    }

    if (width < 450) {
      return Column(
        children: [
          Expanded(child: mainArea),
          SafeArea(child: buildBottomNav()),
        ],
      );
    } else {
      return Row(
        children: [
          SafeArea(child: buildSideNav(extended: width > 600)),
          Expanded(child: mainArea),
        ],
      );
    }
  }

  NavigationRail buildSideNav({required bool extended}) {
    return NavigationRail(
      extended: extended,
      minExtendedWidth: 175,
      onDestinationSelected: _onSelected,
      selectedIndex: _pageIndex,
      destinations: pagesToDestinations(
        pages,
        (p) => NavigationRailDestination(
          icon: _pageToIcon(p),
          label: Text(p.title),
        ),
      ),
    );
  }

  BottomNavigationBar buildBottomNav() {
    return BottomNavigationBar(
      onTap: _onSelected,
      currentIndex: _pageIndex,
      items: pagesToDestinations(
        pages,
        (p) => BottomNavigationBarItem(
          icon: _pageToIcon(p),
          label: p.title,
        ),
      ),
    );
  }

  void _onSelected(index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
    );
  }

  static Tooltip _pageToIcon(PageConfig e) => Tooltip(
        message: e.title,
        child: Icon(e.icon),
      );
}

class FavoritesPage extends StatelessWidget {
  static const double spacing = 15.0;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final tileTextStyle = theme.textTheme.bodyLarge;
    final headlineTextStyle = theme.textTheme.headlineMedium;

    final List<Widget> favoritesUI = List.from(
      state.favorites.map(
        (f) => ListTile(
          leading: Icon(
            Icons.favorite,
            color: theme.primaryColor,
            size: tileTextStyle?.fontSize ?? 16,
          ),
          title: SelectableText(
            f.asPascalCase,
            style: tileTextStyle,
          ),
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.all(spacing),
      child: Column(
        children: [
          SafeArea(
            child: Text(
              'You now have ${state.favorites.length} favorites:',
              style: headlineTextStyle,
            ),
          ),
          SizedBox(height: spacing),
          Expanded(
            child: GridView(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                childAspectRatio: 300 / 50,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
              ),
              children: favoritesUI,
            ),
          ),
        ],
      ),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(flex: 3, child: History()),
        SizedBox(height: 10),
        FittedBox(child: BigWordPairCard(appState.current)),
        SizedBox(height: 10),
        FittedBox(
          child: Row(
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
        ),
        Expanded(child: SizedBox())
      ],
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
        size: textStyle?.fontSize ?? 15,
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
    final TextStyle? textStyle = Theme.of(context).textTheme.bodyMedium;

    return ListView.builder(
      padding: EdgeInsets.only(top: 50),
      reverse: true,
      prototypeItem: _historyItemButton(appState, appState.current, textStyle),
      itemCount: history.length,
      itemBuilder: (context, index) {
        return Center(
          child: _historyItemButton(appState, history[index], textStyle),
        );
      },
    );
  }
}
