import "dart:collection";
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'favorites_page.dart';
import 'generator_page.dart';
import 'state.dart';

void main() {
  runApp(const MyApp());
}

enum PageType {
  generator,
  favorites,
}

typedef PageConfig = ({
  String title,
  IconData icon,
});

const Map<PageType, PageConfig> pagesSpec = {
  PageType.generator: (
    title: 'Generator',
    icon: Icons.home,
  ),
  PageType.favorites: (
    title: 'Favorites',
    icon: Icons.favorite,
  ),
};

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
          body: Builder(builder: (context) {
            return MyHomePage(Provider.of<MyAppState>(context, listen: false));
          }),
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

class MyHomePage extends StatefulWidget {
  MyHomePage(
    this.appState, {
    super.key,
  }) {
    _pages[PageType.generator] = GeneratorPage();
    _pages[PageType.favorites] = FavoritesPage(
      key: _favoritesPageStateKey,
      favorites: appState.favorites,
    );
  }

  final GlobalKey _favoritesPageStateKey = GlobalKey<FavoritesPageState>();
  final MyAppState appState;
  final Map<PageType, Widget> _pages = {};

  UnmodifiableMapView<PageType, Widget> get pages => UnmodifiableMapView(_pages);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late PageController _pageController;
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: _pageIndex,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = widget.pages;
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final mainArea = Container(
      color: theme.colorScheme.primaryContainer,
      child: PageView(
        controller: _pageController,
        onPageChanged: _setPage,
        children: pages.values.toList(),
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
      onDestinationSelected: _animateToPage,
      selectedIndex: _pageIndex,
      destinations: pagesSpec.values
          .map(
            (p) => NavigationRailDestination(
              icon: _pageToIcon(p),
              label: Text(p.title),
            ),
          )
          .toList(),
    );
  }

  BottomNavigationBar buildBottomNav() {
    return BottomNavigationBar(
      onTap: _animateToPage,
      currentIndex: _pageIndex,
      items: pagesSpec.values
          .map(
            (p) => BottomNavigationBarItem(
              icon: _pageToIcon(p),
              label: p.title,
            ),
          )
          .toList(),
    );
  }

  void _setPage(int index) {
    // save changes when leaving the favorites page
    if (PageType.values[_pageIndex] == PageType.favorites) {
      final state = widget._favoritesPageStateKey.currentState as FavoritesPageState;
      print("deleting: ${state.deleted}");
      widget.appState.deleteFavorites(state.deleted);
    }
    setState(() {
      print('_MyHomePageState: selected $index');
      _pageIndex = index;
    });
  }

  void _animateToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
    );
    // no need to call _setPage as it's already called by the PageView
  }

  static Tooltip _pageToIcon(PageConfig e) => Tooltip(
        message: e.title,
        child: Icon(e.icon),
      );
}
