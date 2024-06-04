import 'dart:async';
import 'package:english_words/english_words.dart';

import 'storage_impl/none.dart'
    if (dart.library.io) 'storage_impl/path_provider.dart'
    if (dart.library.html) 'storage_impl/web.dart';

abstract class WordPairStorage {
  Future<void> save(Iterable<WordPair> wordPairs, Set<WordPair> deleted);

  Future<(List<WordPair>, Set<WordPair>)> load();

  factory WordPairStorage(String name) => getWordPairStorageImpl(name);

  static List<String> pairsToStrings(Iterable<WordPair> list, Set<WordPair> deleted) {
    var strings = list.map((pair) {
      return "${pair.first} ${pair.second}${deleted.contains(pair) ? ' *' : ''}";
    });
    return strings.toList();
  }

  static (List<WordPair>, Set<WordPair>) stringsToPairs(Iterable<String> strings) {
    List<WordPair> pairs = <WordPair>[];
    Set<WordPair> deleted = <WordPair>{};
    for (final string in strings) {
      final words = string.split(' ');
      final pair = WordPair(words[0], words[1]);
      pairs.add(pair);
      if (words.length > 2 && words[2] == '*') {
        deleted.add(pair);
      }
    }
    return (pairs, deleted);
  }
}
