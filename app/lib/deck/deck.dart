import 'package:language_picker/languages.dart';

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
      'cards': cards.map((c) => c.toJson()).toList(),
    };
  }
}

class Flashcard {
  final String id;

  final Language sourceLanguage;
  final String sourceWord;

  final Language targetLanguage;
  final String targetWord;

  Flashcard({
    required this.id,
    required this.sourceLanguage,
    required this.sourceWord,
    required this.targetLanguage,
    required this.targetWord,
  });

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id'],
      sourceLanguage: Language.fromIsoCode(json['sourceLanguageCode']),
      sourceWord: json['sourceWord'],
      targetLanguage: Language.fromIsoCode(json['targetLanguageCode']),
      targetWord: json['targetWord'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sourceLanguageCode': sourceLanguage.isoCode,
      'sourceWord': sourceWord,
      'targetLanguageCode': targetLanguage.isoCode,
      'targetWord': targetWord,
    };
  }
}
