import 'dart:io';

import 'package:c4k_daq/constants.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class PhotoCameraPage extends StatefulWidget {
  final Function pathToVideoSetter;
  final Function exitButton;
  final String exerciseTitle;
  final bool verticalOrientation;

  const PhotoCameraPage({
    super.key,
    required this.pathToVideoSetter,
    required this.exerciseTitle,
    required this.exitButton,
    this.verticalOrientation = true,
  });

  @override
  PhotoCameraPageState createState() => PhotoCameraPageState();
}

class PhotoCameraPageState extends State<PhotoCameraPage> {
  bool _isLoading = true;
  // bool _isRecording = false;
  bool _pictureTaken = false;
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
    // setState(() => _isRecording = false);
    widget.exitButton();
  }

  _takePicture() async {
    file = await _cameraController.takePicture();
    String filepath =
        '${(await getApplicationDocumentsDirectory()).path}/c4k_daq/${file.name}';

    Directory("/data/user/0/com.example.c4k_daq/app_flutter/c4k_daq")
        .createSync();

    await file.saveTo(filepath);

    widget.pathToVideoSetter(
        exerciseNameConverter(widget.exerciseTitle), filepath);

    setState(() {
      _pictureTaken = true;
    });
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
                    Icons.camera_alt,
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
          Align(
              alignment: Alignment.topCenter,
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(42, 42, 42, 0),
                  child: SizedBox(
                    height: 36,
                    child: Center(
                        child: Text(widget.exerciseTitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white))),
                  ))),
          if (_pictureTaken && !_isLoading)
            Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 24, 106),
                    child: FilledButton(
                        onPressed: () => {_exitRecording()},
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
