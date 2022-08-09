import 'dart:async' show Future;
import 'dart:convert' show json;
import 'package:flutter/services.dart' show rootBundle;
import 'package:vocab/language/language.dart';
import 'package:vocab/language/languages.dart';

// https://cloud.google.com/translate/docs/languages

class GoogleTranslationLanguages {
  static const String pathToFile = "assets/google_translation_languages.json";

  GoogleTranslationLanguages();

  static Future<List<GoogleTranslationLanguage>> load() async {
    // TODO: reads weird
    var languages = await Languages.getInstance();

    return rootBundle.loadStructuredData<List<GoogleTranslationLanguage>>(
        pathToFile, (jsonStr) async {
      var languagesJson = json.decode(jsonStr)['data']['languages'] as List;

      List<GoogleTranslationLanguage> translationLanguages =
          languagesJson.map((languageJson) {
        var code = languageJson['language'];

        return GoogleTranslationLanguage(
            code: code, language: languages.findByCode(code)!);
      }).toList();

      return translationLanguages;
    });
  }
}

class GoogleTranslationLanguage {
  final String code;
  final Language language;

  const GoogleTranslationLanguage({
    required this.code,
    required this.language,
  });
}
