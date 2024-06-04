import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:english_words/english_words.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'commons.dart';

class WordPairStorage {
  WordPairStorage(this._filename);

  String _filename;
  String? _directoryPath;

  String get filename => _filename;

  Future<String> get directoryPath async {
    if (_directoryPath == null) {
      final dir = await getApplicationDocumentsDirectory();
      _directoryPath = dir.path;
    }
    return _directoryPath!;
  }

  Future<String> get filePath async {
    return '${await directoryPath}/$_filename';
  }

  Future<File> get file async {
    return File(await filePath);
  }

  Future<File> save(Iterable<WordPair> wordPairs, Set<WordPair> deleted) async {
    final contents = wordPairs
        .map((pair) => "${pair.first} ${pair.second}${deleted.contains(pair) ? ' *' : ''}")
        .join('\n');
    final f = await file;
    f.writeAsString(contents);
    return f;
  }

  Future<(List<WordPair>, Set<WordPair>)> load() async {
    final f = await file;
    final List<WordPair> list = <WordPair>[];
    final Set<WordPair> deleted = <WordPair>{};
    if (await f.exists()) {
      final contents = await f.readAsString();
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
    loadFavorites().onError((error, stackTrace) {
      log.e('Failed to load favorites: $error', stackTrace: stackTrace);
    });
  }

  @override
  void dispose() {
    log.d("MyAppState $this disposed");
    _autosaveTimer?.cancel();
    super.dispose();
  }

  void notifyListenersFavoritesChanged() {
    _autosaveTimer ??= Timer(autosaveInterval, saveFavorites);
    notifyListeners();
  }

  static const autosaveInterval = Duration(seconds: 5);

  WordPair _current;
  final _history = <WordPair>[];
  final _favorites = <WordPair>{};
  final _deletedFavorites = <WordPair>{};
  final _favoritesStorage = WordPairStorage('favorites.txt');
  Timer? _autosaveTimer;

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

  void purgeHistory() {
    _history.clear();
    notifyListeners();
  }

  Future<void> saveFavorites() async {
    _autosaveTimer?.cancel();
    _autosaveTimer = null;
    var file = await _favoritesStorage.save(_favorites, _deletedFavorites);
    log.i("Saved favorites to $file");
  }

  Future<void> loadFavorites() async {
    final tuple = await _favoritesStorage.load();
    final list = tuple.$1;
    final deleted = tuple.$2;
    _favorites.clear();
    _favorites.addAll(list);
    _deletedFavorites.clear();
    _deletedFavorites.addAll(deleted);
    notifyListeners();
    log.i("Loaded favorites from ${await _favoritesStorage.filePath}");
  }

  void toggleFavorite([WordPair? wp]) {
    wp ??= current;
    if (isFavorite(wp)) {
      _favorites.remove(wp);
      log.d("Permanently removed ${wp.asPascalCase} from favorites");
    } else {
      _favorites.add(wp);
      log.d("Permanently added ${wp.asPascalCase} to favorites");
    }
    _deletedFavorites.remove(wp);
    notifyListenersFavoritesChanged();
  }

  void toggleFavoriteTemporarily([WordPair? wp]) {
    wp ??= current;
    if (_deletedFavorites.contains(wp)) {
      _deletedFavorites.remove(wp);
      log.d("${wp.asPascalCase} added back to favorites");
    } else {
      if (_favorites.contains(wp)) {
        _deletedFavorites.add(wp);
        log.d("${wp.asPascalCase} temporarily removed from favorites");
      }
    }
    notifyListenersFavoritesChanged();
  }

  void deleteFavoritePermanently([WordPair? wp]) {
    wp ??= current;
    _favorites.remove(wp);
    _deletedFavorites.remove(wp);
    log.d("Permanently deleted ${wp.asPascalCase} from favorites");
    notifyListenersFavoritesChanged();
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
    _deletedFavorites.clear();
    log.d("Pruned $count favorites");
    notifyListenersFavoritesChanged();
    return count;
  }

  void restoreFavorites() {
    log.d("Restored ${_deletedFavorites.length} favorites");
    _deletedFavorites.clear();
    notifyListenersFavoritesChanged();
  }

  void deleteAllFavorites() {
    _deletedFavorites.addAll(_favorites);
    log.d("${_deletedFavorites.length} favorites temporarily deleted");
    notifyListenersFavoritesChanged();
  }
}
