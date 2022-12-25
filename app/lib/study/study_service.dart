import 'package:vocab/deck/deck.dart';
import 'package:vocab/deck/deck_storage.dart';
import 'package:vocab/deck/flashcard/flashcard.dart';
import 'package:vocab/deck/flashcard/review.dart';
import 'package:vocab/sm2/sm2_algorithm.dart';

class StudyService {
  List<Flashcard> findCardsForReviewSession(Deck deck) {
    return deck.getNewCards() +
        deck.getCardsInLearning() +
        deck.getCardsToReview();
  }

  void reviewCard(Flashcard card, int grade) {
    final result = SM2Algorithm.apply(
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
      learning: grade < 4,
    );
  }
}
