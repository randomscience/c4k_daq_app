import 'package:flutter/material.dart';
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'CameraPage.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'MeasurementStepper.dart';
import 'awaiting_button.dart';
import 'full_screen_modal.dart';
import 'loading_button.dart';
import 'saving_states.dart';
import 'upload_data_dialog.dart';
import 'upload_result.dart';

Future<UploadResult> uploadMeasurement(Map<String, String> measurement) async {
  final resp = await http.post(
    Uri.parse(
        "https://external.randomscience.org/c4k/api/v1/upload_measurement_info"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(measurement),
  );

  return UploadResult(statusCode: resp.statusCode, body: resp.body.toString());
}

uploadMeasurementVideo(
  String path,
  String fileName,
  String id,
  String gatewayKey,
) async {
  var request = http.MultipartRequest(
    'POST',
    Uri.parse(
        "https://external.randomscience.org/c4k/api/v1/upload_measurement_video/$gatewayKey/$id"),
  );

  request.files.add(
    http.MultipartFile.fromBytes(
      fileName,
      io.File(path).readAsBytesSync(),
      filename: fileName,
    ),
  );
  final resp = await request.send();

  return UploadResult(
      statusCode: resp.statusCode, body: await resp.stream.bytesToString());
}

class NewRecording extends StatefulWidget {
  NewRecording({super.key});
  bool recordingVideo = false;
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

  setUserInformation(Map<String, String?> userInformation) {
    this.userInformation = userInformation;
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  saveMeasurement() async {
    if (userInformation['id'] == null) {
      return;
    }

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

    userInformation = {
      "id": null,
      "height": null,
      "nose_to_floor": null,
      "collar_bone_to_floor": null,
      "pelvis_to_floor": null
    };

    exerciseVideoMapping = {
      "Exercise 1": null,
    };
    return overallResult;
  }

  @override
  State<NewRecording> createState() => _NewRecording();
}

class _NewRecording extends State<NewRecording> {
  String currentlyRecorderExerciseTitle = "No_exercise_is_currently_recorded";

  setExerciseVideoMapping(String exercise, String? videoPath) {
    if (videoPath != null) widget.exerciseVideoMapping[exercise] = videoPath;
    setState(() => widget.recordingVideo = false);
  }

  recordVideo(String exerciseTitle) {
    currentlyRecorderExerciseTitle = exerciseTitle;
    setState(() => widget.recordingVideo = true);
  }

  _showDialog() async {
    showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
            title: Text("sdasd"),
            content: UploadDataDialog(
                exitButton: Navigator.of(context).pop,
                awaitedFunction: widget.saveMeasurement)));
  }

// TODO this one should return success or failure of the camera recording operation and stuff
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
      setUserInformation: widget.setUserInformation,
      exerciseVideoMappingGetter: () => widget.exerciseVideoMapping,
      userInformationGetter: () => widget.userInformation,
    );
  }
}