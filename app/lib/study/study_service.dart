import 'package:vocab/deck/flashcard.dart';
import 'package:vocab/sm2/sm2_algorithm.dart';

class StudyService {
  void reviewCard(Flashcard card, int grade) {
    final result = SM2Algorithm.apply(
      grade,
      card.sm2Metadata?.repetitionNumber,
      card.sm2Metadata?.easinessFactor,
      card.sm2Metadata?.intervalDays,
    );

    card.lastReviewedAt = DateTime.now();
    card.beingLearned = grade < 4;
    card.sm2Metadata = SM2Metadata(
      repetitionNumber: result.repetitionNumber,
      easinessFactor: result.easinessFactor,
      intervalDays: result.intervalDays,
    );
  }
}
