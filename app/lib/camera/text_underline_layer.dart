import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:collection/collection.dart';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:vocab/camera/text_underline_painter.dart';
import 'package:vocab/deck/deck_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vocab/deck/deck.dart';
import 'package:vocab/secret/secrets.dart';
import 'package:vocab/text_to_speech/google_cloud_text_to_speech_client.dart';
import 'package:vocab/text_to_speech/google_cloud_text_to_speech_languages.dart';
import 'package:vocab/translation/google_cloud_translation_client.dart';
import 'package:vocab/translation/google_cloud_translation_languages.dart';
import 'package:vocab/translation/google_cloud_translation_dtos.dart';
import 'package:vocab/user/user_preferences.dart';
import 'package:vocab/user/user_preferences_storage.dart';

class TextUnderlineLayer extends StatefulWidget {
  final RecognizedText recognizedText;
  final TextElement tappedWord;
  final double scaleFactor;
  final Function callback;

  // TODO: use a callback to update dragged text elements there.

  const TextUnderlineLayer({
    Key? key,
    required this.recognizedText,
    required this.tappedWord,
    required this.scaleFactor,
    required this.callback,
  }) : super(key: key);

  @override
  State<TextUnderlineLayer> createState() => TextUnderlineLayerState();
}

class TextUnderlineLayerState extends State<TextUnderlineLayer> {
  List<TextElement> _selectedTextElements = [];

  @override
  void initState() {
    super.initState();
    _selectedTextElements.add(widget.tappedWord);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(fit: StackFit.expand, children: <Widget>[
      _buildTextUnderlineCustomPaint(),
      GestureDetector(
        onPanStart: (DragStartDetails details) {
          log("onPanStart()");
          _selectedTextElements.clear();
        },
        onPanUpdate: (DragUpdateDetails details) {
          outerLoop:
          for (TextBlock block in widget.recognizedText!.blocks) {
            for (TextLine line in block.lines) {
              for (TextElement element in line.elements) {
                if (element.boundingBox.contains(details.localPosition)) {
                  log("Dragged over: ${element.text}");

                  if (!_selectedTextElements.contains(element)) {
                    setState(() {
                      _selectedTextElements.add(element);
                    });
                  }

                  break outerLoop;
                }
              }
            }
          }
        },
        onPanEnd: (DragEndDetails details) {
          log("onPanEnd()");
          log("Dragged word rects: " +
              _selectedTextElements
                  // TODO: First sort by text blocks, then by text lines within that block, then by words within that line
                  .map((x) => x.text)
                  .toString());
          setState(() {
            // trigger a refresh
            _selectedTextElements = _selectedTextElements;
          });
          widget.callback(_selectedTextElements);
        },
      )
    ]);
  }

  Widget _buildTextUnderlineCustomPaint() {
    List<Rect> wordRects = [];
    if (_selectedTextElements.isNotEmpty) {
      wordRects = _selectedTextElements.map((e) => e.boundingBox).toList();
    }

    final painter = TextUnderlinePainter(wordRects, widget.scaleFactor);
    return CustomPaint(painter: painter);
  }
}
