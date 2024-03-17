import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'measurement_stepper.dart';
import '../camera/full_screen_modal.dart';
import '../upload_measurement.dart';

class NewRecording extends StatefulWidget {
  final Map<String, String?> Function() userInformation;
  final Map<String, String?> Function() exerciseVideoMapping;
  final void Function() clearData;

  const NewRecording(
      {super.key,
      required this.userInformation,
      required this.exerciseVideoMapping,
      required this.clearData});

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  @override
  State<NewRecording> createState() => _NewRecording();
}

class _NewRecording extends State<NewRecording> {
  bool recordingVideo = false;

  String currentlyRecorderExerciseTitle = "No_exercise_is_currently_recorded";

  _showSnackBar(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        action: SnackBarAction(
          label: 'Ok',
          onPressed: () {},
        ),
        content: Text(text),
        duration: const Duration(seconds: 5),
        width: 280.0, // Width of the SnackBar.
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0, // Inner padding for SnackBar content.
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

  _saveToFile(Map<String, String?> userInformation,
      Map<String, String?> exerciseVideoMapping,
      {String? uuid}) async {
    uuid ??= const Uuid().v4();

    var localFile = io.File(
        '${(await getApplicationDocumentsDirectory()).path}/c4k_daq/$uuid.json');
    await localFile.create(recursive: true);
    try {
      await saveToFile(localFile, uuid, userInformation, exerciseVideoMapping);
    } catch (e) {
      throw Exception(
          "Exception occurred when data was saved to local file, error message: $e");
    }
    widget.clearData();
    setState(() => {});
  }

  setExerciseVideoMapping(String exercise, String? videoPath) {
    if (videoPath != null) widget.exerciseVideoMapping()[exercise] = videoPath;
    setState(() => recordingVideo = false);
  }

  _showVideoModal(BuildContext context, String exerciseTitle) async {
    await Navigator.of(context).push(FullScreenModal(
        pathToVideoSetter: setExerciseVideoMapping,
        exerciseTitle: exerciseTitle,
        mode: CamearaMode.video));
  }

  _showPhotoModal(BuildContext context, String exerciseTitle) async {
    await Navigator.of(context).push(FullScreenModal(
        pathToVideoSetter: setExerciseVideoMapping,
        exerciseTitle: exerciseTitle,
        mode: CamearaMode.photo));
  }

  @override
  Widget build(BuildContext context) {
    return MeasurementStepper(
      showVideoModal: (exerciseTitle) =>
          _showVideoModal(context, exerciseTitle),
      showPhotoModal: (exerciseTitle) =>
          _showPhotoModal(context, exerciseTitle),
      exerciseVideoMappingGetter: widget.exerciseVideoMapping,
      userInformationGetter: widget.userInformation,
      saveToFile: (userInformation, exerciseVideoMapping, {String? uuid}) => {
        _saveToFile(userInformation, exerciseVideoMapping, uuid: uuid),
        _showSnackBar(context, "Pomiar zapisano w oczekujących")
      },
    );
  }
}
