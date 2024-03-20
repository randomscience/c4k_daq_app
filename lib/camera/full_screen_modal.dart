import 'package:c4k_daq/camera/camera_page.dart';
import 'package:c4k_daq/camera/photo_page.dart';
import 'package:flutter/material.dart';

enum CamearaMode { video, photo }

class FullScreenModal extends ModalRoute {
  final Function pathToVideoSetter;
  final int index;
  final CamearaMode mode;

  FullScreenModal(
      {required this.pathToVideoSetter,
      required this.index,
      required this.mode});

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
          child: mode == CamearaMode.video
              ? CameraPage(
                  pathToVideoSetter: pathToVideoSetter,
                  index: index,
                  exitButton: () => _closeModal(context))
              : PhotoCameraPage(
                  pathToVideoSetter: pathToVideoSetter,
                  index: index,
                  exitButton: () => _closeModal(context))),
    );
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
