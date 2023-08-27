import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';

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
    widget.pathToVideoSetter(widget.exerciseTitle, null);
    setState(() => _isRecording = false);
    widget.exitButton();
  }

  _recordVideo() async {
    if (_isRecording) {
      final file = await _cameraController.stopVideoRecording();
      widget.pathToVideoSetter(widget.exerciseTitle, file.path);
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
                  onPressed: () => _exitRecording(),
                ),
              )),
          Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 42, 0, 0),
                child: Text(widget.exerciseTitle,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        color: Colors.white)),
              )),
          if (_recordingEnded && !_isRecording && !_isLoading)
            Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 24, 106),
                    child: FilledButton(
                        // backgroundColor:Colors.transparent,
                        // style: TextStyle(color: Colors.grey),
                        onPressed: () => widget.exitButton(),
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
