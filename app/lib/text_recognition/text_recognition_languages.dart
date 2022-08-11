import 'dart:async' show Future;
import 'dart:convert' show json;
import 'package:flutter/services.dart' show rootBundle;
import 'package:vocab/language/language.dart';
import 'package:vocab/language/languages.dart';

// https://developers.google.com/ml-kit/vision/text-recognition/languages

class TextRecognitionLanguages {
  static const String pathToFile = "assets/text_recognition_languages.json";

  TextRecognitionLanguages();

  static Future<List<TextRecognitionLanguage>> load() async {
    var languages = await Languages.getInstance();

    return rootBundle.loadStructuredData<List<TextRecognitionLanguage>>(
        pathToFile, (jsonStr) async {
      var languageCodesJson = json.decode(jsonStr) as List;

      List<TextRecognitionLanguage> textRecognitionLanguages =
          languageCodesJson.map((languageCodeJson) {
        var code = languageCodeJson;
        return TextRecognitionLanguage(
            code: code, language: languages.findByCode(code)!);
      }).toList();

      textRecognitionLanguages
          .sort((a, b) => a.language.name.compareTo(b.language.name));

      return textRecognitionLanguages;
    });
  }
}

class TextRecognitionLanguage {
  final String code;
  final Language language;

  const TextRecognitionLanguage({
    required this.code,
    required this.language,
  });
}
