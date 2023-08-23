import 'package:c4k_daq/constants.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
  Map<String, String?> userInformation = {
    id: null,
    height: null,
    noseToFloor: null,
    collarBoneToFloor: null,
    pelvisToFloor: null
  };

  Map<String, String?> exerciseVideoMapping = {
    "Ćwiczenie 1": null,
    "Ćwiczenie 2": null,
    "Ćwiczenie 3": null,
  };

  NewRecording({super.key});

  clearData() {
    userInformation = Map<String, String?>.from(emptyUserInformation);
    exerciseVideoMapping = Map<String, String?>.from(emptyExerciseVideoMapping);
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
      ...{"measurement_time": "${DateTime.now()}"},
      ...{"app_version": (await PackageInfo.fromPlatform()).version.toString()}
    }));

    Map<String, String> parsedUserInformation = {};

    Iterator serInformationIterator = {
      ...{"gateway_key": gatewayKey},
      ...{"unique_id": uuid},
      ...userInformation,
      ...{"app_version": (await PackageInfo.fromPlatform()).version.toString()}
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
          exerciseVideoMapping[entry.key]!, entry.key, uuid, gatewayKey));
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
