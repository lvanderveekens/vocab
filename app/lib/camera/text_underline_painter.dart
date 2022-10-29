import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class TextUnderlinePainter extends CustomPainter {
  final Rect tappedWordRect;
  final double scaleFactor;

  TextUnderlinePainter(this.tappedWordRect, this.scaleFactor);

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final Paint yellowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Color(0xFF00A3FF)
      ..strokeWidth = 2.0 * scaleFactor;

    // canvas.drawRect(tappedWordRect, yellowPaint);
    canvas.drawLine(
      Offset(tappedWordRect.left, tappedWordRect.bottom + 4.0 * scaleFactor),
      Offset(tappedWordRect.right, tappedWordRect.bottom + 4.0 * scaleFactor),
      yellowPaint,
    );
  }

  @override
  bool shouldRepaint(TextUnderlinePainter oldDelegate) {
    return oldDelegate.tappedWordRect != tappedWordRect ||
        oldDelegate.scaleFactor != scaleFactor;
  }
}
