import 'dart:io';

import 'package:c4k_daq/calibration/camera_page_photo.dart';
import 'package:flutter/material.dart';
import 'package:floating_overlay/floating_overlay.dart';
import 'package:flutter/services.dart';

class MarkerPage extends StatefulWidget {
  final String picturePath;
  final Function exitButton;
  const MarkerPage(
      {super.key, required this.picturePath, required this.exitButton});

  @override
  MarkerPageState createState() => MarkerPageState();
}

class MarkerPageState extends State<MarkerPage> {
  late Image image;
  final controller = FloatingOverlayController.relativeSize(
    maxScale: 2.0,
    minScale: 1.0,
    start: Offset.zero,
    padding: const EdgeInsets.all(200.0),
    // constrained: true,
  );

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    image = Image.file(File(widget.picturePath));

    setState(() => {});
  }

  @override
  Widget build(BuildContext context) {
    print(widget.picturePath);

    return Center(
        child: Stack(children: [
      Center(
        child: FloatingOverlay(
          controller: controller,
          floatingChild: SizedBox.square(
            dimension: 30.0,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                border: Border.all(
                  color: Colors.white,
                  width: 2.0,
                ),
              ),
            ),
          ),
          child: image,
        ),
      ),
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
              onPressed: () => widget.exitButton(),
            ),
          )),
      Align(
        alignment: Alignment.topCenter,
        child: ElevatedButton(
            child: const Text('Toggle'),
            onPressed: () {
              controller.toggle();
            }),
      ),
      Align(
        alignment: Alignment.topRight,
        child: ElevatedButton(
            child: const Text('position'),
            onPressed: () {
              print(controller.offset);
              print(image.height);
              print(image.width);
            }),
      )
    ]));
  }
}

class CalibrationStep extends StatefulWidget {
  final Function exitButton;

  const CalibrationStep({
    super.key,
    required this.exitButton,
  });

  @override
  CalibrationStepState createState() => CalibrationStepState();
}

class CalibrationStepState extends State<CalibrationStep> {
  bool pictureState = true;
  bool markerState = false;
  String _picturePath = "";

  @override
  Widget build(BuildContext context) {
    if (pictureState) {
      return CameraPagePhoto(
          exitButton: widget.exitButton,
          returnPicture: (String picturePath) => setState(() => {
                pictureState = false,
                markerState = true,
                _picturePath = picturePath
              }));
    } else {
      return MarkerPage(
        picturePath: _picturePath,
        exitButton: widget.exitButton,
      );
    }
  }
}

class FullScreenModalPhoto extends ModalRoute {
  final Function pathToVideoSetter;
  late bool pictureTaken;
  FullScreenModalPhoto({required this.pathToVideoSetter});

  _closeModal(context) {
    Navigator.pop(context);
  }

  @override
  Duration get transitionDuration => const Duration(milliseconds: 600);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  Color get barrierColor => Colors.black.withOpacity(1);

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Material(
        type: MaterialType.transparency,
        child: Center(
            child: CalibrationStep(
          exitButton: () => _closeModal(context),
        )));
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -1),
          end: Offset.zero,
        ).animate(animation),
        child: ScaleTransition(
          scale: animation,
          child: child,
        ),
      ),
    );
  }
}
