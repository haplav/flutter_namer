import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter_namer/state.dart';
import 'package:provider/provider.dart';

class GeneratorPage extends StatelessWidget {
  final history = History();

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var buttonRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton.icon(
          onPressed: appState.toggleFavorite,
          label: const Text("Like"),
          icon: Icon(appState.isFavorite() ? Icons.favorite : Icons.favorite_border),
        ),
        const SizedBox(width: 10),
        ElevatedButton.icon(
          onPressed: () => history.next(appState),
          icon: Icon(Icons.skip_next_rounded),
          label: const Text('Next Idea'),
        ),
        const SizedBox(width: 10),
        Tooltip(
          message: "Purge the history of word pairs above",
          child: ElevatedButton.icon(
            onPressed: () => history.purge(appState),
            icon: Icon(Icons.delete),
            label: const Text('Purge'),
          ),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0, top: 15.0),
            child: SafeArea(child: history),
          ),
        ),
        FittedBox(child: BigWordPairCard(appState.current)),
        const SizedBox(height: 12),
        FittedBox(
          child: buttonRow,
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
          margin: EdgeInsets.all(0),
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: AnimatedSize(
              duration: Durations.short3,
              child: SelectableText(
                wordPair.asPascalCase,
                style: theme.textTheme.displaySmall,
                enableInteractiveSelection: true,
              ),
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
  History({
    super.key,
  }) : animatedListKey = GlobalKey<AnimatedListState>(debugLabel: 'History');

  final GlobalKey<AnimatedListState> animatedListKey;
  static const Gradient gradient = LinearGradient(
    colors: [
      Colors.transparent,
      Colors.purple, // should not be visible - use only as mask
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.4],
  );

  Widget _buildItem(BuildContext context, WordPair wp) {
    final appState = Provider.of<MyAppState>(context);
    final TextStyle? textStyle = Theme.of(context).textTheme.bodyMedium;

    return Center(
      child: TextButton.icon(
        onPressed: () => appState.toggleFavorite(wp),
        icon: Icon(
          appState.isFavorite(wp) ? Icons.favorite : Icons.favorite_border,
          size: textStyle?.fontSize ?? 15,
        ),
        label: Text(
          wp.asPascalCase,
          style: textStyle,
        ),
      ),
    );
  }

  void next(MyAppState appState) {
    appState.next();
    animatedListKey.currentState?.insertItem(0);
  }

  void purge(MyAppState appState) {
    final len = appState.history.length;
    for (int i = len - 1; i >= 0; i--) {
      WordPair wp = appState.history[i];
      animatedListKey.currentState?.removeItem(
        i,
        (context, animation) => FadeTransition(
          opacity: animation,
          child: _buildItem(context, wp),
        ),
        duration: Durations.short4 * (len - i),
      );
    }
    appState.purgeHistory();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    final history = appState.history;

    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(bounds),
      blendMode: BlendMode.dstIn,
      child: AnimatedList(
        key: animatedListKey,
        padding: EdgeInsets.only(top: 50),
        reverse: true,
        initialItemCount: history.length,
        itemBuilder: (context, index, animation) {
          return SizeTransition(
            sizeFactor: animation,
            axisAlignment: -1.0,
            child: _buildItem(context, history[index]),
          );
        },
      ),
    );
  }
}
