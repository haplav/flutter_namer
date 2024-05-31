import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'bin_page.dart';
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
  int? iconOverlayNumber,
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
    final appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;

    final List<PageConfig> pages = [
      (
        page: GeneratorPage(),
        icon: Icons.home,
        title: 'Home',
        iconOverlayNumber: appState.history.length,
      ),
      (
        page: FavoritesPage(),
        icon: Icons.favorite,
        title: 'Favorites',
        iconOverlayNumber: appState.actualFavoritesCount
      ),
      (
        page: BinPage(),
        icon: Icons.delete_forever,
        title: 'Bin',
        iconOverlayNumber: appState.deletedFavorites.length,
      ),
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
          SafeArea(child: _buildBottomNav(pages, theme: theme)),
        ],
      );
    } else {
      return Row(
        children: [
          SafeArea(child: _buildSideNav(pages, theme: theme, extended: width > 600)),
          Expanded(child: mainArea),
        ],
      );
    }
  }

  NavigationRail _buildSideNav(
    List<PageConfig> pages, {
    required ThemeData theme,
    required bool extended,
  }) {
    return NavigationRail(
      extended: extended,
      minExtendedWidth: 175,
      selectedLabelTextStyle: TextStyle(
        color: theme.primaryColor,
      ),
      unselectedLabelTextStyle: TextStyle(
        color: theme.colorScheme.onSurface,
      ),
      onDestinationSelected: _animateToPage,
      selectedIndex: _pageIndex,
      destinations: pagesToDestinations(
        pages,
        (p) => NavigationRailDestination(
          icon: _pageToIcon(p, theme),
          label: Text(p.title),
        ),
      ),
    );
  }

  BottomNavigationBar _buildBottomNav(
    List<PageConfig> pages, {
    required ThemeData theme,
  }) {
    return BottomNavigationBar(
      onTap: _animateToPage,
      currentIndex: _pageIndex,
      items: pagesToDestinations(
        pages,
        (p) => BottomNavigationBarItem(
          icon: _pageToIcon(p, theme),
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

  static Tooltip _pageToIcon(PageConfig p, ThemeData theme) {
    return Tooltip(
      message: p.title,
      child: Stack(
        alignment: Alignment.topRight,
        clipBehavior: Clip.none,
        children: [
          Icon(
            p.icon,
            size: 30,
          ),
          if (p.iconOverlayNumber != null)
            Positioned(
              top: -4,
              right: -8,
              child: Opacity(
                opacity: 0.825,
                child: Container(
                  constraints: BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  padding: EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.inversePrimary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    p.iconOverlayNumber.toString(),
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
