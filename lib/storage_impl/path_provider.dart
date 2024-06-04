import 'dart:async';
import 'dart:io';
import 'package:english_words/english_words.dart';
import 'package:path_provider/path_provider.dart';

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
