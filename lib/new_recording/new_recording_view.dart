import 'dart:async';

import 'package:c4k_daq/constants.dart';
import 'package:c4k_daq/version.dart';
import 'package:flutter/material.dart';

import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'measurement_stepper.dart';
import '../camera/full_screen_modal.dart';
import 'upload_data_dialog.dart';
import '../upload_measurement.dart';
import '../upload_result.dart';

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
    // show the modal dialog and pass some data to it
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        action: SnackBarAction(
          label: 'Ok',
          onPressed: () {
            // Code to execute.
          },
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

  saveMeasurement() async {
    var uuid = const Uuid().v4();
    final path = await widget._localPath;

    late Map<String, String?> localExerciseVideoMapping =
        Map<String, String?>.from(widget.exerciseVideoMapping());

    late Map<String, String?> localUserInformation =
        Map<String, String?>.from(widget.userInformation());

    localUserInformation[measurementTime] = "${DateTime.now()}";

    await _saveToFile(localUserInformation, localExerciseVideoMapping,
        uuid: uuid);

    List<UploadResult> overallResult = [];
    try {
      overallResult = await uploadMeasurementFromId(uuid);
    } catch (x) {
      _showSnackBar(context, "Pomiar zapisano w oczekujących");
      rethrow;
    }

    bool singleOverallResult = true;

    for (var element in overallResult) {
      if (!element.isSuccess()) {
        singleOverallResult = false;
        break;
      }
    }

    if (singleOverallResult) {
      deleteMeasurement('$path/c4k_daq/$uuid.json');
      widget.clearData();
      setState(() => {});
    }

    return overallResult;
  }

  setExerciseVideoMapping(String exercise, String? videoPath) {
    if (videoPath != null) widget.exerciseVideoMapping()[exercise] = videoPath;
    setState(() => recordingVideo = false);
  }

  _showDialog() {
    showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => AlertDialog(
            title: const Text("Wysyłanie danych"),
            content: UploadDataDialog(
                exerciseVideoMappingGetter: widget.exerciseVideoMapping,
                userInformationGetter: widget.userInformation,
                exitButton: Navigator.of(context).pop,
                awaitedFunction: saveMeasurement)));
  }

  _showModal(BuildContext context, String exerciseTitle) async {
    // show the modal dialog and pass some data to it
    await Navigator.of(context).push(FullScreenModal(
        pathToVideoSetter: setExerciseVideoMapping,
        exerciseTitle: exerciseTitle));
  }

  @override
  Widget build(BuildContext context) {
    return MeasurementStepper(
      showModalBottomSheet: (exerciseTitle) =>
          _showModal(context, exerciseTitle),
      saveMeasurement: _showDialog,
      exerciseVideoMappingGetter: widget.exerciseVideoMapping,
      userInformationGetter: widget.userInformation,
      saveToFile: (userInformation, exerciseVideoMapping, {String? uuid}) => {
        _saveToFile(userInformation, exerciseVideoMapping, uuid: uuid),
        _showSnackBar(context, "Pomiar zapisano w oczekujących")
      },
    );
  }
}
