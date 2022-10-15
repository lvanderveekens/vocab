class GoogleCloudTextToSpeechSynthesizeRequest {
  final SynthesisInput input;
  final VoiceSelectionParams voice;
  final AudioConfig audioConfig;

  const GoogleCloudTextToSpeechSynthesizeRequest({
    required this.input,
    required this.voice,
    required this.audioConfig,
  });

  factory GoogleCloudTextToSpeechSynthesizeRequest.fromJson(
      Map<String, dynamic> json) {
    return GoogleCloudTextToSpeechSynthesizeRequest(
      input: SynthesisInput.fromJson(json['input']),
      voice: json['voice'],
      audioConfig: json['audioConfig'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "input": input.toJson(),
      "voice": voice.toJson(),
      "audioConfig": audioConfig.toJson(),
    };
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

  Map<String, dynamic> toJson() {
    return {
      "text": text,
    };
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

  Map<String, dynamic> toJson() {
    return {
      "languageCode": languageCode,
      "ssmlGender": ssmlGender.name,
    };
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

  Map<String, dynamic> toJson() {
    return {
      "audioEncoding": audioEncoding.name,
    };
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

class GoogleCloudTextToSpeechSynthesizeResponse {
  final String audioContent;

  const GoogleCloudTextToSpeechSynthesizeResponse({
    required this.audioContent,
  });

  factory GoogleCloudTextToSpeechSynthesizeResponse.fromJson(
      Map<String, dynamic> json) {
    return GoogleCloudTextToSpeechSynthesizeResponse(
      audioContent: json['audioContent'],
    );
  }
}
