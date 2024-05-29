import 'package:flutter/material.dart';
import 'package:flutter_namer/state.dart';
import 'package:provider/provider.dart';

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
