class UserPreferences {
  String sourceLanguageCode;
  String targetLanguageCode;

  UserPreferences({
    required this.sourceLanguageCode,
    required this.targetLanguageCode,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
        sourceLanguageCode: json['sourceLanguageCode'],
        targetLanguageCode: json['targetLanguageCode']);
  }

  Map<String, dynamic> toJson() {
    return {
      'sourceLanguageCode': sourceLanguageCode,
      'targetLanguageCode': targetLanguageCode,
    };
  }
}
