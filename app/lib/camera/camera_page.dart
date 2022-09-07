import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:vocab/camera/info_dialog.dart';
import 'package:vocab/language/language.dart';
import 'package:vocab/camera/tap_dialog.dart';
import 'package:vocab/secret/secrets.dart';
import 'package:vocab/camera/text_decorator_painter.dart';
import 'package:vocab/text_recognition/text_recognition_languages.dart';
import 'package:vocab/translation/google_translation_languages.dart';
import 'package:vocab/user/user_preferences_storage.dart';
import 'package:vocab/widgets/bullet_text.dart';

import '../deck/deck_storage.dart';

class CameraPage extends StatefulWidget {
  final DeckStorage deckStorage;
  final UserPreferencesStorage userPreferencesStorage;
  final List<GoogleTranslationLanguage> googleTranslationLanguages;
  final List<TextRecognitionLanguage> textRecognitionLanguages;

  const CameraPage({
    Key? key,
    required this.deckStorage,
    required this.userPreferencesStorage,
    required this.googleTranslationLanguages,
    required this.textRecognitionLanguages,
  }) : super(key: key);

  @override
  State<CameraPage> createState() => CameraPageState();
}

class CameraPageState extends State<CameraPage> {
  List<CameraDescription>? cameras;
  CameraController? cameraController;
  bool _isDetecting = false;
  bool _isRecognizing = false;

  bool _cameraEnabled = true;
  bool _cameraAvailable = true;
  bool _cameraInitialized = false;
  bool _realTimeScanningEnabled = false;
  bool _translationEnabled = true;

  bool _processingCameraImage = false;

  RecognizedText? _recognizedText;

  TapUpDetails? _tapUpDetails;
  bool _processNextCameraImage = false;

  CameraImage? _cameraImage;
  Size? _cameraImageSize;

  bool _showTapDialog = false;
  String? _tappedOnWord;

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

    if (cameras!.isEmpty) {
      setState(() {
        _cameraAvailable = false;
      });
      return;
    }

    final camera = cameras![0]; // TODO: try other cameras?
    cameraController =
        CameraController(camera, ResolutionPreset.high, enableAudio: false);

    await cameraController!.initialize();
    await cameraController!.lockCaptureOrientation();

    setState(() {
      _cameraInitialized = true;
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

      _cameraImage = cameraImage;

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

  void _processCameraImage() {}

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

    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        for (TextElement element in line.elements) {
          // final scaledBoundingBox =
          //     scaleRect(element.boundingBox, scaleX, scaleY);

          if (element.boundingBox.contains(tapUpDetails.localPosition)) {
            log("Tapped on: ${element.text}");

            final tappedOnWord = element.text;
            return showTapDialog(tappedOnWord);
          }
        }
      }
    }
    log("User did not tap on a word.");
    return showTapDialog(null);
  }

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

  Widget _buildRealTimeScannerIfNeeded() {
    if (!_realTimeScanningEnabled ||
        _recognizedText == null ||
        _cameraImageSize == null) {
      return Container();
    }

    final painter = TextDetectorPainter(
      _cameraImageSize!,
      _recognizedText!,
      [],
    );
    return CustomPaint(painter: painter);
  }

  final cameraPreviewKey = GlobalKey();

  Widget _buildCameraPreviewNotAvailable({required String message}) {
    return Container(
      child: Center(
          child: Text(
        message,
        style: TextStyle(color: Colors.white),
      )),
      color: Colors.grey,
    );
  }

  Widget _buildCameraPreview() {
    if (!_cameraEnabled) {
      return _buildCameraPreviewNotAvailable(
        message: "Camera is disabled.",
      );
    }

    if (!_cameraAvailable) {
      return _buildCameraPreviewNotAvailable(
        message: "Camera not available.",
      );
    }

    if (!_cameraInitialized) {
      log("Camera not initialized yet.");
      return Container(
        color: Colors.black,
      );
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
            child: _cameraImage != null
                ? _buildFrozenImage(_cameraImage!)
                : GestureDetector(
                    onTapUp: handleCameraWidgetTapUp(),
                    child: SizedBox(
                        width: cameraPreviewWidth,
                        height: cameraPreviewHeight,
                        child: Stack(fit: StackFit.expand, children: <Widget>[
                          CameraPreview(cameraController!,
                              key: cameraPreviewKey),
                          _buildRealTimeScannerIfNeeded()
                        ])))));
  }

  Widget _buildFrozenImage(CameraImage cameraImage) {
    return SizedBox(
      width: cameraImage.width.toDouble(),
      height: cameraImage.height.toDouble(),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.memory(Uint8List.fromList(convertToPng(_cameraImage!))),
          _buildTextDetectionOverlay(),
        ],
      ),
    );
  }

  Widget _buildTextDetectionOverlay() {
    return TextDetectionOverlay(
      cameraImageSize: _cameraImageSize!,
      recognizedText: _recognizedText!,
    );
  }

  Widget _buildUsageTip() {
    return Container(
        alignment: Alignment.bottomCenter,
        width: double.infinity,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: const Text(
            "Point the camera at a word and tap it",
            // textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.0, color: Colors.white),
          ),
        ));
  }

  Widget _buildInfoIcon() {
    return Container(
        alignment: Alignment.topRight,
        width: double.infinity,
        child: Container(
          child: IconButton(
            padding: EdgeInsets.all(16.0),
            icon: Icon(Icons.info, color: Colors.white),
            iconSize: 32.0,
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (ctx) => InfoDialog(
                        onClose: () {
                          log("dialog onClose called");
                          Navigator.pop(context);
                        },
                        textRecognitionLanguages:
                            widget.textRecognitionLanguages,
                      ));
            },
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(fit: StackFit.loose, children: <Widget>[
        _buildCameraPreview(),
        _buildUsageTip(),
        _buildInfoIcon(),
      ]),
      floatingActionButton: kDebugMode ? _buildDebugActions() : null,
    );
  }

  Widget _buildDebugActions() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        FloatingActionButton.extended(
            onPressed: () {
              showTapDialog("ape");
            },
            backgroundColor: Colors.blue,
            icon: const Icon(Icons.document_scanner),
            label: const Text("Test tap")),
        FloatingActionButton.extended(
            onPressed: () {
              setState(() {
                _realTimeScanningEnabled = !_realTimeScanningEnabled;
              });
            },
            backgroundColor:
                _realTimeScanningEnabled ? Colors.green : Colors.red,
            icon: const Icon(Icons.document_scanner),
            label: const Text("Real-time scanning")),
        FloatingActionButton.extended(
            onPressed: () {
              setState(() {
                _translationEnabled = !_translationEnabled;
              });
            },
            backgroundColor: _translationEnabled ? Colors.green : Colors.red,
            icon: const Icon(Icons.translate),
            label: const Text("Translation")),
        Container(margin: EdgeInsets.only(bottom: 80))
      ],
    );
  }

  void showTapDialog(String? tappedOnWord) {
    if (tappedOnWord != null) {
      tappedOnWord = _stripInterpunction(tappedOnWord);
    }

    showDialog(
        context: context,
        builder: (ctx) => TapDialog(
              onClose: () {
                log("dialog onClose called");
                Navigator.pop(context);
              },
              tappedOnWord: tappedOnWord,
              deckStorage: widget.deckStorage,
              translationEnabled: _translationEnabled,
              userPreferencesStorage: widget.userPreferencesStorage,
              googleTranslationLanguages: widget.googleTranslationLanguages,
            ));
  }

  String _stripInterpunction(String s) {
    return s.replaceAll(RegExp(r'[.,:;\?!]'), '');
  }

  /// imgLib -> Image package from https://pub.dartlang.org/packages/image
  static List<int> convertToPng(CameraImage image) {
    try {
      img.Image? img2;
      if (image.format.group == ImageFormatGroup.yuv420) {
        // ANDROID
        img2 = _fromYUV420(image);
      } else if (image.format.group == ImageFormatGroup.bgra8888) {
        // IOS
        img2 = _fromBGRA8888(image);
      }
      img.PngEncoder pngEncoder = new img.PngEncoder();

      // Convert to png
      return pngEncoder.encodeImage(img2!);
    } catch (e) {
      print(">>>>>>>>>>>> ERROR:" + e.toString());
    }
    return [];
  }

  /// CameraImage BGRA8888 -> PNG
  /// Color
  static img.Image _fromBGRA8888(CameraImage image) {
    return img.Image.fromBytes(
      (image.planes[0].bytesPerRow / 4).round(),
      image.height,
      image.planes[0].bytes,
      format: img.Format.bgra,
    );
  }

  /// CameraImage YUV420_888 -> PNG -> Image (compresion:0, filter: none)
  /// Black
  static img.Image _fromYUV420(CameraImage image) {
    var img2 = img.Image(image.width, image.height); // Create Image buffer

    Plane plane = image.planes[0];
    const int shift = (0xFF << 24);

    // Fill image buffer with plane[0] from YUV420_888
    for (int x = 0; x < image.width; x++) {
      for (int planeOffset = 0;
          planeOffset < image.height * image.width;
          planeOffset += image.width) {
        final pixelColor = plane.bytes[planeOffset + x];
        // color: 0x FF  FF  FF  FF
        //           A   B   G   R
        // Calculate pixel color
        var newVal =
            shift | (pixelColor << 16) | (pixelColor << 8) | pixelColor;

        img2.data[planeOffset + x] = newVal;
      }
    }

    return img2;
  }
}

class TextDetectionOverlay extends StatefulWidget {
  final Size cameraImageSize;
  final RecognizedText recognizedText;

  const TextDetectionOverlay(
      {required this.cameraImageSize, required this.recognizedText});

  @override
  State<TextDetectionOverlay> createState() => TextDetectionOverlayState();
}

class TextDetectionOverlayState extends State<TextDetectionOverlay> {
  List<SelectedTextElement> _selectedTextElements = [];

  @override
  Widget build(BuildContext context) {
    log("selected text: ${_getSelectedText()}");

    return GestureDetector(
      onPanStart: (DragStartDetails details) {
        log("onPanStart");
        setState(() {
          _selectedTextElements = [];
        });
        _handleDragPosition(details.localPosition);
      },
      onPanUpdate: (DragUpdateDetails details) {
        _handleDragPosition(details.localPosition);
      },
      child: CustomPaint(
          painter: TextDetectorPainter(
        widget.cameraImageSize,
        widget.recognizedText,
        _selectedTextElements.map((e) => e.textElement.boundingBox).toList(),
      )),
    );
  }

  String _getSelectedText() {
    _selectedTextElements.sort((a, b) {
      final compared = a.textLine.boundingBox.topLeft.dy
          .compareTo(b.textLine.boundingBox.topLeft.dy);
      if (compared != 0) {
        return compared;
      }

      return a.textElement.boundingBox.topLeft.dx
          .compareTo(b.textElement.boundingBox.topLeft.dx);
    });
    return _selectedTextElements.map((ste) => ste.textElement.text).join(" ");
  }

  void _handleDragPosition(Offset dragPosition) {
    for (TextBlock textBlock in widget.recognizedText.blocks) {
      for (TextLine textLine in textBlock.lines) {
        for (TextElement textElement in textLine.elements) {
          if (textElement.boundingBox.contains(dragPosition)) {
            log("Dragging over: ${textElement.text}");

            if (!_selectedTextElements
                .any((ste) => ste.textElement == textElement)) {
              setState(() {
                log("setting state");

                // TODO: add line too

                _selectedTextElements = List.from(_selectedTextElements)
                  ..add(SelectedTextElement(
                      textElement: textElement, textLine: textLine));
              });
            }

            return;
          }
        }
      }
    }
  }
}

class SelectedTextElement {
  final TextElement textElement;
  final TextLine textLine;

  SelectedTextElement({
    required this.textElement,
    required this.textLine,
  });
}
