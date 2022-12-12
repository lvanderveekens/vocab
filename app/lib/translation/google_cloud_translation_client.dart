import 'dart:convert';

import 'package:html_unescape/html_unescape.dart';
import 'package:http/http.dart' as http;
import 'package:vocab/translation/google_cloud_translation_dtos.dart';

class GoogleCloudTranslationClient {
  final String apiKey;

  const GoogleCloudTranslationClient({required this.apiKey});

  Future<String> translate(
    String text,
    String sourceLanguageCode,
    String targetLanguageCode,
  ) async {
    final response = await http.get(
        Uri.parse('https://translation.googleapis.com/language/translate/v2')
            .replace(queryParameters: {
      'q': text,
      'source': sourceLanguageCode,
      'target': targetLanguageCode,
      'key': apiKey,
    }));

    if (response.statusCode != 200) {
      throw Exception('Failed to translate text: ${response.body}');
    }

    final googleTranslationResponse =
        GoogleCloudTranslationTranslateResponse.fromJson(
            jsonDecode(response.body));

    String escaped =
        googleTranslationResponse.data.translations[0].translatedText;
    var htmlUnescape = HtmlUnescape();
    var unescaped = htmlUnescape.convert(escaped);

    return unescaped;
  }
}
