import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class TextDetectorPainter extends CustomPainter {
  TextDetectorPainter(this.absoluteImageSize, this.recognizedText);

  final Size absoluteImageSize;
  final RecognizedText recognizedText;

  @override
  void paint(Canvas canvas, Size size) {
    print("@>paint");
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;
    print("size: " + size.toString());
    print("absoluteImageSize: " + absoluteImageSize.toString());

    print("scale " + scaleX.toString() + " " + scaleY.toString());

    Rect scaleRect(Rect boundingBox) {
      return Rect.fromLTRB(
        boundingBox.left * scaleX,
        boundingBox.top * scaleY,
        boundingBox.right * scaleX,
        boundingBox.bottom * scaleY,
      );
    }

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        for (TextElement element in line.elements) {
          // print("draw rectangle for element: " + element.text);
          paint.color = Colors.green;
          final scaledRect = scaleRect(element.boundingBox);
          // print("scaled rect: " + scaledRect.toString());
          canvas.drawRect(scaledRect, paint);
        }

        paint.color = Colors.yellow;
        canvas.drawRect(scaleRect(line.boundingBox), paint);
      }

      paint.color = Colors.red;
      canvas.drawRect(scaleRect(block.boundingBox), paint);
    }
  }

  @override
  bool shouldRepaint(TextDetectorPainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.recognizedText != recognizedText;
  }
}
