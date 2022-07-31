import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class DeckStorage {
  static const filename = "deck";

  // TODO: WIP
  Future<List<String>> findAll() async {
    final file = await _getFile();

    if (await file.exists()) {
      return (jsonDecode(await file.readAsString()) as List)
          .map((value) => value.toString())
          .toList();
    }
    return [];
  }

  Future<void> save(String word) async {
    final file = await _getFile();

    List<String> wordList = [];
    if (await file.exists()) {
      wordList = (jsonDecode(await file.readAsString()) as List)
          .map((value) => value.toString())
          .toList();
    }

    wordList.add(word);

    await file.writeAsString(json.encode(wordList));
  }

  Future<File> _getFile() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    return File('${appDocDir.path}/$filename.json');
  }
}
