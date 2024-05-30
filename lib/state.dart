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

  Future<File> save(Iterable<WordPair> wordPairs) async {
    final contents = wordPairs.map((pair) => "${pair.first} ${pair.second}").join('\n');
    final file = await localFile;
    file.writeAsString(contents);
    return file;
  }

  Future<List<WordPair>> load() async {
    final path = await localPath;
    final file = File('$path/$_filename');
    List<WordPair> list = <WordPair>[];
    if (await file.exists()) {
      final contents = await file.readAsString();
      list = contents.split('\n').map((e) {
        var words = e.split(' ');
        return WordPair(words[0], words[1]);
      }).toList();
    }
    return list;
  }
}

class MyAppState extends ChangeNotifier {
  MyAppState() : _current = _newPair() {
    // load favorites from file in the background
    _favoritesStorage.load().then(
      (list) {
        _favorites.addAll(list);
        notifyListeners();
        print("Loaded favorites from file ${_favoritesStorage.filename}");
      },
      onError: (error) => print('Failed to load favorites: $error'),
    );
    next();
  }

  WordPair _current;
  var _history = <WordPair>[];
  var _favorites = <WordPair>{};
  var _favoritesStorage = WordPairStorage('favorites.txt');

  WordPair get current => _current;
  WordPair? get previous => _history.isNotEmpty ? _history.last : null;
  UnmodifiableListView<WordPair> get history => UnmodifiableListView(_history);
  UnmodifiableSetView<WordPair> get favorites => UnmodifiableSetView(_favorites);

  static WordPair _newPair() {
    return WordPair.random();
  }

  void next() {
    _history.insert(0, _current);
    _current = _newPair();
    notifyListeners();
  }

  void toggleFavorite([WordPair? wp]) {
    wp ??= current;
    if (_favorites.contains(wp)) {
      _favorites.remove(wp);
    } else {
      _favorites.add(wp);
    }
    _favoritesStorage.save(_favorites).then((file) => print("Saved favorites to file: $file"));
    notifyListeners();
  }

  bool isFavorite([WordPair? wp]) {
    wp ??= current;
    return _favorites.contains(wp);
  }

  void deleteFavorites(Set<WordPair> toDelete) {
    _favorites.removeAll(toDelete);
  }
}
