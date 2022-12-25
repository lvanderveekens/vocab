import 'dart:async' show Future;
import 'dart:convert' show json;
import 'dart:developer';
import 'package:flutter/services.dart' show rootBundle;
import 'package:vocab/language/language.dart';

class Languages {
  final List<Language> list;

  Languages({required this.list});

  Language getByCode(String code) {
    return list.firstWhere(
      (language) => language.hasCode(code),
      orElse: () => throw ArgumentError("Language not found", code),
    );
  }
}

class LanguagesLoader {
  final String pathToFile = "assets/languages.json";

  LanguagesLoader();

  Future<Languages> load() {
    log("Loading languages");
    return rootBundle.loadStructuredData<Languages>(pathToFile,
        (jsonStr) async {
      var languagesJson = json.decode(jsonStr) as List;
      List<Language> list = languagesJson
          .map((languageJson) => Language.fromJson(languageJson))
          .toList();

      list.sort((a, b) => a.name.compareTo(b.name));

      return Languages(list: list);
    });
  }
}
