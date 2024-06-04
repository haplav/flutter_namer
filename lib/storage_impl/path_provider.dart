import 'dart:async';
import 'dart:io';
import 'package:english_words/english_words.dart';
import 'package:path_provider/path_provider.dart';

import '../commons.dart';
import '../storage.dart';

WordPairStorage getWordPairStorageImpl(String name) => PathProviderWordPairStorage(name);

class PathProviderWordPairStorage implements WordPairStorage {
  PathProviderWordPairStorage(String name) : _filename = '$name.txt' {
    log.i("Created PathProviderWordPairStorage for $_filename");
  }

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

  @override
  Future<void> save(Iterable<WordPair> list, Set<WordPair> deleted) async {
    final contents = WordPairStorage.pairsToStrings(list, deleted).join('\n');
    final f = await file;
    f.writeAsString(contents);
    log.i("Saved ${list.length} word pairs to $f, of which ${deleted.length} are deleted");
  }

  @override
  Future<(List<WordPair>, Set<WordPair>)> load() async {
    final f = await file;
    if (!await f.exists()) {
      log.e("$f does not exist");
      return (<WordPair>[], <WordPair>{});
    }
    final contents = await f.readAsString();
    final lines = contents.split('\n');
    final (list, deleted) = WordPairStorage.stringsToPairs(lines);
    log.i("Loaded ${list.length} word pairs and ${deleted.length} deleted word pairs from $f");
    return (list, deleted);
  }
}
