import 'package:language_picker/languages.dart';

class UserPreferences {
  final Language sourceLanguage;
  final Language targetLanguage;

  const UserPreferences({
    required this.sourceLanguage,
    required this.targetLanguage,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      sourceLanguage: Language.fromIsoCode(json['sourceLanguageCode']),
      targetLanguage: Language.fromIsoCode(json['targetLanguageCode']),
    );
  }
}
