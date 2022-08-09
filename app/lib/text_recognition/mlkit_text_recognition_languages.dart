import 'dart:async' show Future;
import 'dart:convert' show json;
import 'package:flutter/services.dart' show rootBundle;
import 'package:vocab/language/language.dart';
import 'package:vocab/language/languages.dart';

// https://developers.google.com/ml-kit/vision/text-recognition/languages

class MLKitTextRecognitionLanguages {
  static const String pathToFile =
      "assets/mlkit_text_recognition_languages.json";

  MLKitTextRecognitionLanguages();

  static Future<List<MLKitTextRecognitionLanguage>> load() async {
    // TODO: reads weird
    var languages = await Languages.getInstance();

    return rootBundle.loadStructuredData<List<MLKitTextRecognitionLanguage>>(
        pathToFile, (jsonStr) async {
      var languageCodesJson = json.decode(jsonStr) as List;

      List<MLKitTextRecognitionLanguage> textRecognitionLanguages =
          languageCodesJson.map((languageCodeJson) {
        var code = languageCodeJson;
        return MLKitTextRecognitionLanguage(
            code: code, language: languages.findByCode(code)!);
      }).toList();

      return textRecognitionLanguages;
    });
  }
}

class MLKitTextRecognitionLanguage {
  final String code;
  final Language language;

  const MLKitTextRecognitionLanguage({
    required this.code,
    required this.language,
  });
}
