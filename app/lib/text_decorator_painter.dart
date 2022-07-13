import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class TextDetectorPainter extends CustomPainter {
  TextDetectorPainter(this.imageSize, this.recognizedText);

  final Size imageSize;
  final RecognizedText recognizedText;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    // only works because canvas size and image size have the same aspect ratio
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

    final Paint bluePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.blue
      ..strokeWidth = 2.0;

    final Paint yellowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.yellow
      ..strokeWidth = 2.0;

    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        for (TextElement element in line.elements) {
          // print("draw rectangle for element: " + element.text);
          final elementBoundingBox = element.boundingBox;
          final scaledRect = scaleRect(elementBoundingBox);

          canvas.drawRect(scaledRect, redPaint);
        }

        // canvas.drawRect(scaleRect(line.boundingBox), yellowPaint);
      }

      // canvas.drawRect(scaleRect(block.boundingBox), bluePaint);
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
        oldDelegate.recognizedText != recognizedText;
  }
}
