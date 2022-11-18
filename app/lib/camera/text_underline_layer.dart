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
import 'package:image/image.dart';
import 'package:uuid/uuid.dart';
import 'package:vocab/camera/text_element_with_indexes.dart';
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
  final TextElementWithIndexes tappedWord;
  final double scaleFactor;
  final Function(List<TextElement>) callback;

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
  List<TextElementWithIndexes> _selectedTextElementsWithIndexes = [];

  @override
  void initState() {
    super.initState();
    _selectedTextElementsWithIndexes.add(widget.tappedWord);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(fit: StackFit.expand, children: <Widget>[
      _buildTextUnderlineCustomPaint(),
      GestureDetector(
        onTapUp: (TapUpDetails details) {
          log("onTapUp()");
          var selectedTextElementWithIndexes =
              _findTextElementWithIndexes(details.localPosition);
          if (selectedTextElementWithIndexes != null) {
            if (_selectedTextElementsWithIndexes
                .contains(selectedTextElementWithIndexes)) {
              setState(() {
                _selectedTextElementsWithIndexes
                    .remove(selectedTextElementWithIndexes);
              });
            } else {
              setState(() {
                _selectedTextElementsWithIndexes
                    .add(selectedTextElementWithIndexes);
              });
            }
            widget.callback(_sort(_selectedTextElementsWithIndexes));
          }
        },
        onPanStart: (DragStartDetails details) {
          log("onPanStart()");
        },
        onPanUpdate: (DragUpdateDetails details) {
          log("onPanUpdate()");
          var selectedTextElementWithIndexes =
              _findTextElementWithIndexes(details.localPosition);
          if (selectedTextElementWithIndexes != null) {
            if (!_selectedTextElementsWithIndexes
                .contains(selectedTextElementWithIndexes)) {
              setState(() {
                _selectedTextElementsWithIndexes
                    .add(selectedTextElementWithIndexes);
              });
            }
          }
        },
        onPanEnd: (DragEndDetails details) {
          log("onPanEnd()");
          widget.callback(_sort(_selectedTextElementsWithIndexes));
        },
      )
    ]);
  }

  TextElementWithIndexes? _findTextElementWithIndexes(Offset localPosition) {
    for (var b = 0; b < widget.recognizedText.blocks.length; b++) {
      var block = widget.recognizedText.blocks[b];
      for (var l = 0; l < block.lines.length; l++) {
        var line = block.lines[l];
        for (var e = 0; e < line.elements.length; e++) {
          var element = line.elements[e];
          if (element.boundingBox.contains(localPosition)) {
            return TextElementWithIndexes(
              element: element,
              blockIndex: b,
              lineIndex: l,
              elementIndex: e,
            );
          }
        }
      }
    }
    return null;
  }

  List<TextElement> _sort(List<TextElementWithIndexes> toBeSorted) {
    toBeSorted.sort((a, b) {
      var compare = a.blockIndex.compareTo(b.blockIndex);
      if (compare != 0) {
        return compare;
      }

      compare = a.lineIndex.compareTo(b.lineIndex);
      if (compare != 0) {
        return compare;
      }

      compare = a.elementIndex.compareTo(b.elementIndex);
      if (compare != 0) {
        return compare;
      }
      return 0;
    });
    return toBeSorted.map((e) => e.element).toList();
  }

  Widget _buildTextUnderlineCustomPaint() {
    List<Rect> wordRects = [];
    if (_selectedTextElementsWithIndexes.isNotEmpty) {
      wordRects = _selectedTextElementsWithIndexes
          .map((e) => e.element.boundingBox)
          .toList();
    }

    final painter = TextUnderlinePainter(wordRects, widget.scaleFactor);
    return CustomPaint(painter: painter);
  }
}
