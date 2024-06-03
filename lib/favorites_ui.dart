import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';

class FavoritesGrid extends StatelessWidget {
  const FavoritesGrid({
    super.key,
    required this.favoritesUI,
    required this.message,
  });

  static const double spacing = 15.0;

  final List<FavoriteTile> favoritesUI;
  final RichText message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(spacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(spacing),
              child: message,
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
  FavoriteTile({
    super.key,
    required this.icon,
    required this.message,
    required ThemeData theme,
    required this.wordPair,
    required this.onPressed,
  })  : iconColor = theme.primaryColor,
        tileTextStyle = theme.textTheme.bodyMedium;

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
