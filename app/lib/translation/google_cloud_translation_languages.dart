import 'dart:async' show Future;
import 'dart:convert' show json;
import 'dart:developer';

import 'package:flutter/services.dart' show rootBundle;
import 'package:vocab/language/languages.dart';
import 'package:vocab/translation/google_cloud_translation_language.dart';

// https://cloud.google.com/translate/docs/languages

class GoogleCloudTranslationLanguages {
  final List<GoogleCloudTranslationLanguage> list;

  GoogleCloudTranslationLanguages({required this.list});
}

class GoogleCloudTranslationLanguagesLoader {
  static const String pathToFile =
      "assets/google_cloud_translation_languages.json";

  final Languages languages;

  GoogleCloudTranslationLanguagesLoader({required this.languages});

  Future<GoogleCloudTranslationLanguages> load() async {
    log("Loading Google Cloud translation languages");
    return rootBundle.loadStructuredData<GoogleCloudTranslationLanguages>(
        pathToFile, (jsonStr) async {
      var languagesJson = json.decode(jsonStr)['data']['languages'] as List;

      List<GoogleCloudTranslationLanguage> list =
          languagesJson.map((languageJson) {
        var code = languageJson['language'];

        return GoogleCloudTranslationLanguage(
            code: code, language: languages.getByCode(code));
      }).toList();

      list.sort((a, b) => a.language.name.compareTo(b.language.name));

      return GoogleCloudTranslationLanguages(list: list);
    });
  }
}
