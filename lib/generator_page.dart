import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter_namer/state.dart';
import 'package:provider/provider.dart';

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(flex: 3, child: History()),
        SizedBox(height: 10),
        FittedBox(child: BigWordPairCard(appState.current)),
        SizedBox(height: 10),
        FittedBox(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: appState.toggleFavorite,
                label: const Text("Like"),
                icon: Icon(appState.isFavorite() ? Icons.favorite : Icons.favorite_border),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: appState.next,
                icon: Icon(Icons.skip_next_rounded),
                label: const Text('Next Idea'),
              ),
              const SizedBox(width: 10),
              Tooltip(
                message: "Purge the history of word pairs above",
                child: ElevatedButton.icon(
                  onPressed: appState.purgeHistory,
                  icon: Icon(Icons.delete),
                  label: const Text('Purge'),
                ),
              ),
            ],
          ),
        ),
        Expanded(child: SizedBox())
      ],
    );
  }
}

class BigWordPairCard extends StatelessWidget {
  const BigWordPairCard(
    this.wordPair, {
    super.key,
  });

  final WordPair wordPair;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = _theme(context);
    return Theme(
      data: theme,
      child: Tooltip(
        message: "Just a random word pair idea!",
        child: Card(
          color: theme.colorScheme.primary,
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: SelectableText(
              wordPair.asPascalCase,
              style: theme.textTheme.displaySmall,
              enableInteractiveSelection: true,
            ),
          ),
        ),
      ),
    );
  }

  ThemeData _theme(BuildContext context) {
    final orig = Theme.of(context);
    return orig.copyWith(
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: orig.colorScheme.inversePrimary,
        selectionHandleColor: orig.colorScheme.onPrimary,
      ),
      textTheme: orig.primaryTextTheme.copyWith(
        displaySmall: orig.primaryTextTheme.displaySmall?.copyWith(
          letterSpacing: 2,
        ),
      ),
    );
  }
}

class History extends StatelessWidget {
  History({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    List<WordPair> history = appState.history;
    final TextStyle? textStyle = Theme.of(context).textTheme.bodyMedium;

    // nested function
    TextButton historyItemButton(WordPair wp) {
      return TextButton.icon(
        onPressed: () => appState.toggleFavorite(wp),
        icon: Icon(
          appState.isFavorite(wp) ? Icons.favorite : Icons.favorite_border,
          size: textStyle?.fontSize ?? 15,
        ),
        label: Text(
          wp.asPascalCase,
          style: textStyle,
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(top: 50),
      reverse: true,
      prototypeItem: historyItemButton(appState.current),
      itemCount: history.length,
      itemBuilder: (context, index) {
        return Center(
          child: historyItemButton(history[index]),
        );
      },
    );
  }
}
