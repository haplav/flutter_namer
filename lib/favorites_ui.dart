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
                maxCrossAxisExtent: 270,
                childAspectRatio: 270 / 50,
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
    required this.wordPair,
    required this.icon,
    required this.iconMessage,
    required this.iconOnPressed,
    this.trailingIcon,
    this.trailingIconMessage,
    this.trailingIconOnPressed,
    required ThemeData theme,
  })  : iconColor = theme.primaryColor,
        tileTextStyle = theme.textTheme.bodyMedium {
    assert((trailingIcon == null) == (trailingIconOnPressed == null));
  }

  final WordPair wordPair;
  final IconData icon;
  final String iconMessage;
  final VoidCallback iconOnPressed;
  final IconData? trailingIcon;
  final String? trailingIconMessage;
  final VoidCallback? trailingIconOnPressed;
  final Color iconColor;
  final TextStyle? tileTextStyle;

  @override
  Widget build(BuildContext context) {
    final iconSize = (tileTextStyle?.fontSize ?? 16) * 1.6;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      titleAlignment: ListTileTitleAlignment.center,
      leading: IconButton(
        padding: EdgeInsets.all(2),
        icon: Icon(
          icon,
          color: iconColor,
          size: iconSize,
        ),
        onPressed: iconOnPressed,
        tooltip: iconMessage,
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
                trailingIcon,
                color: iconColor,
                size: iconSize,
              ),
              onPressed: trailingIconOnPressed,
              tooltip: trailingIconMessage,
            ),
    );
  }
}
