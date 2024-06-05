import 'dart:async';
import 'package:english_words/english_words.dart';

import 'commons.dart';
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
      if (string.isEmpty) {
        log.i('Skipping empty line');
        continue;
      }

      final words = string.split(' ');
      if (words.length < 2) {
        log.w('Skipping invalid line: "$string"');
        continue;
      }
      final pair = WordPair(words[0], words[1]);
      if (words.length > 2) {
        if (words[2] == '*') {
          deleted.add(pair);
        } else {
          log.w('Skipping invalid line: "$string"');
          continue;
        }
      }
      pairs.add(pair);
    }
    return (pairs, deleted);
  }
}
