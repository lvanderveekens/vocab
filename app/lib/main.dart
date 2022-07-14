import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:megaphone/google_translation_response.dart';
import 'package:megaphone/secrets.dart';
import 'package:megaphone/text_decorator_painter.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Image Picker Demo',
      home: MyHomePage(title: 'Image Picker Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<XFile>? _imageFileList;

  List<CameraDescription>? cameras;
  CameraController? cameraController;
  bool _isDetecting = false;
  bool _initialized = false;
  bool _isRecognizing = false;
  RecognizedText? _recognizedText;
  File? imageFile;

  bool _showAlertDialog = false;
  String? _tappedText = null;
  String? _translatedText = null;
  List<String>? _recognizedLanguages;

  bool _cameraEnabled = true;
  bool _drawEnabled = false;
  bool _translationEnabled = true;

  @override
  void initState() {
    super.initState();

    if (_cameraEnabled) {
      loadCamera();
    }
  }

  Uint8List _concatenatePlanes(List<Plane> planes) {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }

  loadCamera() async {
    log("@>loadCamera");
    cameras = await availableCameras();

    if (cameras == null) {
      log("No cameras found");
      return;
    }

    // TODO: change to low resolution for better performance?
    cameraController = CameraController(cameras![0], ResolutionPreset.high);

    cameraController!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _initialized = true;
      });

      cameraController!.startImageStream((CameraImage cameraImage) async {
        log("Process image, width: ${cameraImage.width}, height: ${cameraImage.height}");
        if (_isRecognizing) {
          return;
        }

        await recognizeText(cameraImage);
      });
    });
  }

  recognizeText(CameraImage cameraImage) async {
    _isRecognizing = true;

    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    final RecognizedText recognizedText =
        await textRecognizer.processImage(convertToInputImage(cameraImage));

    setState(() {
      _recognizedText = recognizedText;
    });

    _isRecognizing = false;
  }

  InputImage convertToInputImage(CameraImage cameraImage) {
    return InputImage.fromBytes(
        bytes: _concatenatePlanes(cameraImage.planes),
        inputImageData: InputImageData(
            size: Size(
                cameraImage.width.toDouble(), cameraImage.height.toDouble()),
            imageRotation: InputImageRotation.rotation0deg,
            inputImageFormat: InputImageFormat.bgra8888,
            planeData: cameraImage.planes.map(
              (Plane plane) {
                return InputImagePlaneMetadata(
                  bytesPerRow: plane.bytesPerRow,
                  height: plane.height,
                  width: plane.width,
                );
              },
            ).toList()));
  }

  unloadCamera() async {
    if (cameraController != null) {
      cameraController!.stopImageStream();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  handleOverlayTapUp(double scaleX, double scaleY) {
    Rect scaleRect(Rect boundingBox) {
      return Rect.fromLTRB(
        boundingBox.left * scaleX,
        boundingBox.top * scaleY,
        boundingBox.right * scaleX,
        boundingBox.bottom * scaleY,
      );
    }

    return (TapUpDetails details) {
      var x = details.localPosition.dx;
      var y = details.localPosition.dy;

      for (TextBlock block in _recognizedText!.blocks) {
        for (TextLine line in block.lines) {
          for (TextElement element in line.elements) {
            final scaledBoundingBox = scaleRect(element.boundingBox);

            if (scaledBoundingBox.contains(details.localPosition)) {
              log("block recognized langugages: ${block.recognizedLanguages}");

              setState(() {
                _tappedText = element.text;
                _translatedText = null; // translated elsewhere...
                _recognizedLanguages = block.recognizedLanguages;
                _showAlertDialog = true;
              });
            }
          }
        }
      }
    };
  }

  Future<String> translate(String text, String from, String to) async {
    final response = await http.get(
        Uri.parse('https://translation.googleapis.com/language/translate/v2')
            .replace(queryParameters: {
      'q': text,
      'source': from,
      'target': to,
      'key': (await SecretsLoader().load()).apiKey,
    }));

    if (response.statusCode != 200) {
      throw Exception('Failed to call Google Cloud Translation API');
    }

    final googleTranslationResponse =
        GoogleTranslationResponse.fromJson(jsonDecode(response.body));

    return googleTranslationResponse.data.translations[0].translatedText;
  }

  Widget _buildAlertDialogIfNeeded() {
    if (!_showAlertDialog || _tappedText == null) {
      return Container();
    }

    if (_translationEnabled &&
        _recognizedLanguages != null &&
        _recognizedLanguages!.length > 0) {
      final recognizedLanguage = _recognizedLanguages![0];

      translate(_tappedText!, recognizedLanguage, "en").then((value) => {
            setState(() {
              _translatedText = value;
            })
          });
    }

    return AlertDialog(
      content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tapped on: $_tappedText'),
            Text('English translation: $_translatedText'),
            Text('Recognized languages: $_recognizedLanguages'),
          ]),
      actions: <Widget>[
        TextButton(
          onPressed: () => {
            setState(() {
              _showAlertDialog = false;
            })
          },
          child: const Text('OK'),
        ),
      ],
    );
  }

  Widget _buildOverlayIfNeeded() {
    if (_recognizedText == null) {
      return Container();
    }

    // TODO: no static image size
    final imageSize = Size(720, 1280);

    final painter =
        TextDetectorPainter(imageSize, _recognizedText!, _drawEnabled);

    // scaling only works because custom paint size and image size have the same aspect ratio
    // TODO: no static custom paint size
    final Size customPaintSize = Size(390.0, 693.3);
    final double scaleX = customPaintSize.width / imageSize.width;
    final double scaleY = customPaintSize.height / imageSize.height;

    return GestureDetector(
        onTapUp: handleOverlayTapUp(scaleX, scaleY),
        child: CustomPaint(painter: painter, size: customPaintSize));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(widget.title!),
      // ),
      body: !_cameraEnabled
          ? const Text("Camera is disabled")
          : cameraController == null
              ? const Text("Loading camera...")
              : Stack(fit: StackFit.loose, children: <Widget>[
                  CameraPreview(cameraController!),
                  _buildOverlayIfNeeded(),
                  _buildAlertDialogIfNeeded(),
                ]),
      floatingActionButton:
          Column(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
        FloatingActionButton(
          onPressed: () {
            setState(() {
              _drawEnabled = !_drawEnabled;
            });
          },
          backgroundColor: Colors.blue,
          child: const Icon(Icons.document_scanner),
        )
      ]),
    );
  }
}
