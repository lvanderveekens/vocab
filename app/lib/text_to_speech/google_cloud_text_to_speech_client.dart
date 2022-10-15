import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:vocab/text_to_speech/google_cloud_text_to_speech_dtos.dart';

class GoogleCloudTextToSpeechClient {
  final String apiKey;

  const GoogleCloudTextToSpeechClient({required this.apiKey});

  Future<String> synthesize(String text, String languageCode) async {
    final response = await http.post(
      Uri.parse('https://texttospeech.googleapis.com/v1/text:synthesize')
          .replace(queryParameters: {'key': apiKey}),
      body: jsonEncode(GoogleCloudTextToSpeechSynthesizeRequest(
        input: SynthesisInput(text: text),
        voice: VoiceSelectionParams(
            languageCode: languageCode, ssmlGender: SsmlVoiceGender.FEMALE),
        audioConfig: const AudioConfig(audioEncoding: AudioEncoding.MP3),
      ).toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to synthesize speech: ${response.body}');
    }

    final synthesizeResponse =
        GoogleCloudTextToSpeechSynthesizeResponse.fromJson(
            jsonDecode(response.body));

    return synthesizeResponse.audioContent;
  }
}
