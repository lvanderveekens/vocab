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

class StudyOverviewPage extends StatefulWidget {
  final DeckStorage deckStorage;

  const StudyOverviewPage({
    Key? key,
    required this.deckStorage,
  }) : super(key: key);

  @override
  State<StudyOverviewPage> createState() => StudyOverviewPageState();
}

class StudyOverviewPageState extends State<StudyOverviewPage> {
  Deck? _deck;

  @override
  void initState() {
    super.initState();
    widget.deckStorage.get().then((deck) {
      setState(() {
        _deck = deck;
      });
      log("Deck loaded");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(),
    );
  }
}
