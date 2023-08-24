import 'package:c4k_daq/constants.dart';
import 'package:c4k_daq/upload_measurement.dart';
import 'package:c4k_daq/upload_result.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LibraryCard extends StatefulWidget {
  final Map<String, dynamic> localJsonData;
  const LibraryCard({super.key, required this.localJsonData});

  @override
  State<LibraryCard> createState() => _LibraryCard();
}

class _LibraryCard extends State<LibraryCard> {
  String id = "";

  String measurementTimeDay = "";
  String measurementTimeHour = "";

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

    // for (var key in userInformation.keys) {
    //   userInformation[key] = widget.localJsonData[key];
    // }

    var keysList = List.from(userInformation.keys);

    keysList.forEach((element) {
      userInformation[element] = widget.localJsonData[element].toString();
    });

    keysList = List.from(exerciseVideoMapping.keys);
    keysList.forEach((element) {
      exerciseVideoMapping[element] = widget.localJsonData[element].toString();
    });

    print(exerciseVideoMapping);
    print(userInformation);

    var uuid = widget.localJsonData['unique_id'].toString();
    var appVersion = widget.localJsonData['app_version'].toString();

    Map<String, String> parsedUserInformation = {};

    Iterator informationIterator = {
      ...{"gateway_key": gatewayKey},
      ...{"unique_id": uuid},
      ...userInformation,
      ...{"app_version": appVersion}
    }.entries.iterator;

    while (informationIterator.moveNext()) {
      MapEntry<String, String?> entry = informationIterator.current;
      parsedUserInformation[entry.key] = entry.value!;
    }

    List<UploadResult> overallResult = [];
    overallResult.add(await uploadMeasurement(parsedUserInformation));

    Iterator videoIterator = exerciseVideoMapping.entries.iterator;

    while (videoIterator.moveNext()) {
      MapEntry<String, String?> entry = videoIterator.current;

      overallResult.add(await uploadMeasurementVideo(
          exerciseVideoMapping[entry.key]!,
          exerciseNameConverter(entry.key),
          uuid,
          gatewayKey));
    }
  }

  void _retryUpload() {
    saveMeasurement();
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
                      onPressed: () => {},
                      child: const Text(
                        'Usuń',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  )),
              Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 8, 10),
                  child: Align(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent),
                          onPressed: () => {_retryUpload()},
                          child: const Text('Wyślij',
                              style: TextStyle(color: Colors.white)))))
            ])
          ])),
        ));
  }
}
