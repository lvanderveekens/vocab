import 'dart:async' show Future;
import 'dart:convert' show json;
import 'package:flutter/services.dart' show rootBundle;
import 'package:language_picker/languages.dart';

class GoogleTranslationSupportedLanguages {
  static const String pathToFile =
      "assets/google_translation_supported_languages.json";

  GoogleTranslationSupportedLanguages();

  static Future<List<Language>> load() {
    return rootBundle.loadStructuredData<List<Language>>(pathToFile,
        (jsonStr) async {
      var languagesJson = json.decode(jsonStr) as List;
      List<Language> languages = languagesJson
          .map((languageJson) {
            try {
              return Language.fromIsoCode(languageJson['code']);
            } catch (e) {
              return null;
            }
          })
          .where((el) => el != null)
          .map((el) => el!)
          .toList();

      return languages;
    });
  }
}
