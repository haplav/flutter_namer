import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'favorites_page.dart';
import 'generator_page.dart';
import 'state.dart';

void main() {
  runApp(const MyApp());
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

class MyHomePage extends StatefulWidget {
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
    final state = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;

    final pages = [
      (page: GeneratorPage(), icon: Icons.home, title: 'Home'),
      (page: FavoritesPage(favorites: state.favorites), icon: Icons.favorite, title: 'Favorites'),
    ];

    final mainArea = Container(
      color: theme.colorScheme.primaryContainer,
      child: PageView(
        controller: _pageController,
        onPageChanged: _setPage,
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
          SafeArea(child: buildBottomNav(pages)),
        ],
      );
    } else {
      return Row(
        children: [
          SafeArea(child: buildSideNav(pages, extended: width > 600)),
          Expanded(child: mainArea),
        ],
      );
    }
  }

  NavigationRail buildSideNav(List<PageConfig> pages, {required bool extended}) {
    return NavigationRail(
      extended: extended,
      minExtendedWidth: 175,
      onDestinationSelected: _animateToPage,
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

  BottomNavigationBar buildBottomNav(List<PageConfig> pages) {
    return BottomNavigationBar(
      onTap: _animateToPage,
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

  void _setPage(int index) {
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
