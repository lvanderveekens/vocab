import 'dart:convert';

import 'package:vocab/deck/flashcard.dart';

class Deck {
  List<Flashcard> cards;

  Deck({required this.cards});

  int countNewCards() {
    return cards.where((c) => c.lastReviewedAt == null).length;
  }

  int countCardsBeingLearned() {
    return cards.where((c) => c.beingLearned == true).length;
  }

  int countReviewableCards() {
    return cards.where((c) {
      final lastReviewedAt = c.lastReviewedAt;
      if (lastReviewedAt == null) {
        return false;
      }
      return DateTime.now().isAfter(
        lastReviewedAt.add(Duration(days: c.sm2Metadata!.intervalDays)),
      );
    }).length;
  }

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
