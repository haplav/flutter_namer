import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:english_words/english_words.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class WordPairStorage {
  WordPairStorage(this._filename);

  String _filename;

  String get filename => _filename;

  Future<String> get localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get localFile async {
    final path = await localPath;
    return File('$path/$_filename');
  }

  Future<File> save(Iterable<WordPair> wordPairs, Set<WordPair> deleted) async {
    final contents = wordPairs
        .map((pair) => "${pair.first} ${pair.second}${deleted.contains(pair) ? ' *' : ''}")
        .join('\n');
    final file = await localFile;
    file.writeAsString(contents);
    return file;
  }

  Future<(List<WordPair>, Set<WordPair>)> load() async {
    final path = await localPath;
    final file = File('$path/$_filename');
    final List<WordPair> list = <WordPair>[];
    final Set<WordPair> deleted = <WordPair>{};
    if (await file.exists()) {
      final contents = await file.readAsString();
      final lines = contents.split('\n');
      for (final line in lines) {
        final words = line.split(' ');
        final pair = WordPair(words[0], words[1]);
        list.add(pair);
        if (words.length > 2 && words[2] == '*') {
          deleted.add(pair);
        }
      }
    }
    return (list, deleted);
  }
}

class MyAppState extends ChangeNotifier {
  MyAppState() : _current = _newPair() {
    loadFavorites();
    _autosaveTimer = Timer.periodic(autosaveInterval, (_) => saveFavoritesIfChanged());
  }

  @override
  void dispose() {
    print("MyAppState disposed");
    _autosaveTimer.cancel();
    super.dispose();
  }

  @override
  void notifyListeners() {
    _hasChanged = true;
    super.notifyListeners();
  }

  WordPair _current;
  bool _hasChanged = false;
  final _history = <WordPair>[];
  final _favorites = <WordPair>{};
  final _deletedFavorites = <WordPair>{};
  final _favoritesStorage = WordPairStorage('favorites.txt');
  late final Timer _autosaveTimer;

  static const autosaveInterval = Duration(seconds: 5);

  WordPair get current => _current;
  WordPair? get previous => _history.isNotEmpty ? _history.last : null;
  UnmodifiableListView<WordPair> get history => UnmodifiableListView(_history);
  UnmodifiableSetView<WordPair> get favorites => UnmodifiableSetView(_favorites);
  UnmodifiableSetView<WordPair> get deletedFavorites => UnmodifiableSetView(_deletedFavorites);
  int get actualFavoritesCount => _favorites.length - _deletedFavorites.length;

  static WordPair _newPair() {
    return WordPair.random();
  }

  void next() {
    _history.insert(0, _current);
    _current = _newPair();
    notifyListeners();
  }

  void saveFavorites() {
    _favoritesStorage.save(_favorites, _deletedFavorites).then((file) => print("Saved favorites to $file"));
    _hasChanged = false;
  }

  void saveFavoritesIfChanged() {
    if (_hasChanged) {
      saveFavorites();
    }
  }

  void loadFavorites() {
    _favoritesStorage.load().then(
      (tuple) {
        final list = tuple.$1;
        final deleted = tuple.$2;
        _favorites.clear();
        _favorites.addAll(list);
        _deletedFavorites.clear();
        _deletedFavorites.addAll(deleted);
        notifyListeners();
        print("Loaded favorites from file ${_favoritesStorage.filename}");
      },
      onError: (error) => print('Failed to load favorites: $error'),
    );
    notifyListeners();
  }

  void toggleFavorite([WordPair? wp]) {
    wp ??= current;
    if (isFavorite(wp)) {
      _favorites.remove(wp);
      print("Permanently removed ${wp.asPascalCase} from favorites");
    } else {
      _favorites.add(wp);
      print("Permanently added ${wp.asPascalCase} to favorites");
    }
    _deletedFavorites.remove(wp);
    notifyListeners();
  }

  void toggleFavoriteTemporarily([WordPair? wp]) {
    wp ??= current;
    if (isInGeneratorPage(wp)) {
      toggleFavorite(wp);
      return;
    }
    if (_deletedFavorites.contains(wp)) {
      _deletedFavorites.remove(wp);
      print("${wp.asPascalCase} added back to favorites");
    } else {
      if (_favorites.contains(wp)) {
        _deletedFavorites.add(wp);
        print("${wp.asPascalCase} temporarily removed from favorites");
      }
    }
    notifyListeners();
  }

  bool isInGeneratorPage(WordPair wp) => wp == current || _history.contains(wp);

  bool isDeleted(WordPair wp) => _deletedFavorites.contains(wp);

  bool isFavorite([WordPair? wp]) {
    wp ??= current;
    return _favorites.contains(wp) && !isDeleted(wp);
  }

  // Permanently removes favorites that have been deleted temporarily and returns their number
  int pruneFavorites() {
    int count = _deletedFavorites.length;
    _favorites.removeAll(_deletedFavorites);
    saveFavorites();
    _deletedFavorites.clear();
    print("Pruned $count favorites");
    notifyListeners();
    return count;
  }

  void restoreFavorites() {
    print("Restored ${_deletedFavorites.length} favorites");
    _deletedFavorites.clear();
    saveFavorites();
    notifyListeners();
  }

  void deleteAllFavorites() {
    _deletedFavorites.addAll(_favorites);
    saveFavorites();
    notifyListeners();
  }
}
