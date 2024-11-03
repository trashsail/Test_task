import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';

import '../controller.dart';

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({
    super.key,
    required this.camera,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late ControllerOfCamera _controllerOfCamera;
  late Future<void> _initializeControllerFuture;

  TextEditingController description = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controllerOfCamera = ControllerOfCamera();
    _initializeControllerFuture =
        _controllerOfCamera.initializeCamera(widget.camera);
  }

  @override
  void dispose() {
    super.dispose();
    _controllerOfCamera.disposedCamera();
    description.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => _controllerOfCamera,
      child: Consumer<ControllerOfCamera>(
        builder: (context, controller, child) {
          return Scaffold(
            body: FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Stack(
                    children: [
                      SizedBox(
                        height: double.infinity,
                        width: double.infinity,
                        child: AspectRatio(
                          aspectRatio: _controllerOfCamera
                              .cameraController.value.aspectRatio,
                          child: CameraPreview(controller.cameraController),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 200,
                                  child: TextFormField(
                                    controller: description,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Введите комментарий',
                                    ),
                                    onChanged: (value) {
                                      controller.takeDescription(value);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                FloatingActionButton(
                                  onPressed: () async {
                                    await controller.uploadPhoto();
                                    description.clear();
                                  },
                                  child: const Icon(Icons.camera_alt),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          );
        },
      ),
    );
  }
}
