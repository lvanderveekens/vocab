import 'dart:convert';

class GoogleCloudTranslationResponse {
  final Data data;

  const GoogleCloudTranslationResponse({
    required this.data,
  });

  factory GoogleCloudTranslationResponse.fromJson(Map<String, dynamic> json) {
    return GoogleCloudTranslationResponse(
      data: Data.fromJson(json['data']),
    );
  }
}

class Data {
  final List<Translation> translations;

  const Data({
    required this.translations,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    var translationsJson = json['translations'] as List;
    List<Translation> translations = translationsJson
        .map((translationJson) => Translation.fromJson(translationJson))
        .toList();

    return Data(
      translations: translations,
    );
  }
}

class Translation {
  final String translatedText;

  const Translation({required this.translatedText});

  factory Translation.fromJson(Map<String, dynamic> json) {
    return Translation(
      translatedText: json['translatedText'],
    );
  }
}
