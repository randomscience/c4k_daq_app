import 'package:c4k_daq/calibration/full_screen_modal_photo.dart';
import 'package:flutter/material.dart'
    show
        BuildContext,
        Center,
        Column,
        Navigator,
        State,
        StatefulWidget,
        Text,
        TextButton,
        Widget;

class Calibration extends StatefulWidget {
  const Calibration({super.key});
  @override
  State<Calibration> createState() => _Calibration();
}

// TODO floating overlay https://pub.dev/packages/floating_overlay
class _Calibration extends State<Calibration> {
  late String calibrationPhoto;

  _showModal(BuildContext context) async {
    // show the modal dialog and pass some data to it
    await Navigator.of(context).push(FullScreenModalPhoto(
        pathToVideoSetter: (String calibration) =>
            {calibrationPhoto = calibration}));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("Last Calibration was performed: <date>"),
        TextButton(
          child: const Text("Update Calibration"),
          onPressed: () async {
            await _showModal(context);
          },
        )
      ],
    );
  }
}
