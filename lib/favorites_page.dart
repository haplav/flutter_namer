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
      final VoidCallback onPressed;
      final IconData icon;
      final String message;
      if (appState.isInGeneratorPage(wp)) {
        icon = Icons.cancel_sharp;
        message = "Remove from favorites (still visible in Home)";
        onPressed = () => appState.toggleFavorite(wp);
      } else {
        icon = !appState.isDeleted(wp) ? Icons.favorite : Icons.favorite_border;
        message = "Toggle favorite";
        onPressed = () => appState.toggleFavoriteTemporarily(wp);
      }
      return FavoriteTile(
        icon: icon,
        iconColor: theme.primaryColor,
        message: message,
        tileTextStyle: theme.textTheme.bodyLarge,
        wordPair: wp,
        onPressed: onPressed,
      );
    }

    RichText message() {
      return RichText(
        text: TextSpan(
          style: theme.textTheme.bodyMedium,
          children: [
            TextSpan(text: 'You have '),
            TextSpan(
              text: '${appState.actualFavoritesCount} ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: 'favorites and '),
            TextSpan(
              text: '${appState.deletedFavorites.length} ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: 'temporarily deleted. '),
            TextSpan(text: 'You can '),
            HyperlinkSpan(
              text: 'delete',
              theme: theme,
              onTap: appState.deleteAllFavorites,
            ),
            TextSpan(text: ' or '),
            HyperlinkSpan(
              text: 'restore',
              theme: theme,
              onTap: appState.restoreFavorites,
            ),
            TextSpan(text: ' all your favorites at once.'),
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
