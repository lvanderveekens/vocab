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
import 'package:get_it/get_it.dart';
import 'package:image/image.dart' as img;

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:vocab/camera/camera_image_converter.dart';
import 'package:vocab/camera/info_dialog.dart';
import 'package:vocab/camera/text_underline_painter.dart';
import 'package:vocab/deck/deck_storage.dart';
import 'package:vocab/language/language.dart';
import 'package:vocab/camera/tap_container.dart';
import 'package:vocab/secret/secrets.dart';
import 'package:vocab/camera/text_decorator_painter.dart';
import 'package:vocab/text_recognition/ml_kit_text_recognition_languages.dart';
import 'package:vocab/text_to_speech/google_cloud_text_to_speech_client.dart';
import 'package:vocab/text_to_speech/google_cloud_text_to_speech_languages.dart';
import 'package:vocab/translation/google_cloud_translation_client.dart';
import 'package:vocab/translation/google_cloud_translation_languages.dart';
import 'package:vocab/user/user_preferences.dart';
import 'package:vocab/user/user_preferences_storage.dart';
import 'package:vocab/widgets/bullet_text.dart';

class CameraPage extends StatefulWidget {
  final DeckStorage deckStorage;
  final UserPreferencesStorage userPreferencesStorage;
  final List<GoogleCloudTranslationLanguage> translationLanguages;
  final List<GoogleCloudTextToSpeechLanguage> textToSpeechLanguages;
  final List<MLKitTextRecognitionLanguage> textRecognitionLanguages;
  final UserPreferences? userPreferences;

  const CameraPage({
    Key? key,
    required this.deckStorage,
    required this.userPreferencesStorage,
    required this.translationLanguages,
    required this.textRecognitionLanguages,
    required this.textToSpeechLanguages,
    required this.userPreferences,
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
  bool _translationEnabled = !kDebugMode;

  bool _processNextCameraImage = false;
  bool _processingCameraImage = false;
  CameraImage? _tappedCameraImage;
  Size? _cameraImageSize;
  TapUpDetails? _tapUpDetails;

  bool _showTapContainer = false;

  RecognizedText? _recognizedText;
  String? _tappedWord;
  Rect? _tappedWordRect;

  bool _showTapDialog = false;
  String? _tappedOnWord;

  @override
  void initState() {
    super.initState();

    if (_cameraEnabled) {
      loadCamera();
    }

    // WidgetsBinding.instance.addPostFrameCallback(_getSizedBoxWidgetInfo);
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

      // set guard
      _processingCameraImage = true;

      // reset
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
          log("Processing tap local location: (${_tapUpDetails!.localPosition.dx}, ${_tapUpDetails!.localPosition.dy})");
          log("Processing tap global location: (${_tapUpDetails!.globalPosition.dx}, ${_tapUpDetails!.globalPosition.dy})");
          var tappedWord = await checkTapLocation(
              _tapUpDetails!, recognizedText, _cameraImageSize!);

          if (tappedWord != null) {
            setState(() {
              _tappedCameraImage = cameraImage;
              _tappedWord = tappedWord;
              _showTapContainer = true;
            });
          }
        }
      }).whenComplete(() {
        log("Done processing camera image");
        _processingCameraImage = false;
      });
    });
  }

  Future<String?> checkTapLocation(TapUpDetails tapUpDetails,
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
            setState(() {
              _tappedWordRect = element.boundingBox;
            });
            return element.text;
          }
        }
      }
    }
    log("User did not tap on a word.");
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

  Widget _buildTextUnderlineCustomPaint(double scaleFactor) {
    final painter = TextUnderlinePainter(_tappedWordRect!, scaleFactor);
    return CustomPaint(painter: painter);
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

  Widget _buildCameraNotAvailable({required String message}) {
    return Container(
      child: Center(
          child: Text(
        message,
        style: TextStyle(color: Colors.white),
      )),
      color: Colors.grey,
    );
  }

  final GlobalKey _fittedBoxKey = GlobalKey();
  final GlobalKey _sizedBoxKey = GlobalKey();

  Widget _buildCameraWidget() {
    if (!_cameraEnabled) {
      return _buildCameraNotAvailable(message: "Camera is disabled.");
    }

    if (!_cameraAvailable) {
      return _buildCameraNotAvailable(message: "Camera not available.");
    }

    if (!_cameraInitialized) {
      log("Camera not initialized yet.");
      return Container(color: Colors.black);
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
            key: _fittedBoxKey,
            fit: BoxFit.cover,
            child: GestureDetector(
                onTapUp: handleCameraWidgetTapUp(),
                child: SizedBox(
                    key: _sizedBoxKey,
                    width: cameraPreviewWidth,
                    height: cameraPreviewHeight,
                    child: Stack(fit: StackFit.expand, children: <Widget>[
                      CameraPreview(cameraController!, key: cameraPreviewKey),
                      _buildRealTimeScannerIfNeeded()
                    ])))));
  }

  double getOverflowHeightCorrection(BoxConstraints scaffoldConstraints) {
    final parentAspectRatio =
        scaffoldConstraints.maxWidth / scaffoldConstraints.maxHeight;

    final cameraImageHeight = _cameraImageSize!.height;

    final renderedCameraImageHeight =
        _cameraImageSize!.width / parentAspectRatio;
    print(renderedCameraImageHeight);

    return (cameraImageHeight - renderedCameraImageHeight) / 2;
  }

  void _getSizedBoxWidgetInfo() {
    // if (_sizedBoxKey.currentContext == null) {
    //   return;
    // }

    // print('Size: ${size.width}, ${size.height}');

    // final Offset offset = renderBox.localToGlobal(Offset.zero);

    // print('global Offset: ${offset.dx}, ${offset.dy}');
    // print(
    //     'Position: ${(offset.dx + size.width) / 2}, ${(offset.dy + size.height) / 2}');
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
      body: LayoutBuilder(builder: (ctx, constraints) {
        return Stack(fit: StackFit.loose, children: <Widget>[
          _tappedCameraImage != null
              ? _buildCameraImage(constraints)
              : _buildCameraWidget(),
          _buildUsageTip(),
          _buildInfoIcon(),
        ]);
      }),
      // floatingActionButton: kDebugMode ? _buildDebugActions() : null,
      // floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  Widget _buildCameraImage(BoxConstraints scaffoldConstraints) {
    final scaleFactor = _getScaleFactor(scaffoldConstraints);

    // TODO: use max height to restrict tap container height
    final maxHeight = (_tappedWordRect?.top ?? 0) -
        getOverflowHeightCorrection(scaffoldConstraints);

    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _tappedCameraImage!.width.toDouble(),
            height: _tappedCameraImage!.height.toDouble(),
            child: Stack(fit: StackFit.expand, children: <Widget>[
              Image.memory(
                  Uint8List.fromList(convertToPng(_tappedCameraImage!))),
              _buildTextUnderlineCustomPaint(scaleFactor),
              GestureDetector(
                onTap: () {
                  // tapped outside tap container
                  setState(() {
                    _showTapContainer = false;
                    _tappedCameraImage = null;
                    _tapUpDetails = null;
                  });
                },
              ),
              _showTapContainer
                  ? Positioned(
                      left: 0,
                      right: 0,
                      bottom: _cameraImageSize!.height - _tappedWordRect!.top,
                      child: Container(
                        margin: EdgeInsets.all(16.0 * scaleFactor),
                        // color: Colors.yellow,
                        child: buildTapContainer(
                          _tappedWord!,
                          scaleFactor,
                          maxHeight,
                        ),
                      ))
                  : Container(),
            ]),
          ),
        ));
  }

  double _getScaleFactor(BoxConstraints scaffoldConstraints) {
    return _cameraImageSize!.width / scaffoldConstraints.maxWidth;
  }

  Widget _buildDebugActions() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        FloatingActionButton.extended(
            onPressed: () {
              // TODO
              // showTapDialog("monkey");
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
      ],
    );
  }

  Widget buildTapContainer(
      String tappedWord, double scaleFactor, double maxHeight) {
    // TODO: use max height
    return TapContainer(
      onClose: () {
        log("dialog onClose called");
        // TODO
        //         setState(() {
        //   _tappedCameraImage = null;
        //   _tapUpDetails = null;
        // });
      },
      tappedWord: _stripInterpunction(tappedWord),
      deckStorage: widget.deckStorage,
      translationEnabled: _translationEnabled,
      userPreferencesStorage: widget.userPreferencesStorage,
      translationLanguages: widget.translationLanguages,
      textToSpeechLanguages: widget.textToSpeechLanguages,
      userPreferences: widget.userPreferences,
      googleCloudTranslationClient: GetIt.I<GoogleCloudTranslationClient>(),
      googleCloudTextToSpeechClient: GetIt.I<GoogleCloudTextToSpeechClient>(),
      scaleFactor: scaleFactor,
    );
  }

  // void showTapDialog(String tappedWord) {
  //   showDialog(
  //       context: context,
  //       builder: (ctx) => TapContainer(
  //             onClose: () {
  //               log("dialog onClose called");
  //               Navigator.pop(context);
  //             },
  //             tappedWord: _stripInterpunction(tappedWord),
  //             deckStorage: widget.deckStorage,
  //             translationEnabled: _translationEnabled,
  //             userPreferencesStorage: widget.userPreferencesStorage,
  //             translationLanguages: widget.translationLanguages,
  //             textToSpeechLanguages: widget.textToSpeechLanguages,
  //             userPreferences: widget.userPreferences,
  //             googleCloudTranslationClient:
  //                 GetIt.I<GoogleCloudTranslationClient>(),
  //             googleCloudTextToSpeechClient:
  //                 GetIt.I<GoogleCloudTextToSpeechClient>(),
  //           )).whenComplete(() {
  //     setState(() {
  //       _tappedCameraImage = null;
  //       _tapUpDetails = null;
  //     });
  //   });
  // }

  String _stripInterpunction(String s) {
    return s.replaceAll(RegExp(r'[.,:;\?!]'), '');
  }
}
