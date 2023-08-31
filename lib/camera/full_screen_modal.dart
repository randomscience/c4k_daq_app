import 'package:c4k_daq/camera/camera_page.dart';
import 'package:flutter/material.dart';

class FullScreenModal extends ModalRoute {
  final Function pathToVideoSetter;
  final String exerciseTitle;

  // constructor
  FullScreenModal(
      {required this.pathToVideoSetter, required this.exerciseTitle});

  _closeModal(context) {
    // close the modal dialog
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
          child: CameraPage(
              pathToVideoSetter: pathToVideoSetter,
              exerciseTitle: exerciseTitle,
              exitButton: () => _closeModal(context))),
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    // add fade animation
    return FadeTransition(
      opacity: animation,
      // add slide animation
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -1),
          end: Offset.zero,
        ).animate(animation),
        // add scale animation
        child: ScaleTransition(
          scale: animation,
          child: child,
        ),
      ),
    );
  }
}
