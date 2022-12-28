import 'package:vocab/deck/flashcard/flashcard.dart';
import 'package:vocab/deck/flashcard/review.dart';
import 'package:vocab/sm2/sm2_modified_algorithm.dart';

class StudyService {
  void reviewCard(Flashcard card, int grade) {
    final result = SM2ModifiedAlgorithm.apply(
      grade,
      card.lastReview?.repetitionNumber,
      card.lastReview?.easinessFactor,
      card.lastReview?.intervalDays,
    );

    card.lastReview = Review(
      timestamp: DateTime.now(),
      repetitionNumber: result.repetitionNumber,
      easinessFactor: result.easinessFactor,
      intervalDays: result.intervalDays,
      learning: grade < 3,
    );
  }
}
