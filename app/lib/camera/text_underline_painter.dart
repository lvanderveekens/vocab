import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class TextUnderlinePainter extends CustomPainter {
  final List<Rect> wordRects;
  final double scaleFactor;

  TextUnderlinePainter(this.wordRects, this.scaleFactor);

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final Paint yellowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Color(0xFF00A3FF)
      ..strokeWidth = 2.0 * scaleFactor;

    // canvas.drawRect(tappedWordRect, yellowPaint);
    for (Rect wordRect in wordRects) {
      canvas.drawLine(
        Offset(wordRect.left, wordRect.bottom + 4.0 * scaleFactor),
        Offset(wordRect.right, wordRect.bottom + 4.0 * scaleFactor),
        yellowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(TextUnderlinePainter oldDelegate) {
    return oldDelegate.wordRects != wordRects ||
        oldDelegate.scaleFactor != scaleFactor;
  }
}
