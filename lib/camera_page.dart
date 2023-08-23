import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraPage extends StatefulWidget {
  Function pathToVideoSetter;
  Function exitButton;
  String exerciseTitle;

  CameraPage(
      {super.key,
      required this.pathToVideoSetter,
      required this.exerciseTitle,
      required this.exitButton});

  @override
  CameraPageState createState() => CameraPageState();
}

class CameraPageState extends State<CameraPage> {
  bool _isLoading = true;
  bool _isRecording = false;
  late CameraController _cameraController;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  @override
  void dispose() {
    _cameraController.dispose();
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
    widget.pathToVideoSetter(widget.exerciseTitle, null);
    setState(() => _isRecording = false);
    widget.exitButton();
  }

  _recordVideo() async {
    if (_isRecording) {
      final file = await _cameraController.stopVideoRecording();
      widget.pathToVideoSetter(widget.exerciseTitle, file.path);
      setState(() => _isRecording = false);
      widget.exitButton();
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
          CameraPreview(_cameraController),
          Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: FloatingActionButton(
                  backgroundColor: Colors.red,
                  child: Icon(_isRecording ? Icons.stop : Icons.circle),
                  onPressed: () => _recordVideo(),
                ),
              )),
          Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: FloatingActionButton(
                  backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                  child: const Icon(Icons.keyboard_return_outlined),
                  onPressed: () => _exitRecording(),
                ),
              )),
          Padding(
            padding: const EdgeInsets.all(25),
            child: Text(widget.exerciseTitle),
          ),
        ],
        // ),
      ));
    }
  }
}
