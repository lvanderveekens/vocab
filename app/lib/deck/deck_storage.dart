import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vocab/deck/deck.dart';
import 'package:flutter/services.dart' show rootBundle;

class DeckStorage {
  Future<void> migrate() async {
    final fileV1 = await _getFileV1();
    final fileV2 = await _getFileV1();

    if (!await fileV2.exists() && await fileV1.exists()) {
      log("Migrating deck.json to v2");
      Map<String, dynamic> json = jsonDecode(await fileV1.readAsString());
      final deck = Deck.fromJsonV1(json);
      // write as v2
      save(deck);
    }
  }

  Future<Deck> get() async {
    final fileV2 = await _getFileV2();
    if (await fileV2.exists()) {
      Map<String, dynamic> json = jsonDecode(await fileV2.readAsString());
      return Deck.fromJsonV2(json);
    } else if (kDebugMode) {
      Map<String, dynamic> json = jsonDecode(
          await rootBundle.loadString('assets/debug/initial_deck.json'));

      return Deck.fromJsonV2(json);
    }
    return Deck(cards: []);
  }

  Future<void> save(Deck deck) async {
    final file = await _getFileV2();
    await file.writeAsString(jsonEncode(deck.toJson()));
  }

  Future<File> _getFileV1() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    return File('${appDocDir.path}/deck.json');
  }

  Future<File> _getFileV2() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    return File('${appDocDir.path}/deck-v2.json');
  }
}
