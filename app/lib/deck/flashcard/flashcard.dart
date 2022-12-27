import 'package:vocab/deck/flashcard/review.dart';

class Flashcard {
  final String id;
  final String sourceLanguageCode;
  final String sourceWord;
  final String targetLanguageCode;
  final String targetWord;

  Review? lastReview;

  Flashcard({
    required this.id,
    required this.sourceLanguageCode,
    required this.sourceWord,
    required this.targetLanguageCode,
    required this.targetWord,
    this.lastReview,
  });

  bool isNew() {
    return lastReview == null;
  }

  bool isInLearning() {
    return lastReview?.learning == true;
  }

  bool isReviewable() {
    if (lastReview == null) {
      return false;
    }
    return DateTime.now().isAfter(
      lastReview!.timestamp.add(Duration(days: lastReview!.intervalDays)),
    );
  }

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id'],
      sourceLanguageCode: json['sourceLanguageCode'],
      sourceWord: json['sourceWord'],
      targetLanguageCode: json['targetLanguageCode'],
      targetWord: json['targetWord'],
      lastReview: json['lastReview'] != null
          ? Review.fromJson(json['lastReview'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sourceLanguageCode': sourceLanguageCode,
      'sourceWord': sourceWord,
      'targetLanguageCode': targetLanguageCode,
      'targetWord': targetWord,
      'lastReview': lastReview?.toJson(),
    };
  }
}
