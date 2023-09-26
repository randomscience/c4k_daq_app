import 'dart:io';

import 'package:c4k_daq/constants.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class CameraPagePhoto extends StatefulWidget {
  final Function exitButton;
  final Function returnPicture;

  final bool verticalOrientation;

  const CameraPagePhoto({
    super.key,
    required this.exitButton,
    this.verticalOrientation = true,
    required this.returnPicture,
  });

  @override
  CameraPagePhotoState createState() => CameraPagePhotoState();
}

class CameraPagePhotoState extends State<CameraPagePhoto> {
  bool _isLoading = true;
  String? _picturePath;
  late CameraController _cameraController;
  XFile file = XFile("");
  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    _initCamera();
  }

  @override
  void dispose() {
    _cameraController.dispose();

    SystemChrome.setPreferredOrientations([]);
    super.dispose();
  }

  _initCamera() async {
    final cameras = await availableCameras();
    CameraDescription? front;
    try {
      front = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back);
    } catch (e) {
      if (cameras.isNotEmpty) {
        front = cameras[0];
      } else {
        rethrow;
      }
    }

    _cameraController =
        CameraController(front, ResolutionPreset.max, enableAudio: false);

    await _cameraController.initialize();
    setState(() => _isLoading = false);
  }

  _exitRecording() async {
    setState(() => {});
    widget.exitButton();
  }

  _takePicture() async {
    try {
      final image = await _cameraController.takePicture();

      _picturePath = image.path;
    } catch (e) {
      print("error?: $e");
    }

    setState(
      () => {},
    );
    // widget.pathToVideoSetter("calibration", "calibration") ;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: Colors.white,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Center(
          child: Stack(
        children: [
          Center(
            child: CameraPreview(_cameraController),
          ),
          Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 102),
                child: FloatingActionButton(
                  backgroundColor: Colors.white,
                  shape: const CircleBorder(eccentricity: 0.5),
                  child: const Icon(
                    Icons.circle,
                    color: Colors.red,
                    size: 46,
                  ),
                  onPressed: () => _takePicture(),
                ),
              )),
          Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 34, 0, 0),
                child: IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                  onPressed: () => {_exitRecording()},
                ),
              )),
          if (!_isLoading && _picturePath != null)
            Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 24, 106),
                    child: FilledButton(
                        onPressed: () => {widget.returnPicture(_picturePath)},
                        child: const Text(
                          'Zapisz',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        )))),
        ],
      ));
    }
  }
}
