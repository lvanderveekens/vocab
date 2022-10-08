import 'dart:async' show Future;
import 'dart:convert' show json;
import 'package:flutter/services.dart' show rootBundle;
import 'package:vocab/language/language.dart';
import 'package:vocab/language/languages.dart';

// https://cloud.google.com/translate/docs/languages

class GoogleCloudTranslationLanguages {
  static const String pathToFile =
      "assets/google_cloud_translation_languages.json";

  GoogleCloudTranslationLanguages();

  static Future<List<GoogleCloudTranslationLanguage>> load() async {
    // TODO: reads weird
    var languages = await Languages.getInstance();

    return rootBundle.loadStructuredData<List<GoogleCloudTranslationLanguage>>(
        pathToFile, (jsonStr) async {
      var languagesJson = json.decode(jsonStr)['data']['languages'] as List;

      List<GoogleCloudTranslationLanguage> googleTranslationLanguages =
          languagesJson.map((languageJson) {
        var code = languageJson['language'];

        return GoogleCloudTranslationLanguage(
            code: code, language: languages.findByCode(code));
      }).toList();

      googleTranslationLanguages
          .sort((a, b) => a.language.name.compareTo(b.language.name));

      return googleTranslationLanguages;
    });
  }
}

class GoogleCloudTranslationLanguage {
  final String code;
  final Language language;

  const GoogleCloudTranslationLanguage({
    required this.code,
    required this.language,
  });
}
