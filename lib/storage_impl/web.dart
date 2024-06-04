import 'dart:async';
import 'package:english_words/english_words.dart';

import '../commons.dart';
import '../storage.dart';

WordPairStorage getWordPairStorageImpl(String name) => WebWordPairStorage(name);

class WebWordPairStorage implements WordPairStorage {
  WebWordPairStorage(String name) {
    log.i("Created WebWordPairStorage for $name");
  }

  @override
  Future<void> save(Iterable<WordPair> wordPairs, Set<WordPair> deleted) async {
    throw UnimplementedError("WebWordPairStorage not yet implemented");
  }

  @override
  Future<(List<WordPair>, Set<WordPair>)> load() async {
    throw UnimplementedError("WebWordPairStorage not yet implemented");
  }
}
