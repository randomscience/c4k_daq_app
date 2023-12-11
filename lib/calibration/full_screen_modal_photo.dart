import 'dart:io';

import 'package:c4k_daq/calibration/camera_page_photo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:getwidget/getwidget.dart';
// import 'package:floating_draggable_widget/floating_draggable_widget.dart';
// import 'package:image_painter_extended/image_painter_extended.dart';

import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_painter/flutter_painter.dart';

import 'dart:ui' as ui;

// import 'package:phosphor_flutter/phosphor_flutter.dart';

class MarkerPage extends StatefulWidget {
  final String picturePath;
  final Function exitButton;
  const MarkerPage(
      {super.key, required this.picturePath, required this.exitButton});

  @override
  MarkerPageState createState() => MarkerPageState();
}

class MarkerPageState extends State<MarkerPage> {
  late Image imag;
  late Paint shapePaint;
  late PainterController controller;
  late ui.Image backgroundImage;

  @override
  Future<void> initState() async {
    super.initState();
    shapePaint = Paint()
      ..strokeWidth = 5
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    controller = PainterController(
        settings: PainterSettings(
            text: const TextSettings(
              // focusNode: textFocusNode,
              textStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(255, 0, 0, 1),
                  fontSize: 18),
            ),
            freeStyle: const FreeStyleSettings(
              color: Color.fromRGBO(255, 0, 0, 1),
              strokeWidth: 5,
            ),
            shape: ShapeSettings(
              paint: shapePaint,
            ),
            scale: const ScaleSettings(
              enabled: true,
              minScale: 1,
              maxScale: 5,
            )));

    backgroundImage =
        await const NetworkImage('https://picsum.photos/1920/1080/').image;
    controller.background = backgroundImage.backgroundDrawable;
    setState(() => {});
  }

  @override
  Widget build(BuildContext context) {
    print(widget.picturePath);

    // final _imageKey = GlobalKey<ImagePainterState>();

    // Uint8List byteArray = await _imageKey.currentState.exportImage();

    // File imgFile = new File('directoryPath/fileName.png');
    // imgFile.writeAsBytesSync(image);

    return Center(
        child: Stack(children: [
      Padding(
          padding: EdgeInsets.only(top: 80),
          child: Center(
            child: Positioned.fill(
              child: Center(
                child: AspectRatio(
                  aspectRatio: backgroundImage.width! / backgroundImage.height!,
                  child: FlutterPainter(
                    controller: controller,
                  ),
                ),
              ),
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
              onPressed: () => widget.exitButton(),
            ),
          )),
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
