import 'dart:async';
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'package:english_words/english_words.dart';

import '../commons.dart';
import '../storage.dart';

WordPairStorage getWordPairStorageImpl(String name) => WebWordPairStorage(name);

class WebWordPairStorage implements WordPairStorage {
  WebWordPairStorage(this.name) {
    log.i("Created WebWordPairStorage for $name");
  }

  final String name;

  @override
  Future<void> save(Iterable<WordPair> list, Set<WordPair> deleted) async {
    final strings = WordPairStorage.pairsToStrings(list, deleted);
    final jsonString = jsonEncode(strings);
    log.d("Saving $jsonString");
    window.localStorage[name] = jsonString;
    log.i("Saved ${list.length} word pairs to $name, of which ${deleted.length} are deleted");
  }

  @override
  Future<(List<WordPair>, Set<WordPair>)> load() async {
    String? jsonString = window.localStorage[name];
    if (jsonString == null) {
      return (<WordPair>[], <WordPair>{});
    }
    log.d("Loaded $jsonString");
    final List<dynamic> rawList = jsonDecode(jsonString);
    final strings = rawList.map((e) => e as String);
    final (list, deleted) = WordPairStorage.stringsToPairs(strings);
    log.i("Loaded ${list.length} word pairs from $name, of which ${deleted.length} are deleted");
    return (list, deleted);
  }
}
