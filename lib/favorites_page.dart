import 'dart:collection';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';

class FavoritesPage extends StatefulWidget {
  FavoritesPage({super.key, required this.favorites});

  static const double spacing = 15.0;
  final UnmodifiableSetView<WordPair> favorites;

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final Set<WordPair> _deleted = <WordPair>{};

  bool isDeleted(WordPair wp) {
    return _deleted.contains(wp);
  }

  void _toggleFavoriteDeleted(WordPair wp) {
    setState(() {
      if (isDeleted(wp)) {
        _deleted.remove(wp);
      } else {
        _deleted.add(wp);
      }
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final List<Widget> favoritesUI = widget.favorites
        .map(
          (e) => _favoriteTile(e, isDeleted(e), theme),
        )
        .toList(growable: false);

    return Padding(
      padding: const EdgeInsets.all(FavoritesPage.spacing),
      child: Column(
        children: [
          SafeArea(
            child: Text(
              'You now have ${_deleted.length} favorites:',
              style: theme.textTheme.headlineMedium,
            ),
          ),
          SizedBox(height: FavoritesPage.spacing),
          Expanded(
            child: GridView(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                childAspectRatio: 300 / 50,
                crossAxisSpacing: FavoritesPage.spacing,
                mainAxisSpacing: FavoritesPage.spacing,
              ),
              children: favoritesUI,
            ),
          ),
        ],
      ),
    );
  }

  Widget _favoriteTile(WordPair wp, bool deleted, ThemeData theme) {
    return FavoriteTile(
      iconColor: theme.primaryColor,
      tileTextStyle: theme.textTheme.bodyLarge,
      wordPair: wp,
      deleted: deleted,
      onPressed: () => _toggleFavoriteDeleted(wp),
    );
  }

  UnmodifiableSetView<WordPair> get deleted => UnmodifiableSetView(_deleted);
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
