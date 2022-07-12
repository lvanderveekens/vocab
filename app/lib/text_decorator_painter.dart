import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class TextDetectorPainter extends CustomPainter {
  TextDetectorPainter(this.imageSize, this.recognizedText);

  final Size imageSize;
  final RecognizedText recognizedText;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    print("@>paint");

    final double scaleX = canvasSize.width / imageSize.width;
    final double scaleY = canvasSize.height / imageSize.height;

    print("canvas size: " + canvasSize.toString());
    print("canvas ratio (width/height): " +
        (canvasSize.width / canvasSize.height).toString());
    print("image size: " + imageSize.toString());
    print("image ratio (width/height): " +
        (imageSize.width / imageSize.height).toString());

    print("scale " + scaleX.toString() + " " + scaleY.toString());

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
          print("elementBoundingBox before scale");
          print(elementBoundingBox);
          final scaledRect = scaleRect(elementBoundingBox);
          print("elementBoundingBox after scale");
          print(scaledRect);

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
          2376.0,
          4224.0,
        )),
        redPaint);
  }

  @override
  bool shouldRepaint(TextDetectorPainter oldDelegate) {
    return oldDelegate.imageSize != imageSize ||
        oldDelegate.recognizedText != recognizedText;
  }
}
