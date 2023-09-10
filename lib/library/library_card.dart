import 'dart:async';
import 'package:c4k_daq/constants.dart';
import 'package:c4k_daq/upload_measurement.dart';
import 'package:c4k_daq/upload_result.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class LibraryCard extends StatefulWidget {
  final Map<String, dynamic> localJsonData;
  final void Function(String) deleteMeasurement;
  final void Function(String, String) runPopUp;
  final void Function() snackBar;
  final String pathToFile;

  const LibraryCard(
      {super.key,
      required this.localJsonData,
      required this.pathToFile,
      required this.runPopUp,
      required this.snackBar,
      required this.deleteMeasurement});

  @override
  State<LibraryCard> createState() => _LibraryCard();
}

class _LibraryCard extends State<LibraryCard> {
  String id = "";

  String measurementTimeDay = "";
  String measurementTimeHour = "";

  bool isAwaiting = false;

  @override
  void initState() {
    super.initState();
    id = widget.localJsonData['id'];

    final DateTime date =
        DateTime.parse(widget.localJsonData['measurement_time']);

    measurementTimeDay = DateFormat('dd-MM-yyyy').format(date.toLocal());
    measurementTimeHour = DateFormat('H:mm').format(date.toLocal());
  }

  saveMeasurement() async {
    Map<String, String?> userInformation =
        Map<String, String?>.from(emptyUserInformation());

    Map<String, String?> exerciseVideoMapping =
        Map<String, String?>.from(emptyExerciseVideoMapping);

    var keysList = List.from(userInformation.keys);

    for (var element in keysList) {
      userInformation[element] = widget.localJsonData[element].toString();
    }

    keysList = List.from(exerciseVideoMapping.keys);
    for (var element in keysList) {
      exerciseVideoMapping[element] = widget.localJsonData[element].toString();
    }

    var uuid = widget.localJsonData['unique_id'].toString();
    var appVersion = widget.localJsonData['app_version'].toString();

    Map<String, String> parsedUserInformation = {};

    Iterator informationIterator = {
      ...{"gateway_key": gatewayKeyValue},
      ...{"unique_id": uuid},
      ...{"hardware_key": await getId()},
      ...userInformation,
      ...{"app_version": appVersion}
    }.entries.iterator;

    while (informationIterator.moveNext()) {
      MapEntry<String, String?> entry = informationIterator.current;
      parsedUserInformation[entry.key] = entry.value!;
    }

    List<UploadResult> overallResult = [];
    try {
      overallResult.add(await uploadInformation(parsedUserInformation)
          .timeout(const Duration(minutes: 1)));
    } on TimeoutException {
      throw TimeoutException("parsedUserInformation upload took to long.");
    } catch (x) {
      rethrow;
    }

    Iterator videoIterator = exerciseVideoMapping.entries.iterator;

    while (videoIterator.moveNext()) {
      MapEntry<String, String?> entry = videoIterator.current;
      try {
        overallResult.add(await uploadMeasurementVideo(
                exerciseVideoMapping[entry.key]!, entry.key, uuid)
            .timeout(const Duration(minutes: 5)));
      } on TimeoutException {
        throw TimeoutException(
            "${exerciseNameConverter(entry.key)} upload took to long.");
      } catch (x) {
        rethrow;
      }
    }
    return overallResult;
  }

  void _deleteMeasurement() async {
    String directory = (await getApplicationDocumentsDirectory()).path;

    widget.runPopUp(widget.localJsonData['id'],
        '$directory/c4k_daq/${widget.localJsonData['unique_id']}.json');
  }

  void _retryUpload() async {
    setState(() {
      isAwaiting = true;
    });

    List<UploadResult> overallResult = [];
    try {
      overallResult = await saveMeasurement();
    } on TimeoutException {
      widget.snackBar();
      setState(() => isAwaiting = false);
      return;
    } catch (x) {
      widget.snackBar();
      setState(() => isAwaiting = false);
      return;
    }

    bool singleOverallResult = true;

    for (var element in overallResult) {
      singleOverallResult = element.isSuccess() && singleOverallResult;
    }

    if (singleOverallResult) {
      widget.deleteMeasurement(widget.pathToFile);
    } else {
      widget.snackBar();
    }
    // setState(() {
    //   isAwaiting = false;
    // });
  }

  FilledButton _sendButton() {
    if (isAwaiting) {
      return FilledButton(
          // style: FilledButton.styleFrom(backgroundColor: Colors.white),
          onPressed: () => {},
          child: const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 3.0,
                color: Colors.white,
              )));
    } else {
      return FilledButton(
          // style: FilledButton.styleFrom(backgroundColor: Colors.white),
          onPressed: () => {_retryUpload()},
          child: const Text(
            'Wyślij',
            // style: TextStyle(color: Colors.blueAccent)
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 6),
        child: Center(
          child: Card(
              child: Column(children: [
            Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 6, 6),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text("ID: $id",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)))),
            Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 6, 0),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                        "Stworzono: $measurementTimeDay o godzinie: $measurementTimeHour",
                        style: const TextStyle(fontSize: 16)))),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 8, 10),
                    child: TextButton(
                      // style: ElevatedButton.styleFrom(
                      //     backgroundColor: Colors.transparent),
                      onPressed: () => {_deleteMeasurement()},
                      child: const Text(
                        'Usuń',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  )),
              Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 8, 10),
                  child: Align(
                      alignment: Alignment.bottomRight, child: _sendButton()))
            ])
          ])),
        ));
  }
}
