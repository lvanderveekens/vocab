import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:megaphone/text_decorator_painter.dart';

// useful links:
// https://www.fluttercampus.com/guide/266/show-live-image-preview-camera-flutter/
// https://medium.flutterdevs.com/text-recognition-with-ml-kit-flutter-c71f27089437

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
  bool _textScanningEnabled = false;
  bool _isDetecting = false;
  bool _initialized = false;
  bool _isRecognizing = false;
  RecognizedText? _recognizedText;
  bool _cameraEnabled = true;
  File? imageFile;

  @override
  void initState() {
    super.initState();
    loadCamera();
  }

  Uint8List _concatenatePlanes(List<Plane> planes) {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }

  // Future<void> recognizeText(CameraImage cameraImage) async {
  //   final inputImage = InputImage.fromBytes(
  //       bytes: _concatenatePlanes(cameraImage.planes),
  //       inputImageData: InputImageData(
  //           size: Size(
  //               cameraImage.width.toDouble(), cameraImage.height.toDouble()),
  //           imageRotation: InputImageRotation.rotation0deg,
  //           inputImageFormat: InputImageFormat.bgra8888,
  //           planeData: cameraImage.planes.map(
  //             (Plane plane) {
  //               return InputImagePlaneMetadata(
  //                 bytesPerRow: plane.bytesPerRow,
  //                 height: plane.height,
  //                 width: plane.width,
  //               );
  //             },
  //           ).toList()));

  //   final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  //   final RecognizedText recognizedText =
  //       await textRecognizer.processImage(inputImage);

  //   _recognizedText = recognizedText.text;
  //   textRecognizer.close();
  // }

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
              log("CLICKED ON: ${element.text}");
            }
          }
        }
      }
    };
  }

  handleCameraPreviewTapUp(TapUpDetails details) {
    log("handle camera preview tap up!");
    // on tap: take picture and show picture until tapped again
    if (imageFile != null) {
      setState(() {
        imageFile = null;
      });
      return;
    }

    // or user the local position method to get the offset
    log("${details.localPosition}");
    var x = details.globalPosition.dx;
    var y = details.globalPosition.dy;
    log("global " + x.toString() + ", " + y.toString());

    cameraController!.takePicture().then((file) async {
      // final imageFile = File(file.path);

      final img.Image? capturedImage =
          img.decodeImage(await File(file.path).readAsBytes());
      final img.Image orientedImage = img.bakeOrientation(capturedImage!);
      await File(file.path).writeAsBytes(img.encodeJpg(orientedImage));

      final imageFile = File(file.path);

      setState(() {
        this.imageFile = imageFile;
      });
    });
  }

  Future<MyResult?> getAap(File? imageFile) async {
    if (imageFile == null) {
      return null;
    }

    final bs = await imageFile.readAsBytes();

    final uiImage = await decodeImageFromList(bs);
    log("image " + uiImage.width.toString() + " " + uiImage.height.toString());

    final inputImage = InputImage.fromFile(imageFile);

    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

    log(">>> RECOGNIZED TEXT");
    log(recognizedText.text);
    log("<<< RECOGNIZED TEXT");

    textRecognizer.close();

    final imageSize = Size(uiImage.width.toDouble(), uiImage.height.toDouble());
    log("image size");
    log("$imageSize");

    return MyResult(imageSize, recognizedText);
  }

  _buildOverlayIfNeeded() {
    if (_recognizedText == null) {
      return Container();
    }

    // TODO: no static image size
    final imageSize = Size(720, 1280);

    final painter = TextDetectorPainter(imageSize, _recognizedText!);

    // scaling only works because custom paint size and image size have the same aspect ratio
    // TODO: no static custom paint size
    final Size customPaintSize = Size(390.0, 693.3);
    final double scaleX = customPaintSize.width / imageSize.width;
    final double scaleY = customPaintSize.height / imageSize.height;

    return GestureDetector(
        onTapUp: handleOverlayTapUp(scaleX, scaleY),
        child: CustomPaint(painter: painter, size: customPaintSize));
  }

  Widget getCameraPreviewWidget(context) {
    final size = MediaQuery.of(context).size;

    return Stack(fit: StackFit.loose, children: <Widget>[
      Container(
          width: size.width,
          child: GestureDetector(
              // onTapUp: handleCameraPreviewTapUp,
              child: CameraPreview(cameraController!))),
      // ))),
      _buildOverlayIfNeeded(),
    ]);
    // ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   title: Text(widget.title!),
        // ),
        body: cameraController == null
            ? const Text("Loading Camera...")
            : getCameraPreviewWidget(context),
        floatingActionButton:
            Column(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
          FloatingActionButton(
            onPressed: () {
              setState(() {
                _textScanningEnabled = !_textScanningEnabled;
              });
            },
            backgroundColor: Colors.blue,
            child: const Icon(Icons.document_scanner),
          ),
          Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _cameraEnabled = !_cameraEnabled;
                  });

                  if (_cameraEnabled) {
                    loadCamera();
                  } else {
                    unloadCamera();
                  }
                },
                backgroundColor: Colors.blue,
                child: const Icon(Icons.camera_alt),
              ))
        ]));
  }
}

class MyResult {
  Size imageSize;
  RecognizedText recognizedText;

  MyResult(this.imageSize, this.recognizedText);
}
