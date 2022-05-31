import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

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

  dynamic _pickImageError;
  bool isVideo = false;

  VideoPlayerController? _controller;
  VideoPlayerController? _toBeDisposed;
  String? _retrieveDataError;

  final ImagePicker _picker = ImagePicker();
  final TextEditingController maxWidthController = TextEditingController();
  final TextEditingController maxHeightController = TextEditingController();
  final TextEditingController qualityController = TextEditingController();

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

      //cameras[0] = first camera, change to 1 to another camera

      // cameraController!.value.aspectRatio
      cameraController!.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {
          _initialized = true;
        });

        // cameraController!.startImageStream((CameraImage image) {
        //   log("processing image");
        //   if (_isDetecting) return;

        //   if (_textScanningEnabled) {
        //     setState(() {
        //       _isDetecting = true;
        //     });

        //     log("will recognize text");
        //     recognizeText(image).whenComplete(() => _isDetecting = false);
        //   }
        // });
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

  void _setImageFileListFromFile(XFile? value) {
    _imageFileList = value == null ? null : <XFile>[value];
  }

  @override
  void dispose() {
    _disposeVideoController();
    maxWidthController.dispose();
    maxHeightController.dispose();
    qualityController.dispose();
    super.dispose();
  }

  Future<void> _disposeVideoController() async {
    if (_toBeDisposed != null) {
      await _toBeDisposed!.dispose();
    }
    _toBeDisposed = _controller;
    _controller = null;
  }

  Widget getCameraPreviewWidget(context) {
    final size = MediaQuery.of(context).size;

    return Container(
        width: size.width,
        height: size.height,
        child: FittedBox(
            fit: BoxFit.contain,
            child: Container(
              width: 100,
              child: GestureDetector(
                  onTapUp: (TapUpDetails details) {
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
                      final imageFile = File(file.path);
                      setState(() {
                        this.imageFile = imageFile;
                      });

                      file.readAsBytes().then((bs) {
                        decodeImageFromList(bs).then((uiImage) {
                          print("image " +
                              uiImage.width.toString() +
                              " " +
                              uiImage.height.toString());
                        });
                      });

                      final inputImage = InputImage.fromFile(imageFile);

                      final textRecognizer =
                          TextRecognizer(script: TextRecognitionScript.latin);

                      final RecognizedText recognizedText =
                          await textRecognizer.processImage(inputImage);

                      recognizedText.blocks.forEach((block) {
                        block.lines.forEach((line) {
                          line.elements.forEach((element) {
                            if (element.text == "gaan") {
                              print("'gaan' found");
                              print(element.boundingBox);
                            }
                          });
                        });
                      });

                      // textRecognizer.close();
                    });
                  },
                  child: imageFile != null
                      ? Image.file(imageFile!)
                      : CameraPreview(cameraController!)),
            )));
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

  Text? _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError!);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }
}

typedef OnPickImageCallback = void Function(
    double? maxWidth, double? maxHeight, int? quality);

class AspectRatioVideo extends StatefulWidget {
  const AspectRatioVideo(this.controller, {Key? key}) : super(key: key);

  final VideoPlayerController? controller;

  @override
  AspectRatioVideoState createState() => AspectRatioVideoState();
}

class AspectRatioVideoState extends State<AspectRatioVideo> {
  VideoPlayerController? get controller => widget.controller;
  bool initialized = false;

  void _onVideoControllerUpdate() {
    if (!mounted) {
      return;
    }
    if (initialized != controller!.value.isInitialized) {
      initialized = controller!.value.isInitialized;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    controller!.addListener(_onVideoControllerUpdate);
  }

  @override
  void dispose() {
    controller!.removeListener(_onVideoControllerUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (initialized) {
      return Center(
        child: AspectRatio(
          aspectRatio: controller!.value.aspectRatio,
          child: VideoPlayer(controller!),
        ),
      );
    } else {
      return Container();
    }
  }
}
