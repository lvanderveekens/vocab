class Flashcard {
  final String id;
  final String sourceLanguageCode;
  final String sourceWord;
  final String targetLanguageCode;
  final String targetWord;

  final SM2Metadata? sm2Metadata;

  Flashcard({
    required this.id,
    required this.sourceLanguageCode,
    required this.sourceWord,
    required this.targetLanguageCode,
    required this.targetWord,
    this.sm2Metadata,
  });

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id'],
      sourceLanguageCode: json['sourceLanguageCode'],
      sourceWord: json['sourceWord'],
      targetLanguageCode: json['targetLanguageCode'],
      targetWord: json['targetWord'],
      sm2Metadata: json['sm2Metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sourceLanguageCode': sourceLanguageCode,
      'sourceWord': sourceWord,
      'targetLanguageCode': targetLanguageCode,
      'targetWord': targetWord,
      'sm2Metadata': sm2Metadata?.toJson(),
    };
  }
}

class SM2Metadata {
  final int repetitionNumber;
  final double easinessFactor;
  final int intervalDays;

  SM2Metadata({
    required this.repetitionNumber,
    required this.easinessFactor,
    required this.intervalDays,
  });

  factory SM2Metadata.fromJson(Map<String, dynamic> json) {
    return SM2Metadata(
      repetitionNumber: json['repetitionNumber'],
      easinessFactor: json['easinessFactor'],
      intervalDays: json['intervalDays'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'repetitionNumber': repetitionNumber,
      'easinessFactor': easinessFactor,
      'intervalDays': intervalDays,
    };
  }
}
