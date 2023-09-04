import 'dart:io';

import 'package:c4k_daq/constants.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class CameraPage extends StatefulWidget {
  final Function pathToVideoSetter;
  final Function exitButton;
  final String exerciseTitle;
  final bool verticalOrientation;

  const CameraPage({
    super.key,
    required this.pathToVideoSetter,
    required this.exerciseTitle,
    required this.exitButton,
    this.verticalOrientation = true,
  });

  @override
  CameraPageState createState() => CameraPageState();
}

class CameraPageState extends State<CameraPage> {
  bool _isLoading = true;
  bool _isRecording = false;
  bool _recordingEnded = false;
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

    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: []);
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
    // widget.pathToVideoSetter(exerciseNameConverter(widget.exerciseTitle), null);
    setState(() => _isRecording = false);
    widget.exitButton();
  }

  _recordVideo() async {
    if (_isRecording) {
      // XFile file = await _cameraController.
      file = await _cameraController.stopVideoRecording();
      String filepath =
          '${(await getApplicationDocumentsDirectory()).path}/c4k_daq/${file.name}';

      Directory("/data/user/0/com.example.c4k_daq/app_flutter/c4k_daq")
          .createSync();

      await file.saveTo(filepath);

      widget.pathToVideoSetter(
          exerciseNameConverter(widget.exerciseTitle), filepath);

      setState(() => {_isRecording = false, _recordingEnded = true});
      // widget.exitButton();
    } else {
      await _cameraController.prepareForVideoRecording();
      await _cameraController.startVideoRecording();
      setState(() => _isRecording = true);
    }
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
          // child: Center(
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
                  child: Icon(
                    _isRecording ? Icons.stop_rounded : Icons.circle,
                    color: Colors.red,
                    size: 46,
                  ),
                  onPressed: () => _recordVideo(),
                ),
              )),
          Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 34, 0, 0),
                child: IconButton(
                  // backgroundColor: const Color.fromARGB(0, 255, 255, 255),
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
                    // width: 1200,
                    height: 36,
                    child: Center(
                        child: Text(widget.exerciseTitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white))),
                  ))),
          if (_recordingEnded && !_isRecording && !_isLoading)
            Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 24, 106),
                    child: FilledButton(
                        // backgroundColor:Colors.transparent,
                        // style: TextStyle(color: Colors.grey),
                        onPressed: () => {_exitRecording()},
                        child: const Text(
                          'Zapisz',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        )))),
        ],
        // ),
      ));
    }
  }
}
