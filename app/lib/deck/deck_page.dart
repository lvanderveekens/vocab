import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:vocab/deck/deck.dart';
import 'package:vocab/deck/deck_storage.dart';
import 'package:vocab/language/language.dart';
import 'package:vocab/language/languages.dart';
import 'package:vocab/secret/secrets.dart';
import 'package:vocab/camera/text_decorator_painter.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class DeckPage extends StatefulWidget {
  final DeckStorage deckStorage;
  final List<Language> languages;

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
      return Center(child: Text("Your deck is empty."));
    }

    return Scaffold(
        backgroundColor: Colors.white,
        body: ListView.builder(
          itemCount: cards.length,
          itemBuilder: (context, index) {
            var margin = index == cards.length - 1
                ? const EdgeInsets.all(16.0)
                : const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0);

            return Container(
                margin: margin,
                child: Dismissible(
                  key: Key(cards[index].id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    setState(() {
                      Flashcard deletedCard = cards.removeAt(index);
                      widget.deckStorage.save(_deck!);

                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text('Card deleted'),
                          action: SnackBarAction(
                            label: "Undo",
                            onPressed: () {
                              _setStateIfMounted(() {
                                cards.insert(index, deletedCard);
                                widget.deckStorage.save(_deck!);
                              });
                            },
                          )));
                    });
                  },
                  background: Container(
                    color: Colors.red,
                    child: Container(
                        margin: EdgeInsets.only(right: 16.0),
                        child: Text("Delete",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    alignment: Alignment.centerRight,
                  ),
                  child: _buildFlashcard(cards[index]),
                ));

            // return ;
          },
        ));
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
            border: Border.all(color: Colors.black26),
            borderRadius: BorderRadius.circular(10.0)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              margin: EdgeInsets.only(bottom: 8.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_getLanguageName(card.sourceLanguageCode),
                        style: TextStyle(
                            color: Color(0xFF00A3FF),
                            fontWeight: FontWeight.bold,
                            fontSize: 12.0)),
                    Text(card.sourceWord, style: TextStyle(fontSize: 24.0)),
                  ])),
          const Divider(color: Colors.black26, height: 1.0, thickness: 1.0),
          Container(
              margin: EdgeInsets.only(top: 8.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_getLanguageName(card.targetLanguageCode),
                        style: TextStyle(
                            color: Color(0xFF00A3FF),
                            fontWeight: FontWeight.bold,
                            fontSize: 12.0)),
                    Text(card.targetWord, style: TextStyle(fontSize: 24.0)),
                  ])),
        ]));
  }

  String _getLanguageName(String code) {
    return widget.languages.firstWhere((l) => l.hasCode(code)).name;
  }
}
