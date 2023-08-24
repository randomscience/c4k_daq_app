import 'package:c4k_daq/constants.dart';
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

  saveMeasurement() async {
    var uuid = const Uuid().v4();
    final path = await widget._localPath;
    try {
      var localFile = io.File('$path/c4k_daq/$uuid.json');
      localFile.create(recursive: true);
      // '...' operator combines maps
      // but I call it crazy shit
      await localFile.writeAsString(
          json.encode({
            ...{"unique_id": uuid},
            ...widget.userInformation(),
            ...widget.exerciseVideoMapping(),
            ...{"measurement_time": "${DateTime.now()}"},
            ...{"app_version": "0.1.dummy"}
          }),
          flush: true);
    } catch (e) {
      throw Exception(
          "Exception occurred when data was saved to local file, error message: $e");
    }
    Map<String, String> parsedUserInformation = {};

    Iterator serInformationIterator = {
      ...{"gateway_key": gatewayKey},
      ...{"unique_id": uuid},
      ...widget.userInformation(),
      ...{"app_version": "0.1.dummy"}
    }.entries.iterator;

    while (serInformationIterator.moveNext()) {
      MapEntry<String, String?> entry = serInformationIterator.current;
      parsedUserInformation[entry.key] = entry.value!;
    }

    List<UploadResult> overallResult = [];
    overallResult.add(await uploadMeasurement(parsedUserInformation));

    Iterator videoIterator = widget.exerciseVideoMapping().entries.iterator;
    while (videoIterator.moveNext()) {
      MapEntry<String, String?> entry = videoIterator.current;

      overallResult.add(await uploadMeasurementVideo(
          widget.exerciseVideoMapping()[entry.key]!,
          entry.key,
          uuid,
          gatewayKey));
    }
    widget.clearData();
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
    );
  }
}
