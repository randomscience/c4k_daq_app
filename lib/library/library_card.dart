import 'package:c4k_daq/upload_measurement.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class LibraryCard extends StatefulWidget {
  final Map<String, dynamic> localJsonData;
  final void Function(String) deleteMeasurement;
  final void Function(String, String) runPopUp;
  final void Function(String) snackBar;
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

  void _deleteMeasurement() async {
    String directory = (await getApplicationDocumentsDirectory()).path;

    widget.runPopUp(widget.localJsonData['id'],
        '$directory/c4k_daq/${widget.localJsonData['unique_id']}.json');
  }

  void _retryUpload() async {
    setState(() {
      isAwaiting = true;
    });
    String? result = await uploadMeasurementFromPath(widget.pathToFile);
    setState(() => isAwaiting = false);

    if (result != null) {
      widget.snackBar(result);
      return;
    }
    widget.deleteMeasurement(widget.pathToFile);
  }

  FilledButton _sendButton() {
    if (isAwaiting) {
      return FilledButton(
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
          onPressed: () => {_retryUpload()},
          child: const Text(
            'Wyślij',
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
