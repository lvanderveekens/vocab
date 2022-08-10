import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:vocab/deck/deck.dart';

class DeckStorage {
  static const filename = "deck";

  Future<Deck> get() async {
    final file = await _getFile();
    if (await file.exists()) {
      Map<String, dynamic> json = jsonDecode(await file.readAsString());
      return Deck.fromJson(json);
    }
    return Deck(cards: []);
  }

  Future<void> save(Deck deck) async {
    final file = await _getFile();
    await file.writeAsString(jsonEncode(deck.toJson()));
  }

  Future<File> _getFile() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    return File('${appDocDir.path}/$filename.json');
  }
}
