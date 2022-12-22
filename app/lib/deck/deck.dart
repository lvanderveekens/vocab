import 'dart:convert';

import 'package:vocab/deck/flashcard.dart';

class Deck {
  List<Flashcard> cards;

  Deck({required this.cards});

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
