import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter_namer/state.dart';
import 'package:provider/provider.dart';

class FavoritesPage extends StatelessWidget {
  static const double spacing = 15.0;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final headlineTextStyle = theme.textTheme.headlineMedium;

    // nested function
    Widget favoriteTile(WordPair wp) {
      return FavoriteTile(
        iconColor: theme.primaryColor,
        tileTextStyle: theme.textTheme.bodyLarge,
        wordPair: wp,
        deleted: state.isDeleted(wp),
        onPressed: () => state.toggleFavoriteTemporarily(wp),
      );
    }

    final List<Widget> favoritesUI = state.favorites
        .map(
          (e) => favoriteTile(e),
        )
        .toList(growable: false);

    return Padding(
      padding: const EdgeInsets.all(spacing),
      child: Column(
        children: [
          SafeArea(
            child: Text(
              'You now have ${state.actualFavoritesCount} favorites:',
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

class FavoriteTile extends StatelessWidget {
  const FavoriteTile({
    super.key,
    required this.iconColor,
    required this.tileTextStyle,
    required this.wordPair,
    required this.deleted,
    required this.onPressed,
  });

  final Color iconColor;
  final TextStyle? tileTextStyle;
  final WordPair wordPair;
  final bool deleted;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: IconButton(
        icon: Icon(
          !deleted ? Icons.favorite : Icons.favorite_border,
          color: iconColor,
          size: tileTextStyle?.fontSize ?? 16,
        ),
        onPressed: onPressed,
      ),
      title: SelectableText(
        wordPair.asPascalCase,
        style: tileTextStyle,
      ),
      contentPadding: EdgeInsets.zero,
    );
  }
}
