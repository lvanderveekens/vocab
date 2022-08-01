import 'package:language_picker/languages.dart';

class UserPreferences {
  Language? sourceLanguage;
  Language? targetLanguage;

  UserPreferences({
    this.sourceLanguage,
    this.targetLanguage,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    UserPreferences userPreferences = new UserPreferences();

    var sourceLanguageCode = json['sourceLanguageCode'];
    if (sourceLanguageCode != null) {
      userPreferences.sourceLanguage = Language.fromIsoCode(sourceLanguageCode);
    }
    var targetLanguageCode = json['targetLanguageCode'];
    if (targetLanguageCode != null) {
      userPreferences.targetLanguage = Language.fromIsoCode(targetLanguageCode);
    }

    return userPreferences;
  }

  Map<String, dynamic> toJson() {
    return {
      'sourceLanguageCode': sourceLanguage?.isoCode,
      'targetLanguageCode': targetLanguage?.isoCode,
    };
  }
}
