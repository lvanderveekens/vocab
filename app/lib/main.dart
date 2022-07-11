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
  String? _recognizedText;
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

  Future<void> recognizeText(CameraImage cameraImage) async {
    final inputImage = InputImage.fromBytes(
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

    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

    _recognizedText = recognizedText.text;
    textRecognizer.close();
  }

  loadCamera() async {
    log("@>loadCamera");
    cameras = await availableCameras();
    if (cameras != null) {
      cameraController = CameraController(cameras![0], ResolutionPreset.max);

      cameraController!.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {
          _initialized = true;
        });

        // TODO: is this needed?
        cameraController!.lockCaptureOrientation(DeviceOrientation.portraitUp);
      });
    } else {
      log("No cameras found");
    }
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

  handleTapUp(TapUpDetails details) {
    // on tap: take picture and show picture until tapped again
    if (imageFile != null) {
      setState(() {
        imageFile = null;
      });
      return;
    }

    // or user the local position method to get the offset
    print(details.localPosition);
    var x = details.globalPosition.dx;
    var y = details.globalPosition.dy;
    print("global " + x.toString() + ", " + y.toString());

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
    print(
        "image " + uiImage.width.toString() + " " + uiImage.height.toString());

    final inputImage = InputImage.fromFile(imageFile);

    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

    print(">>> RECOGNIZED TEXT");
    print(recognizedText.text);
    print("<<< RECOGNIZED TEXT");

    textRecognizer.close();

    final imageSize = Size(uiImage.width.toDouble(), uiImage.height.toDouble());
    print("image size");
    print(imageSize);

    return MyResult(imageSize, recognizedText);
  }

  _buildOverlayIfNeeded(File? imageFile) {
    return FutureBuilder(
        future: getAap(imageFile),
        builder: (BuildContext context, AsyncSnapshot<MyResult?> myResult) {
          if (myResult.data == null) {
            return Container();
          }

          print("draw it");
          final absoluteImageSize = myResult.data!.imageSize;
          final recognizedText = myResult.data!.recognizedText;
          print("absolute image size");
          print(absoluteImageSize);
          print("recognizedText");
          print(recognizedText);

          final painter =
              TextDetectorPainter(absoluteImageSize, recognizedText);

          print("futureBuilder()");
          // print(context.size);

          return CustomPaint(painter: painter, size: Size(390.0, 693.3));
        });

    // recognizedText.blocks.forEach((block) {
    //   block.lines.forEach((line) {
    //     line.elements.forEach((element) {
    //       if (element.text == "gaan") {
    //         print("'gaan' found");
    //         print(element.boundingBox);
    //       }
    //     });
    //   });
    // });
  }

  Widget getCameraPreviewWidget(context) {
    final size = MediaQuery.of(context).size;

    return Stack(fit: StackFit.loose, children: <Widget>[
      Container(
          width: size.width,
          // height: size.height,
          // child: FittedBox(
          // fit: BoxFit.contain, // TODO: change to 'cover' later...
          // child: Container(
          // width: size.width,
          child: GestureDetector(
              onTapUp: handleTapUp,
              child: imageFile != null
                  ? Image.file(imageFile!)
                  : CameraPreview(cameraController!))),
      // ))),
      _buildOverlayIfNeeded(imageFile),
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
