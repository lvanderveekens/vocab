import 'dart:convert';

import 'package:vocab/deck/flashcard/flashcard.dart';

class Deck {
  List<Flashcard> cards;

  Deck({required this.cards});

  List<Flashcard> getNewCards() {
    return cards.where((c) => c.isNew()).toList();
  }

  List<Flashcard> getCardsInLearning() {
    var cardsInLearning = cards.where((c) => c.isInLearning()).toList();
    cardsInLearning.sort(_byLastReviewTimestamp);
    return cardsInLearning;
  }

  List<Flashcard> getCardsToReview() {
    var cardsToReview = cards.where((c) => c.isReviewable()).toList();
    cardsToReview.sort(_byLastReviewTimestamp);
    return cardsToReview;
  }

  List<Flashcard> getCardsForReviewSession() {
    return getNewCards() + getCardsInLearning() + getCardsToReview();
  }

  int _byLastReviewTimestamp(a, b) =>
      a.lastReview!.timestamp.compareTo(b.lastReview!.timestamp);

  factory Deck.fromJsonV1(Map<String, dynamic> json) {
    var cardsJson = json['cards'] as List;
    List<Flashcard> cards = cardsJson
        .map((cardJson) => Flashcard.fromJson(jsonDecode(cardJson)))
        .toList();

    return Deck(cards: cards);
  }

  factory Deck.fromJsonV2(Map<String, dynamic> json) {
    var cardsJson = json['cards'] as List;
    List<Flashcard> cards =
        cardsJson.map((cardJson) => Flashcard.fromJson(cardJson)).toList();

    return Deck(cards: cards);
  }

  Map<String, dynamic> toJson() {
    return {
      'cards': cards.map((c) => c.toJson()).toList(),
    };
  }
}
