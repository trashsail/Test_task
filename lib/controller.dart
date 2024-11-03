import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

import 'package:with_camera/camera/camera_model.dart';

class ControllerOfCamera extends ChangeNotifier {
  final CameraModel _cameraModel = CameraModel();

  String description = '';

  bool isInitialized = false;

  double? lat = 0.0;
  double? lon = 0.0;

  CameraController get cameraController => _cameraModel.cameraController;

  Future<void> initializeCamera(CameraDescription cameraDescription) async {
    await _cameraModel.initializeCamera(cameraDescription);
    isInitialized = true;
    notifyListeners();
  }

  Future<void> disposedCamera() async {
    await _cameraModel.disposeCamera();
    notifyListeners();
  }

  Future<Map<String, dynamic>> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
      };
    } catch (e) {
      throw Exception('Ошибка при получении местоположения: $e');
    }
  }

  Future<void> takeDescription(String input) async {
    description = input;
    notifyListeners();
  }

  Future<void> uploadPhoto() async {
    try {
      Map<String, dynamic> location = await _getCurrentLocation();
      lat = location['latitude'];
      lon = location['longitude'];

      final XFile? imageFile = await _cameraModel.captureImage();

      await takeDescription(description);

      if (imageFile != null) {
        await _postPhoto(imageFile);
      } else {
        throw Exception('Не удалось захватить изображение');
      }
    } catch (e) {
      throw Exception('Ошибка при отправке фото: $e');
    }
  }

  Future<void> _postPhoto(XFile imageFile) async {
    try {
      final url =
          Uri.parse('https://myproject.free.beeceptor.com/upload_photo');

      final req = http.MultipartRequest('POST', url)
        ..fields['comment'] = description
        ..fields['latitude'] = lat.toString()
        ..fields['longitude'] = lon.toString()
        ..files.add(await http.MultipartFile.fromPath(
          'photo',
          imageFile.path,
        ));
      final streamedResponse = await req.send();

      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        debugPrint('Uploaded: ${response.statusCode}');
      } else {
        debugPrint('Upload failed with status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Ошибка отправки запроса на сервер: $e');
      throw Exception('Ошибка отправки запроса на сервер: $e');
    }
  }
}
