import 'dart:async';
import 'dart:collection';

import 'package:english_words/english_words.dart';
import 'package:flutter/foundation.dart';

import 'commons.dart';
import 'storage.dart';

class MyAppState extends ChangeNotifier with Messaging {
  MyAppState() : _current = _newPair() {
    loadFavorites().onError((error, stackTrace) {
      log.e('Failed to load $favoritesName: $error', stackTrace: stackTrace);
    });
    addMessenger((msg, replace) => log.d('Message: "$msg"'));
  }

  @override
  void dispose() {
    log.d("MyAppState $this disposed");
    _autosaveTimer?.cancel();
    super.dispose();
  }

  void notifyListenersFavoritesChanged() {
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(autosaveInterval, saveFavorites);
    notifyListeners();
  }

  static const favoritesName = 'favorites';
  static const autosaveInterval = Duration(seconds: 5);

  WordPair _current;
  final _history = <WordPair>[];
  final _favorites = <WordPair>{};
  final _deletedFavorites = <WordPair>{};
  final _favoritesStorage = WordPairStorage(favoritesName);
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
    _current = _newPair();
    notifyListeners();
  }

  Future<void> saveFavorites() async {
    _autosaveTimer?.cancel();
    _autosaveTimer = null;
    _favoritesStorage.save(_favorites, _deletedFavorites);
    message('Favorites saved', replace: true);
  }

  Future<void> loadFavorites() async {
    final tuple = await _favoritesStorage.load();
    final list = tuple.$1;
    final deleted = tuple.$2;
    _favorites.clear();
    _favorites.addAll(list);
    _deletedFavorites.clear();
    _deletedFavorites.addAll(deleted);
    message('Favorites loaded');
    notifyListeners();
  }

  void toggleFavorite([WordPair? wp]) {
    wp ??= current;
    if (isFavorite(wp)) {
      _favorites.remove(wp);
      log.d("Deleted ${wp.asPascalCase} from $favoritesName");
    } else {
      _favorites.add(wp);
      log.d("Added ${wp.asPascalCase} to $favoritesName");
    }
    _deletedFavorites.remove(wp);
    notifyListenersFavoritesChanged();
  }

  void toggleFavoriteTemporarily([WordPair? wp]) {
    wp ??= current;
    if (_deletedFavorites.contains(wp)) {
      _deletedFavorites.remove(wp);
      log.d("${wp.asPascalCase} added back to $favoritesName");
    } else {
      if (_favorites.contains(wp)) {
        _deletedFavorites.add(wp);
        log.d("${wp.asPascalCase} moved from $favoritesName Bin");
      }
    }
    notifyListenersFavoritesChanged();
  }

  void deleteFavoritePermanently([WordPair? wp]) {
    wp ??= current;
    _favorites.remove(wp);
    _deletedFavorites.remove(wp);
    log.d("Deleted ${wp.asPascalCase} from $favoritesName");
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
    message("Pruned $count $favoritesName");
    notifyListenersFavoritesChanged();
    return count;
  }

  void restoreFavorites() {
    message("Restored ${_deletedFavorites.length} $favoritesName from Bin");
    _deletedFavorites.clear();
    notifyListenersFavoritesChanged();
  }

  void deleteAllFavorites() {
    _deletedFavorites.addAll(_favorites);
    message("${_deletedFavorites.length} moved from $favoritesName to Bin");
    notifyListenersFavoritesChanged();
  }
}
