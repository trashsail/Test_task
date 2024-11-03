import 'dart:io';

import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class CameraModel {
  late CameraController _cameraController;
  bool isCameraInitialized = false;

  Future<void> initializeCamera(CameraDescription cameraDescription) async {
    _cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.max,
    );
    try {
      await _cameraController.initialize();
      isCameraInitialized = true;
    } catch (e) {
      isCameraInitialized = false;
      throw Exception('Ошибка при инициализации камеры $e');
    }
  }

  Future<XFile?> captureImage() async {
    if (isCameraInitialized) {
      try {
        final XFile imageFile = await _cameraController.takePicture();

        var jpegBytes = await imageFile.readAsBytes();
        var image = img.decodeJpg(jpegBytes);

        if (image != null) {
          var resizedImage = img.copyResize(image, width: 800);

          var compressedJpegBytes = img.encodeJpg(resizedImage, quality: 80);

          final directory = await getTemporaryDirectory();
          final newFilePath = '${directory.path}/test.jpg';

          await File(newFilePath).writeAsBytes(compressedJpegBytes);

          await File(imageFile.path).delete();

          return XFile(newFilePath);
        }
      } catch (e) {
        throw Exception('Ошибка при захвате изображения: $e');
      }
    }
    return null;
  }

  Future<void> disposeCamera() async {
    if (isCameraInitialized) {
      await _cameraController.dispose();
    }
  }

  CameraController get cameraController => _cameraController;
}
