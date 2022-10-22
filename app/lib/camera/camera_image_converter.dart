import 'package:camera/camera.dart';
import 'package:image/image.dart';

List<int> convertToPng(CameraImage image) {
  try {
    Image? img2;
    if (image.format.group == ImageFormatGroup.yuv420) {
      // ANDROID
      img2 = _fromYUV420(image);
    } else if (image.format.group == ImageFormatGroup.bgra8888) {
      // IOS
      img2 = _fromBGRA8888(image);
    }
    PngEncoder pngEncoder = new PngEncoder();

    // Convert to png
    return pngEncoder.encodeImage(img2!);
  } catch (e) {
    print(">>>>>>>>>>>> ERROR:" + e.toString());
  }
  return [];
}

/// CameraImage BGRA8888 -> PNG
/// Color
Image _fromBGRA8888(CameraImage image) {
  return Image.fromBytes(
    (image.planes[0].bytesPerRow / 4).round(),
    image.height,
    image.planes[0].bytes,
    format: Format.bgra,
  );
}

/// CameraImage YUV420_888 -> PNG -> Image (compresion:0, filter: none)
/// Black
Image _fromYUV420(CameraImage image) {
  var img2 = Image(image.width, image.height); // Create Image buffer

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
      var newVal = shift | (pixelColor << 16) | (pixelColor << 8) | pixelColor;

      img2.data[planeOffset + x] = newVal;
    }
  }

  return img2;
}
