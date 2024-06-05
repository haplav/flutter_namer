import 'dart:async';
import 'dart:io';
import 'package:english_words/english_words.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import '../commons.dart';
import '../storage.dart';

WordPairStorage getWordPairStorageImpl(String name) => PathProviderWordPairStorage(name);

class PathProviderWordPairStorage with Messaging implements WordPairStorage {
  PathProviderWordPairStorage(String name) {
    _file = _createFileIfNotExists('$name.txt');
    _file.then((file) => log.i('PathProviderWordPairStorage is ready for\n$file'));
  }

  late final Future<File> _file;

  Future<File> _createFileIfNotExists(String filename) async {
    final dir = await path_provider.getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/$filename';
    var f = File(filePath);
    if (!await f.exists()) {
      f = await f.create();
      message('Created new data file\n${f.path}');
    }
    assert(await f.exists());
    return f;
  }

  @override
  Future<void> save(Iterable<WordPair> list, Set<WordPair> deleted) async {
    final f = await _file;
    final contents = WordPairStorage.pairsToStrings(list, deleted).join('\n');
    f.writeAsString(contents);
    message(
      'Saved ${list.length} word pairs including ${deleted.length} deleted to\n${f.path}',
      replace: true,
    );
  }

  @override
  Future<(List<WordPair>, Set<WordPair>)> load() async {
    final f = await _file;
    if (!await f.exists()) {
      log.e("$f does not exist");
      return (<WordPair>[], <WordPair>{});
    }
    final contents = await f.readAsString();
    final lines = contents.split('\n');
    final (list, deleted) = WordPairStorage.stringsToPairs(lines);
    if (list.isNotEmpty) {
      message('Loaded ${list.length} word pairs including ${deleted.length} deleted from\n${f.path}');
    }
    return (list, deleted);
  }
}
