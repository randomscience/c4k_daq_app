import 'package:flutter/material.dart';
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'measurement_stepper.dart';
import 'full_screen_modal.dart';
import 'upload_data_dialog.dart';
import 'upload_measurement.dart';
import 'upload_result.dart';

class NewRecording extends StatefulWidget {
  NewRecording({super.key});

  Map<String, String?> userInformation = {
    "id": null,
    "height": null,
    "nose_to_floor": null,
    "collar_bone_to_floor": null,
    "pelvis_to_floor": null
  };

  Map<String, String?> exerciseVideoMapping = {
    "Exercise 1": null,
  };

  clearData() {
    for (MapEntry e in userInformation.entries) {
      userInformation[e.key] = null;
    }
    for (MapEntry e in exerciseVideoMapping.entries) {
      exerciseVideoMapping[e.key] = null;
    }
  }

  setUserInformation(Map<String, String?> userInformation) {
    this.userInformation = userInformation;
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  saveMeasurement() async {
    var uuid = const Uuid().v4();
    final path = await _localPath;
    var localFile = io.File('$path/c4k_daq/$uuid.json');
    localFile.create(recursive: true);

    // '...' operator combines maps
    // but I call it crazy shit
    await localFile.writeAsString(json.encode({
      ...{"unique_id": uuid},
      ...userInformation,
      ...exerciseVideoMapping,
      ...{"measurement_time": "${DateTime.now()}"}
    }));

    Map<String, String> parsedUserInformation = {};

    Iterator serInformationIterator = {
      ...{"gateway_key": "dc48813b9f2371df0479fa27b112b64d"},
      ...{"unique_id": uuid},
      ...userInformation,
    }.entries.iterator;

    while (serInformationIterator.moveNext()) {
      MapEntry<String, String?> entry = serInformationIterator.current;
      parsedUserInformation[entry.key] = entry.value!;
    }

    List<UploadResult> overallResult = [];
    overallResult.add(await uploadMeasurement(parsedUserInformation));

    Iterator videoIterator = exerciseVideoMapping.entries.iterator;
    while (videoIterator.moveNext()) {
      MapEntry<String, String?> entry = videoIterator.current;

      overallResult.add(await uploadMeasurementVideo(
          exerciseVideoMapping[entry.key]!,
          entry.key,
          uuid,
          "dc48813b9f2371df0479fa27b112b64d"));
    }
    clearData();
    return overallResult;
  }

  @override
  State<NewRecording> createState() => _NewRecording();
}

class _NewRecording extends State<NewRecording> {
  bool recordingVideo = false;

  String currentlyRecorderExerciseTitle = "No_exercise_is_currently_recorded";

  setExerciseVideoMapping(String exercise, String? videoPath) {
    if (videoPath != null) widget.exerciseVideoMapping[exercise] = videoPath;
    setState(() => recordingVideo = false);
  }

  recordVideo(String exerciseTitle) {
    currentlyRecorderExerciseTitle = exerciseTitle;
    setState(() => recordingVideo = true);
  }

  _showDialog() async {
    showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
            title: const Text("Uploading data"),
            content: UploadDataDialog(
                exerciseVideoMappingGetter: () => widget.exerciseVideoMapping,
                userInformationGetter: () => widget.userInformation,
                exitButton: Navigator.of(context).pop,
                awaitedFunction: widget.saveMeasurement)));
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
      clearData: widget.clearData,
      setUserInformation: widget.setUserInformation,
      exerciseVideoMappingGetter: () => widget.exerciseVideoMapping,
      userInformationGetter: () => widget.userInformation,
    );
  }
}
