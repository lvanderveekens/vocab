import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class TextDetectorPainter extends CustomPainter {
  final Size imageSize;
  final RecognizedText recognizedText;
  final List<Rect> selectedRects;
  final Rect? selectionRect;

  TextDetectorPainter(this.imageSize, this.recognizedText, this.selectedRects,
      this.selectionRect);

  @override
  void paint(Canvas canvas, Size canvasSize) {
    log("@>paint");
    // only works if aspect ratios match

    // TODO: aspect ratios do not match...
    // 'recognizedText' is based on image size.
    final double scaleX = canvasSize.width / imageSize.width;
    final double scaleY = canvasSize.height / imageSize.height;

    Rect scaleRect(Rect boundingBox) {
      return Rect.fromLTRB(
        boundingBox.left * scaleX,
        boundingBox.top * scaleY,
        boundingBox.right * scaleX,
        boundingBox.bottom * scaleY,
      );
    }

    final Paint redPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.red
      ..strokeWidth = 2.0;

    final Paint yellowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.yellow
      ..strokeWidth = 2.0;

    final Paint bluePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.blue
      ..strokeWidth = 2.0;

    final Paint blackStrokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black
      ..strokeWidth = 2.0;

    final Paint yellowTransparentFillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Color(0x6FFFEB3B)
      ..strokeWidth = 2.0;

    final Paint themeFillPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Color(0xFF00A3FF)
      ..strokeWidth = 5.0;

    // for (TextBlock block in recognizedText.blocks) {
    //   for (TextLine line in block.lines) {
    //     for (TextElement element in line.elements) {
    //       // print("draw rectangle for element: " + element.text);
    //       final elementBoundingBox = element.boundingBox;
    //       final scaledRect = scaleRect(elementBoundingBox);

    //       canvas.drawRect(scaledRect, redPaint);
    //     }

    //     canvas.drawRect(scaleRect(line.boundingBox), yellowPaint);
    //   }

    //   canvas.drawRect(scaleRect(block.boundingBox), bluePaint);
    // }

    log("@@@@@@: " + selectionRect.toString());
    if (selectionRect != null) {
      final scaledRect = scaleRect(selectionRect!);
      canvas.drawRect(scaledRect, blackStrokePaint);
    }

    for (Rect selectedRect in selectedRects) {
      final scaledRect = scaleRect(selectedRect);
      canvas.drawRect(scaledRect, themeFillPaint);
    }

    canvas.drawRect(
        scaleRect(Rect.fromLTRB(
          0.0,
          0.0,
          imageSize.width,
          imageSize.height,
        )),
        redPaint);
  }

  @override
  bool shouldRepaint(TextDetectorPainter oldDelegate) {
    return oldDelegate.imageSize != imageSize ||
        oldDelegate.recognizedText != recognizedText ||
        oldDelegate.selectedRects != selectedRects ||
        oldDelegate.selectionRect != selectionRect;
  }
}
