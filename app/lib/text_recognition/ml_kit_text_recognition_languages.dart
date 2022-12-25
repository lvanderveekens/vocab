import 'dart:async' show Future;
import 'dart:convert' show json;
import 'dart:developer';
import 'package:flutter/services.dart' show rootBundle;
import 'package:vocab/language/language.dart';
import 'package:vocab/language/languages.dart';
import 'package:vocab/text_recognition/ml_kit_text_recognition_language.dart';

// https://developers.google.com/ml-kit/vision/text-recognition/languages

class MLKitTextRecognitionLanguages {
  final List<MLKitTextRecognitionLanguage> list;

  MLKitTextRecognitionLanguages({required this.list});
}

class MLKitTextRecognitionLanguagesLoader {
  final String pathToFile = "assets/ml_kit_text_recognition_languages.json";

  final Languages languages;

  MLKitTextRecognitionLanguagesLoader({required this.languages});

  Future<MLKitTextRecognitionLanguages> load() {
    log("Loading ML Kit text recognition languages");
    return rootBundle.loadStructuredData<MLKitTextRecognitionLanguages>(
        pathToFile, (jsonStr) async {
      var languageCodesJson = json.decode(jsonStr) as List;

      List<MLKitTextRecognitionLanguage> list =
          languageCodesJson.map((languageCodeJson) {
        var code = languageCodeJson;
        return MLKitTextRecognitionLanguage(
            code: code, language: languages.getByCode(code));
      }).toList();

      list.sort((a, b) => a.language.name.compareTo(b.language.name));

      return MLKitTextRecognitionLanguages(list: list);
    });
  }
}
