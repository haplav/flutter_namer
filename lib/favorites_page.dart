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

    // nested function
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

    final List<FavoriteTile> favoritesUI = appState.favorites
        .map(
          (e) => favoriteTile(e),
        )
        .toList()
        .reversed
        .toList(growable: false);

    return FavoritesGrid(
      favoritesUI: favoritesUI,
      message: _message(theme, appState),
    );
  }

  RichText _message(ThemeData theme, MyAppState state) {
    return RichText(
      text: TextSpan(
        style: theme.textTheme.bodyMedium,
        children: [
          TextSpan(text: 'You now have '),
          TextSpan(
            text: '${state.actualFavoritesCount} ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: 'favorites and '),
          TextSpan(
            text: '${state.deletedFavorites.length} ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: 'temporarily deleted. '),
          TextSpan(text: 'You can '),
          HyperlinkSpan(
            text: 'delete',
            theme: theme,
            onTap: state.deleteAllFavorites,
          ),
          TextSpan(text: ' or '),
          HyperlinkSpan(
            text: 'restore',
            theme: theme,
            onTap: state.restoreFavorites,
          ),
          TextSpan(text: ' all your favorites at once. Further, you can '),
          HyperlinkSpan(
            text: 'delete them permanently',
            theme: theme,
            onTap: state.pruneFavorites,
          ),
          TextSpan(text: " so they disappear for good."),
        ],
      ),
    );
  }
}
