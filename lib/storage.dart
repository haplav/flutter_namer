import 'dart:async';
import 'package:english_words/english_words.dart';

import 'storage_impl/none.dart'
    if (dart.library.io) 'storage_impl/path_provider.dart'
    if (dart.library.html) 'storage_impl/web.dart';

abstract class WordPairStorage {
  Future<void> save(Iterable<WordPair> wordPairs, Set<WordPair> deleted);

  Future<(List<WordPair>, Set<WordPair>)> load();

  factory WordPairStorage(String name) => getWordPairStorageImpl(name);
}
