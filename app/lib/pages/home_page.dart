import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
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

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List<CameraDescription>? cameras;
  CameraController? cameraController;
  bool _isDetecting = false;
  bool isCameraInitialized = false;
  bool _isRecognizing = false;

  bool _showAlertDialog = false;
  List<Widget> _alertDialogChildren = [];

  bool _cameraEnabled = true;
  bool _realTimeScanningEnabled = false;
  bool _translationEnabled = false;

  bool _processingCameraImage = false;

  RecognizedText? _recognizedText;

  TapUpDetails? _tapUpDetails;
  bool _processNextCameraImage = false;

  Size? _cameraImageSize;

  @override
  void initState() {
    super.initState();

    if (_cameraEnabled) {
      loadCamera();
    }
  }

  @override
  void dispose() {
    super.dispose();

    if (cameraController != null) {
      cameraController!.dispose();
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

    final camera = cameras![0]; // TODO: try other cameras?
    cameraController = CameraController(camera, ResolutionPreset.high);

    await cameraController!.initialize();

    if (!mounted) {
      return;
    }
    setState(() {
      isCameraInitialized = true;
    });

    cameraController!.startImageStream((CameraImage cameraImage) {
      if (_processingCameraImage) {
        return;
      }
      if (!_processNextCameraImage && !_realTimeScanningEnabled) {
        return;
      }

      _processingCameraImage = true;
      _processNextCameraImage = false;

      log("Started processsing camera image (${cameraImage.width}, ${cameraImage.height})");

      _cameraImageSize =
          Size(cameraImage.width.toDouble(), cameraImage.height.toDouble());

      log("Recognizing text...");
      recognizeText(cameraImage).then((recognizedText) async {
        setState(() {
          _recognizedText = recognizedText;
        });

        if (_tapUpDetails != null) {
          log("Processing tap location: (${_tapUpDetails!.localPosition.dx}, ${_tapUpDetails!.localPosition.dy})");
          await checkTapLocation(
                  _tapUpDetails!, recognizedText, _cameraImageSize!)
              .whenComplete(() => _tapUpDetails = null);
        }
      }).whenComplete(() {
        log("Done processing");
        _processingCameraImage = false;
      });
    });
  }

  Future<void> checkTapLocation(TapUpDetails tapUpDetails,
      RecognizedText recognizedText, Size cameraImageSize) async {
    final cameraPreviewSize = cameraPreviewKey.currentContext!.size!;

    log("Camera image (${cameraImageSize.width},${cameraImageSize.height})");
    log("Camera image aspect ratio ${cameraImageSize.width / cameraImageSize.height}");
    log("Camera preview (${cameraPreviewSize.width},${cameraPreviewSize.height})");
    log("Camera preview aspect ratio ${cameraPreviewSize.width / cameraPreviewSize.height}");

    // // NOTE: scaling only works if the aspect ratios match
    // final double scaleX = cameraPreviewSize.width / cameraImageSize.width;
    // final double scaleY = cameraPreviewSize.height / cameraImageSize.height;

    var x = tapUpDetails.localPosition.dx;
    var y = tapUpDetails.localPosition.dy;

    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        for (TextElement element in line.elements) {
          // final scaledBoundingBox =
          //     scaleRect(element.boundingBox, scaleX, scaleY);

          if (element.boundingBox.contains(tapUpDetails.localPosition)) {
            log("Tapped on: ${element.text}");

            final tappedText = element.text;
            String? translation;
            final recognizedLanguages = block.recognizedLanguages;

            if (_translationEnabled && recognizedLanguages.isNotEmpty) {
              final recognizedLanguage = recognizedLanguages[0];
              if (recognizedLanguage != "en") {
                log("Translating...");
                translation =
                    await translate(tappedText, recognizedLanguage, "en");

                log("Translation: $translation");
              }
            }

            setState(() {
              _alertDialogChildren = [
                Text('Tapped on: $tappedText'),
                Text('English translation: $translation'),
                Text('Recognized languages: $recognizedLanguages'),
              ];
              _showAlertDialog = true;
            });

            return;
          }
        }
      }
    }
    log("User did not tap on a word.");
    setState(() {
      _alertDialogChildren = [const Text('No word found...')];
      _showAlertDialog = true;
    });
  }

  // Rect scaleRect(Rect boundingBox, double scaleX, double scaleY) {
  //   return Rect.fromLTRB(
  //     boundingBox.left * scaleX,
  //     boundingBox.top * scaleY,
  //     boundingBox.right * scaleX,
  //     boundingBox.bottom * scaleY,
  //   );
  // }

  Future<RecognizedText> recognizeText(CameraImage cameraImage) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    return await textRecognizer.processImage(convertToInputImage(cameraImage));
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

  handleCameraWidgetTapUp() {
    return (TapUpDetails tapUpDetails) {
      _tapUpDetails = tapUpDetails;
      _processNextCameraImage = true;
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
      throw Exception(
          'Failed to call Google Cloud Translation API: ${response.body}');
    }

    final googleTranslationResponse =
        GoogleTranslationResponse.fromJson(jsonDecode(response.body));

    return googleTranslationResponse.data.translations[0].translatedText;
  }

  Widget _buildAlertDialogIfNeeded() {
    if (!_showAlertDialog) {
      return Container();
    }

    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _alertDialogChildren,
      ),
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

  Widget _buildRealTimeScannerIfNeeded() {
    if (!_realTimeScanningEnabled ||
        _recognizedText == null ||
        _cameraImageSize == null) {
      return Container();
    }

    final painter = TextDetectorPainter(_cameraImageSize!, _recognizedText!);
    return CustomPaint(painter: painter);
  }

  final cameraPreviewKey = GlobalKey();

  Widget _buildCameraWidget() {
    if (!isCameraInitialized) {
      return Text("Camera not initialized yet");
    }

    // somehow the camera sensor orientation is 90 which messes up the aspect ratio field...
    // the logic below is a workaround...
    final cameraPreviewWidth = math.min(
        cameraController!.value.previewSize!.width,
        cameraController!.value.previewSize!.height);
    final cameraPreviewHeight = math.max(
        cameraController!.value.previewSize!.width,
        cameraController!.value.previewSize!.height);

    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: FittedBox(
            fit: BoxFit.cover,
            child: GestureDetector(
                onTapUp: handleCameraWidgetTapUp(),
                child: SizedBox(
                    width: cameraPreviewWidth,
                    height: cameraPreviewHeight,
                    child: Stack(fit: StackFit.expand, children: <Widget>[
                      CameraPreview(cameraController!, key: cameraPreviewKey),
                      _buildRealTimeScannerIfNeeded()
                    ])))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: !_cameraEnabled
          ? const Text("Camera is disabled")
          : cameraController == null
              ? const Text("Loading camera...")
              : Stack(fit: StackFit.loose, children: <Widget>[
                  _buildCameraWidget(),
                  _buildAlertDialogIfNeeded(),
                ]),
      floatingActionButton:
          Column(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
        FloatingActionButton(
          onPressed: () {
            setState(() {
              _realTimeScanningEnabled = !_realTimeScanningEnabled;
            });
          },
          backgroundColor: _realTimeScanningEnabled ? Colors.blue : Colors.red,
          child: const Icon(Icons.document_scanner),
        ),
        FloatingActionButton(
          onPressed: () {
            setState(() {
              _translationEnabled = !_translationEnabled;
            });
          },
          backgroundColor: _translationEnabled ? Colors.blue : Colors.red,
          child: const Icon(Icons.translate),
        ),
      ]),
    );
  }
}
