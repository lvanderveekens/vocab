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
import 'package:vocab/secret/secrets.dart';
import 'package:vocab/camera/text_decorator_painter.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class DeckPage extends StatefulWidget {
  final DeckStorage deckStorage;

  const DeckPage({Key? key, required this.deckStorage}) : super(key: key);

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
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(
          children: (_deck?.cards ?? []).map((card) {
        return Container(
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
            width: double.infinity,
            decoration: BoxDecoration(border: Border.all(color: Colors.black)),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                  margin: EdgeInsets.only(bottom: 16.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(card.sourceLanguage.name,
                            style: TextStyle(fontSize: 12.0)),
                        Text(card.sourceWord, style: TextStyle(fontSize: 24.0)),
                      ])),
              const Divider(color: Colors.black, height: 1.0, thickness: 1.0),
              Container(
                  margin: EdgeInsets.only(top: 16.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(card.targetLanguage.name,
                            style: TextStyle(fontSize: 12.0)),
                        Text(card.targetWord, style: TextStyle(fontSize: 24.0)),
                      ])),
            ]));
      }).toList()),
    ));
  }
}
