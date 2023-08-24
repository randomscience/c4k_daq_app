import 'dart:io';
import 'dart:convert';

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

  void _loadFiles() async {
    String directory = (await getApplicationDocumentsDirectory()).path;
    List<FileSystemEntity> directoriesInFile =
        Directory("$directory/c4k_daq/").listSync();

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
    } else {
      return Center(
          child: ListView.builder(
        itemCount: contentsInFiles.length,
        itemBuilder: (context, index) {
          return LibraryCard(
              localJsonData: Map<String, dynamic>.from(contentsInFiles[index]),
              pathToFile: '');
        },
      ));
    }
  }
}
