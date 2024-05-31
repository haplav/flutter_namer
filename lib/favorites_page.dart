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
      final VoidCallback onPressed;
      final IconData icon;
      final String message;
      if (state.isInGeneratorPage(wp)) {
        icon = Icons.cancel_sharp;
        message = "Remove from favorites (still visible in Home)";
        onPressed = () => state.toggleFavorite(wp);
      } else {
        icon = !state.isDeleted(wp) ? Icons.favorite : Icons.favorite_border;
        message = "Toggle favorite";
        onPressed = () => state.toggleFavoriteTemporarily(wp);
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

    final List<Widget> favoritesUI = state.favorites
        .map(
          (e) => favoriteTile(e),
        )
        .toList()
        .reversed
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
          TextSpan(text: " so they disappear for good."),
        ],
      ),
    );
  }
}

class FavoriteTile extends StatelessWidget {
  const FavoriteTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.message,
    required this.tileTextStyle,
    required this.wordPair,
    required this.onPressed,
  });

  final IconData icon;
  final Color iconColor;
  final String message;
  final TextStyle? tileTextStyle;
  final WordPair wordPair;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: IconButton(
        icon: Icon(
          icon,
          color: iconColor,
          size: (tileTextStyle?.fontSize ?? 16) * 1.15,
        ),
        onPressed: onPressed,
        tooltip: message,
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
