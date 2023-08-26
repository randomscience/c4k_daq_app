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

  const DeleteDataDialog(
      {super.key,
      required this.id,
      required this.pathToFile,
      required this.deleteFile,
      required this.exitButton});

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
                child: ElevatedButton(
                    onPressed: () => widget.exitButton(),
                    child: const Text('Anuluj'))),
            Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                    onPressed: () => {
                          widget.deleteFile(widget.pathToFile),
                          widget.exitButton()
                        },
                    child: const Text(
                      'Usuń',
                      style: TextStyle(color: Colors.red),
                    )))
          ],
        )
      ],
    ));
  }
}

class Library extends StatefulWidget {
  const Library({super.key});

  @override
  State<Library> createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  bool _isLoading = true;
  List<Map<String, dynamic>> contentsInFiles = [];
  List<String> pathsToFiles = [];

  void _deleteMeasurement(String pathToMeasurement) async {
    await deleteMeasurement(pathToMeasurement);
    _loadFiles();
  }

  void _loadFiles() async {
    List<FileSystemEntity> directoriesInFile = [];
    List<Map<String, dynamic>> localContentsInFiles = [];

    setState(() => {_isLoading = false, contentsInFiles = []});
    sleep(Duration(seconds: 1));
    String directory = (await getApplicationDocumentsDirectory()).path;
    try {
      directoriesInFile = Directory("$directory/c4k_daq/").listSync();
    } on PathNotFoundException {
      setState(
          () => {_isLoading = false, contentsInFiles = localContentsInFiles});
      return;
    } catch (x) {
      setState(
          () => {_isLoading = false, contentsInFiles = localContentsInFiles});
      return;
    }
    var iter = directoriesInFile.iterator;

    while (iter.moveNext()) {
      var file = File(iter.current.path);
      String content = await file.readAsString();

      if (content.isNotEmpty) {
        localContentsInFiles.add(json.decode(content));
        pathsToFiles.add(iter.current.path);
      }
    }
    setState(
        () => {_isLoading = false, contentsInFiles = localContentsInFiles});
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
      return Container(
        color: Colors.white,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (contentsInFiles.isNotEmpty) {
      return Center(
          child: ListView.builder(
        itemCount: contentsInFiles.length,
        itemBuilder: (context, index) {
          return LibraryCard(
            localJsonData: Map<String, dynamic>.from(contentsInFiles[index]),
            pathToFile: pathsToFiles[index],
            runPopUp: _showDialog,
            snackBar: () => _showSnackBar(context),
          );
        },
      ));
    } else {
      return const Center(
        child: Text("Nie masz żadnych zapisanych pomiarów",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 38,
            ),
            textAlign: TextAlign.center),
      );
    }
  }
}
