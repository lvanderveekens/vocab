import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class TextElementWithIndexes {
  final TextElement element;
  final int blockIndex;
  final int lineIndex;
  final int elementIndex;

  TextElementWithIndexes({
    required this.element,
    required this.blockIndex,
    required this.lineIndex,
    required this.elementIndex,
  });

  @override
  bool operator ==(o) =>
      o is TextElementWithIndexes &&
      element == o.element &&
      blockIndex == o.blockIndex &&
      lineIndex == o.lineIndex &&
      elementIndex == o.elementIndex;

  @override
  int get hashCode => super.hashCode;
}
