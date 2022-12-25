import 'dart:async' show Future;
import 'dart:convert' show json;
import 'dart:developer';

import 'package:flutter/services.dart' show rootBundle;
import 'package:vocab/language/languages.dart';
import 'package:vocab/text_to_speech/google_cloud_text_to_speech_language.dart';

class GoogleCloudTextToSpeechLanguages {
  List<GoogleCloudTextToSpeechLanguage> list;

  GoogleCloudTextToSpeechLanguages({required this.list});
}

class GoogleCloudTextToSpeechLanguagesLoader {
  static const String pathToFile =
      "assets/google_cloud_text_to_speech_get_voices_response.json";

  final Languages languages;

  GoogleCloudTextToSpeechLanguagesLoader({required this.languages});

  Future<GoogleCloudTextToSpeechLanguages> load() async {
    log("Loading Google Cloud text to speech languages");
    return rootBundle.loadStructuredData<GoogleCloudTextToSpeechLanguages>(
        pathToFile, (jsonStr) async {
      var voicesJson = json.decode(jsonStr)['voices'] as List;

      // TODO: list warning for voices with language codes that are not recognized.

      Set<String> languageCodes = voicesJson
          .expand((voiceJson) => voiceJson['languageCodes'])
          .map((languageCode) => languageCode.toString())
          .toSet();

      List<GoogleCloudTextToSpeechLanguage> list = languageCodes.map((code) {
        return GoogleCloudTextToSpeechLanguage(
            code: code, language: languages.getByCode(code));
      }).toList();

      list.sort((a, b) => a.language.name.compareTo(b.language.name));

      return GoogleCloudTextToSpeechLanguages(list: list);
    });
  }
}
