import 'package:english_words/english_words.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_namer/state.dart';
import 'package:provider/provider.dart';

class FavoritesPage extends StatelessWidget {
  static const double spacing = 15.0;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MyAppState>();
    final theme = Theme.of(context);

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(spacing),
              child: _message(theme, state),
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
          TextSpan(text: " so they disappear for good. Finally, you can "),
          HyperlinkSpan(
            text: 'save your current state to a file',
            theme: theme,
            onTap: state.saveFavorites,
          ),
          TextSpan(text: '.'),
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

class HyperlinkSpan extends TextSpan {
  HyperlinkSpan({
    required super.text,
    required ThemeData theme,
    required VoidCallback onTap,
  }) : super(
          recognizer: TapGestureRecognizer()..onTap = onTap,
          style: TextStyle(
            color: theme.primaryColor,
            decoration: TextDecoration.underline,
            decorationColor: theme.primaryColor,
            fontWeight: FontWeight.w500,
          ),
        );
}
