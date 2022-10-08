import 'dart:async' show Future;
import 'dart:convert' show json;
import 'package:flutter/services.dart' show rootBundle;
import 'package:vocab/language/language.dart';
import 'package:vocab/language/languages.dart';

class GoogleCloudTextToSpeechLanguages {
  static const String pathToFile =
      "assets/google_cloud_text_to_speech_get_voices_response.json";

  GoogleCloudTextToSpeechLanguages();

  static Future<List<GoogleCloudTextToSpeechLanguage>> load() async {
    var languages = await Languages.getInstance();

    return rootBundle.loadStructuredData<List<GoogleCloudTextToSpeechLanguage>>(
        pathToFile, (jsonStr) async {
      var voicesJson = json.decode(jsonStr)['voices'] as List;

      // TODO: list warning for voices with language codes that are not recognized.

      Set<String> languageCodes = voicesJson
          .expand((voiceJson) => voiceJson['languageCodes'])
          .map((languageCode) => languageCode.toString())
          .toSet();

      List<GoogleCloudTextToSpeechLanguage> textToSpeechLanguages =
          languageCodes.map((code) {
        return GoogleCloudTextToSpeechLanguage(
            code: code, language: languages.findByCode(code));
      }).toList();

      textToSpeechLanguages
          .sort((a, b) => a.language.name.compareTo(b.language.name));

      return textToSpeechLanguages;
    });
  }
}

class GoogleCloudTextToSpeechLanguage {
  final String code;
  final Language language;

  const GoogleCloudTextToSpeechLanguage({
    required this.code,
    required this.language,
  });
}
