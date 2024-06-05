import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter_namer/commons.dart';
import 'package:flutter_namer/favorites_ui.dart';
import 'package:flutter_namer/state.dart';
import 'package:provider/provider.dart';

class BinPage extends StatelessWidget {
  static const double spacing = 15.0;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    final theme = Theme.of(context);

    FavoriteTile favoriteTile(WordPair wp) {
      return FavoriteTile(
        icon: Icons.delete_forever,
        message: "Delete permanently",
        theme: theme,
        wordPair: wp,
        onPressed: () => appState.deleteFavoritePermanently(wp),
      );
    }

    RichText message() {
      final nDeleted = appState.deletedFavorites.length;
      return RichText(
        text: TextSpan(
          style: theme.textTheme.bodyLarge,
          children: [
            TextSpan(text: 'You have '),
            TextSpan(
              text: '$nDeleted ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: 'temporarily deleted favorites. '),
            if (nDeleted > 0) ...[
              TextSpan(text: 'You can '),
              HyperlinkSpan(
                text: 'delete them permanently',
                theme: theme,
                onTap: appState.pruneFavorites,
              ),
              TextSpan(text: " so they disappear for good."),
            ],
          ],
        ),
      );
    }

    final List<FavoriteTile> favoritesUI = appState.deletedFavorites
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
