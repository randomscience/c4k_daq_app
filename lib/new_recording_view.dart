import 'dart:async';

import 'package:c4k_daq/constants.dart';
import 'package:c4k_daq/version.dart';
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

  _saveToFile({String? uuid}) async {
    uuid ??= const Uuid().v4();

    var localFile = io.File(
        '${(await getApplicationDocumentsDirectory()).path}/c4k_daq/$uuid.json');
    await localFile.create(recursive: true);
    try {
      await saveToFile(localFile, uuid, widget.userInformation(),
          widget.exerciseVideoMapping());
    } catch (e) {
      // widget.clearData();
      setState(() => {});
      throw Exception(
          "Exception occurred when data was saved to local file, error message: $e");
    }
    // widget.clearData();
    setState(() => {});
  }

  saveMeasurement() async {
    var uuid = const Uuid().v4();
    final path = await widget._localPath;
    late Map<String, String?> localExerciseVideoMapping =
        Map<String, String?>.from(widget.exerciseVideoMapping());
    late Map<String, String?> localUserInformation =
        Map<String, String?>.from(widget.userInformation());

    _saveToFile(uuid: uuid);

    Map<String, String> parsedUserInformation = {};
    print("here");
    Iterator serInformationIterator = {
      ...{"gateway_key": gatewayKey},
      ...{"unique_id": uuid},
      ...localUserInformation,
      ...{"app_version": appVersion}
    }.entries.iterator;

    while (serInformationIterator.moveNext()) {
      MapEntry<String, String?> entry = serInformationIterator.current;
      parsedUserInformation[entry.key] = entry.value!;
    }
    print("here");

    List<UploadResult> overallResult = [];
    try {
      overallResult.add(await uploadMeasurement(parsedUserInformation)
          .timeout(const Duration(seconds: 10)));
    } on TimeoutException {
      widget.clearData();
      setState(() => {});
      throw TimeoutException("parsedUserInformation upload took to long.");
    } catch (x) {
      widget.clearData();
      setState(() => {});
      rethrow;
    }
    print("here");

    Iterator videoIterator = localExerciseVideoMapping.entries.iterator;
    while (videoIterator.moveNext()) {
      MapEntry<String, String?> entry = videoIterator.current;
      try {
        overallResult.add(await uploadMeasurementVideo(
                localExerciseVideoMapping[entry.key]!,
                exerciseNameConverter(entry.key),
                uuid,
                gatewayKey)
            .timeout(const Duration(seconds: 10)));
      } on TimeoutException {
        widget.clearData();
        setState(() => {});
        throw TimeoutException(
            "${exerciseNameConverter(entry.key)} upload took to long.");
      } catch (x) {
        widget.clearData();
        setState(() => {});
        rethrow;
      }
    }
    print("here");

    widget.clearData();
    bool singleOverallResult = true;

    for (var element in overallResult) {
      singleOverallResult = element.isSuccess() && singleOverallResult;
    }

    if (singleOverallResult) {
      deleteMeasurement('$path/c4k_daq/$uuid.json');
      widget.clearData();
    }

    setState(() => {});
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
      saveToFile: _saveToFile,
    );
  }
}
