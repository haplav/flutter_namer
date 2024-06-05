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
          Expanded(
            child: GridView(
              padding: EdgeInsets.zero,
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 400,
                childAspectRatio: 8,
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

typedef IconConfig = ({
  IconData icon,
  String message,
  VoidCallback? onPressed,
});

class FavoriteTile extends StatelessWidget {
  FavoriteTile({
    super.key,
    required this.wordPair,
    required this.leadingIcon,
    this.trailingIcon,
    required ThemeData theme,
  })  : iconColor = theme.primaryColor,
        tileTextStyle = theme.textTheme.bodyLarge;

  final WordPair wordPair;
  final IconConfig leadingIcon;
  final IconConfig? trailingIcon;
  final Color iconColor;
  final TextStyle? tileTextStyle;

  @override
  Widget build(BuildContext context) {
    final iconSize = (tileTextStyle?.fontSize ?? 16) * 1.4;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      titleAlignment: ListTileTitleAlignment.center,
      leading: IconButton(
        padding: EdgeInsets.all(2),
        icon: Icon(
          leadingIcon.icon,
          color: iconColor,
          size: iconSize,
        ),
        onPressed: leadingIcon.onPressed,
        tooltip: leadingIcon.message,
      ),
      title: SelectableText(
        wordPair.asPascalCase,
        style: tileTextStyle,
      ),
      trailing: trailingIcon == null
          ? null
          : IconButton(
              padding: EdgeInsets.all(2),
              icon: Icon(
                trailingIcon!.icon,
                color: iconColor,
                size: iconSize,
              ),
              onPressed: trailingIcon!.onPressed,
              tooltip: trailingIcon!.message,
            ),
    );
  }
}
