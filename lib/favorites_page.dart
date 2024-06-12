import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter_namer/commons.dart';
import 'package:flutter_namer/favorites_ui.dart';
import 'package:flutter_namer/state.dart';
import 'package:provider/provider.dart';

class FavoritesPage extends StatelessWidget {
  static const double spacing = 15.0;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    final theme = Theme.of(context);

    FavoriteTile favoriteTile(WordPair wp) {
      return FavoriteTile(
        wordPair: wp,
        leadingIcon: (
          icon: !appState.isDeleted(wp) ? Icons.favorite : Icons.favorite_border,
          message: "Toggle favorite",
          onPressed: () => appState.toggleFavoriteTemporarily(wp),
        ),
        theme: theme,
      );
    }

    RichText message() {
      var nFavorites = appState.actualFavoritesCount;
      var nDeleted = appState.deletedFavorites.length;
      return RichText(
        text: TextSpan(
          style: theme.textTheme.bodyLarge,
          children: [
            TextSpan(text: 'You have '),
            TextSpan(
              text: '$nFavorites ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: 'favorites and '),
            TextSpan(
              text: '$nDeleted ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: 'are in the bin. '),
            if (nFavorites > 0 || nDeleted > 0) ...[
              TextSpan(text: 'You can '),
              HyperlinkSpan(
                text: 'delete all',
                theme: theme,
                onTap: appState.deleteAllFavorites,
              ),
              TextSpan(text: ' or '),
              HyperlinkSpan(
                text: 'restore all',
                theme: theme,
                onTap: appState.restoreFavorites,
              ),
              TextSpan(text: ' your favorites at once.'),
            ]
          ],
        ),
      );
    }

    final List<FavoriteTile> favoritesUI = appState.favorites
        .map(
          (e) => favoriteTile(e),
        )
        .toList()
        .reversed
        .toList(growable: false);

    return FavoritesGrid(
      favoritesUI: favoritesUI,
      message: message(),
    );
  }
}
