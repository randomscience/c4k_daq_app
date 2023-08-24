import 'dart:io';

import 'package:flutter/material.dart'
    show
        BuildContext,
        Center,
        ListView,
        State,
        StatefulWidget,
        Text,
        Theme,
        Widget;

import 'package:path_provider/path_provider.dart';

class Library extends StatefulWidget {
  const Library({super.key});

  @override
  State<Library> createState() => _Library();
}

class _Library extends State<Library> {
  String directory = '';
  List file = [];
  @override
  void initState() {
    super.initState();
    _listofFiles();
  }

  // Make New Function
  void _listofFiles() async {
    directory = (await getApplicationDocumentsDirectory()).path;
    setState(() {
      file = Directory("$directory/c4k_daq/")
          .listSync(); //use your folder name insted of resume.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView.builder(
          itemCount: file.length,
          itemBuilder: (BuildContext context, int index) {
            return Text(file[index].toString());
          }),
    );
  }
}
