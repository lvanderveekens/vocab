import 'dart:convert';

import 'package:vocab/language/language.dart';

class Deck {
  List<Flashcard> cards;

  Deck({required this.cards});

  factory Deck.fromJson(Map<String, dynamic> json) {
    var cardsJson = json['cards'] as List;
    List<Flashcard> cards =
        cardsJson.map((cardJson) => Flashcard.fromJson(cardJson)).toList();

    return Deck(cards: cards);
  }

  Map<String, dynamic> toJson() {
    return {
      'cards': cards.map((c) => jsonEncode(c)).toList(),
    };
  }
}

class Flashcard {
  final String id;

  final String sourceLanguageCode;
  final String sourceWord;

  final String targetLanguageCode;
  final String targetWord;

  Flashcard({
    required this.id,
    required this.sourceLanguageCode,
    required this.sourceWord,
    required this.targetLanguageCode,
    required this.targetWord,
  });

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id'],
      sourceLanguageCode: json['sourceLanguageCode'],
      sourceWord: json['sourceWord'],
      targetLanguageCode: json['targetLanguageCode'],
      targetWord: json['targetWord'],
    );
  }
}
