import 'dart:io';
import 'dart:convert';

import 'package:c4k_daq/upload_measurement.dart';
import 'package:flutter/material.dart';

import 'package:path_provider/path_provider.dart';

import 'library_card.dart';

class Library extends StatefulWidget {
  const Library({super.key});

  @override
  State<Library> createState() => _Library();
}

class _Library extends State<Library> {
  bool _isLoading = true;
  List<Map<String, dynamic>> contentsInFiles = [];
  void _deleteMeasurement(String pathToMeasurement) async {
    await deleteMeasurement(pathToMeasurement);
    contentsInFiles = [];
    _loadFiles();
  }

  void _loadFiles() async {
    String directory = (await getApplicationDocumentsDirectory()).path;
    List<FileSystemEntity> directoriesInFile = [];
    try {
      directoriesInFile = Directory("$directory/c4k_daq/").listSync();
    } on PathNotFoundException {
      setState(() => _isLoading = false);
      return;
    }
    var iter = directoriesInFile.iterator;

    contentsInFiles = [];
    while (iter.moveNext()) {
      var file = File(iter.current.path);
      String content = await file.readAsString();

      if (content.isNotEmpty) {
        contentsInFiles.add(json.decode(content));
      }
    }
    setState(() => _isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    _loadFiles();
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive, overlays: []);
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
            pathToFile: '',
            deleteMeasurement: _deleteMeasurement,
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
