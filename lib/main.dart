import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_namer/favorites_page.dart';
import 'package:flutter_namer/generator_page.dart';
import 'package:flutter_namer/state.dart';

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
