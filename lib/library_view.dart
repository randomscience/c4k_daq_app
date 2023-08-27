import 'dart:io';
import 'dart:convert';

import 'package:c4k_daq/upload_measurement.dart';
import 'package:flutter/material.dart';

import 'package:path_provider/path_provider.dart';

import 'library_card.dart';

class DeleteDataDialog extends StatefulWidget {
  final String id;
  final String pathToFile;
  final void Function(String) deleteFile;
  final void Function() exitButton;

  const DeleteDataDialog({
    super.key,
    required this.id,
    required this.pathToFile,
    required this.deleteFile,
    required this.exitButton,
  });

  @override
  State<DeleteDataDialog> createState() => _DeleteDataDialogState();
}

class _DeleteDataDialogState extends State<DeleteDataDialog> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: ListBody(
      children: <Widget>[
        Text("Czy na pewno chcesz usunąć: ${widget.id}"),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Align(
                alignment: Alignment.bottomRight,
                child: FilledButton.tonal(
                    onPressed: () => widget.exitButton(),
                    child: const Text('Anuluj'))),
            Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                    child: FilledButton(
                        onPressed: () => {
                              widget.deleteFile(widget.pathToFile),
                              widget.exitButton()
                            },
                        child: const Text(
                          'Usuń',
                          // style: TextStyle(color: Colors.red),
                        ))))
          ],
        )
      ],
    ));
  }
}

class Library extends StatefulWidget {
  final void Function(int) updateBadgeNumber;

  const Library({super.key, required this.updateBadgeNumber});

  @override
  State<Library> createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  bool _isLoading = true;
  // List<Map<String, dynamic>> contentsInFiles = [];
  Map<String, Map<String, dynamic>?> measurementFiles = {};
  // List<String> pathsToFiles = [];

  void _deleteMeasurement(String pathToMeasurement) {
    deleteMeasurement(pathToMeasurement);

    widget.updateBadgeNumber(measurementFiles.length - 1);

    setState(() {
      measurementFiles.remove(pathToMeasurement);
    });

    // _loadFiles();
  }

  List<Widget> _generateCards(context) {
    List<Widget> cards = [];
    measurementFiles.forEach((key, value) => cards.add(LibraryCard(
          key: Key(key),
          localJsonData: value!,
          pathToFile: key,
          runPopUp: _showDialog,
          deleteMeasurement: _deleteMeasurement,
          snackBar: () => _showSnackBar(context),
        )));

    return cards;
  }

  void _loadFiles() async {
    // List<FileSystemEntity> directoriesInFile = [];
    // List<Map<String, dynamic>> localContentsInFiles = [];

    setState(() => {_isLoading = false, measurementFiles = {}});

    String directory = (await getApplicationDocumentsDirectory()).path;

    try {
      Directory("$directory/c4k_daq/")
          .listSync()
          .forEach((element) => measurementFiles[element.path] = null);
    } on PathNotFoundException {
      setState(() => {_isLoading = false, measurementFiles = {}});
      return;
    } catch (x) {
      setState(() => {_isLoading = false, measurementFiles = {}});
      return;
    }

    Iterator iter = measurementFiles.keys.iterator;

    while (iter.moveNext()) {
      var file = File(iter.current);
      String content = await file.readAsString();

      if (content.isNotEmpty) {
        measurementFiles[iter.current] = json.decode(content);
      } else {
        measurementFiles.remove(iter.current);
      }
    }

    var sortedByValueMap = Map.fromEntries(measurementFiles.entries.toList()
      ..sort((e1, e2) => DateTime.parse(e2.value!['measurement_time'])
          .compareTo(DateTime.parse(e1.value!['measurement_time']))));

    setState(() => {_isLoading = false, measurementFiles = sortedByValueMap});
  }

  @override
  void initState() {
    super.initState();
    _loadFiles();
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive, overlays: []);
  }

  _showDialog(String id, String pathToFile) {
    showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
            title: const Text("Usuń"),
            content: DeleteDataDialog(
              exitButton: Navigator.of(context).pop,
              id: id,
              pathToFile: pathToFile,
              deleteFile: _deleteMeasurement,
            )));
  }

  _showSnackBar(BuildContext context) {
    // show the modal dialog and pass some data to it
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        action: SnackBarAction(
          label: 'Ok',
          onPressed: () {
            // Code to execute.
          },
        ),
        content:
            const Text('Wysyłanie nie powiodło się, spróbuj ponownie później'),
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (measurementFiles.keys.isNotEmpty) {
      return Center(
          child: ListView(
        children: _generateCards(context),
      ));
    } else {
      return const Center(
        child: Text("Nie masz żadnych pomiarów oczekujących na wysłanie",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 24,
            ),
            textAlign: TextAlign.center),
      );
    }
  }
}
