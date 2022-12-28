import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vocab/deck/deck.dart';
import 'package:vocab/deck/deck_storage.dart';
import 'package:vocab/deck/flashcard/flashcard.dart';
import 'package:vocab/language/languages.dart';

class DeckPage extends StatefulWidget {
  final DeckStorage deckStorage;
  final Languages languages;

  const DeckPage({
    Key? key,
    required this.deckStorage,
    required this.languages,
  }) : super(key: key);

  @override
  State<DeckPage> createState() => DeckPageState();
}

class DeckPageState extends State<DeckPage> {
  Deck? _deck;

  @override
  void initState() {
    super.initState();
    widget.deckStorage.get().then((deck) {
      setState(() {
        _deck = deck;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var cards = _deck?.cards ?? [];
    if (cards.isEmpty) {
      return const Center(child: Text("Your deck is empty."));
    }

    cards = cards.reversed.toList();

    return Scaffold(
        backgroundColor: Colors.white,
        body: Scrollbar(
            child: ListView.builder(
          itemCount: cards.length,
          itemBuilder: (context, reversedIndex) {
            var margin = reversedIndex == cards.length - 1
                ? const EdgeInsets.all(16.0)
                : const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0);

            return Container(
                margin: margin,
                child: Dismissible(
                  key: Key(cards[reversedIndex].id),
                  direction: DismissDirection.endToStart,
                  onDismissed: handleDismissedFlashcard(cards, reversedIndex),
                  background: Container(
                    color: Colors.red,
                    child: Container(
                        margin: const EdgeInsets.only(right: 16.0),
                        child: const Text("Delete",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    alignment: Alignment.centerRight,
                  ),
                  child: _buildFlashcard(cards[reversedIndex]),
                ));
          },
        )));
  }

  DismissDirectionCallback handleDismissedFlashcard(
      List<Flashcard> reversedCards, int reversedIndex) {
    return (direction) {
      final index = reversedCards.length - reversedIndex - 1;

      setState(() {
        final deletedCard = _deck!.cards.removeAt(index);
        widget.deckStorage.save(_deck!);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Card deleted'),
            action: SnackBarAction(
              label: "Undo",
              onPressed: () {
                _setStateIfMounted(() {
                  _deck!.cards.insert(index, deletedCard);
                  widget.deckStorage.save(_deck!);
                });
              },
            )));
      });
    };
  }

  void _setStateIfMounted(VoidCallback fn) {
    if (!mounted) {
      return fn();
    }
    setState(() {
      return fn();
    });
  }

  Widget _buildFlashcard(Flashcard card) {
    return Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black26),
            borderRadius: BorderRadius.circular(5.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 4,
                offset: Offset(0, 4),
              ),
            ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              margin: EdgeInsets.only(bottom: 8.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_getLanguageName(card.sourceLanguageCode),
                        style: TextStyle(fontSize: 12.0)),
                    Text(card.sourceWord, style: TextStyle(fontSize: 24.0)),
                  ])),
          const Divider(color: Colors.black26, height: 1.0, thickness: 1.0),
          Container(
              margin: EdgeInsets.only(top: 8.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_getLanguageName(card.targetLanguageCode),
                        style: TextStyle(fontSize: 12.0)),
                    Text(card.targetWord, style: TextStyle(fontSize: 24.0)),
                  ])),
        ]));
  }

  String _getLanguageName(String code) {
    return widget.languages.getByCode(code).name;
  }
}
