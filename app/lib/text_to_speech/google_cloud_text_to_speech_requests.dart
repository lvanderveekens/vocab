class GoogleCloudTextToSpeechTextSynthesizeRequest {
  final SynthesisInput input;
  final VoiceSelectionParams voice;
  final AudioConfig audioConfig;

  const GoogleCloudTextToSpeechTextSynthesizeRequest({
    required this.input,
    required this.voice,
    required this.audioConfig,
  });

  factory GoogleCloudTextToSpeechTextSynthesizeRequest.fromJson(
      Map<String, dynamic> json) {
    return GoogleCloudTextToSpeechTextSynthesizeRequest(
      input: SynthesisInput.fromJson(json['input']),
      voice: json['voice'],
      audioConfig: json['audioConfig'],
    );
  }
}

class SynthesisInput {
  final String text;

  const SynthesisInput({required this.text});

  factory SynthesisInput.fromJson(Map<String, dynamic> json) {
    return SynthesisInput(
      text: json['text'],
    );
  }
}

class VoiceSelectionParams {
  final String languageCode;
  final SsmlVoiceGender ssmlGender;

  const VoiceSelectionParams({
    required this.languageCode,
    required this.ssmlGender,
  });

  factory VoiceSelectionParams.fromJson(Map<String, dynamic> json) {
    return VoiceSelectionParams(
      languageCode: json['languageCode'],
      ssmlGender: json['ssmlGender'],
    );
  }
}

enum SsmlVoiceGender {
  SSML_VOICE_GENDER_UNSPECIFIED,
  MALE,
  FEMALE,
}

class AudioConfig {
  final AudioEncoding audioEncoding;

  const AudioConfig({required this.audioEncoding});

  factory AudioConfig.fromJson(Map<String, dynamic> json) {
    return AudioConfig(
      audioEncoding: json['audioEncoding'],
    );
  }
}

enum AudioEncoding {
  AUDIO_ENCODING_UNSPECIFIED,
  LINEAR16,
  MP3,
  OGG_OPUS,
  MULAW,
  ALAW
}

class GoogleCloudTextToSpeechTextSynthesizeResponse {
  final String audioContent;

  const GoogleCloudTextToSpeechTextSynthesizeResponse({
    required this.audioContent,
  });

  factory GoogleCloudTextToSpeechTextSynthesizeResponse.fromJson(
      Map<String, dynamic> json) {
    return GoogleCloudTextToSpeechTextSynthesizeResponse(
      audioContent: json['audioContent'],
    );
  }
}
