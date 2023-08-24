import 'package:flutter/material.dart';

class LibraryCard extends StatefulWidget {
  final Map<String, dynamic> localJsonData;
  const LibraryCard({super.key, required this.localJsonData});

  @override
  State<LibraryCard> createState() => _LibraryCard();
}

class _LibraryCard extends State<LibraryCard> {
  String id = "";
  String measurementTime = "";
  @override
  void initState() {
    super.initState();
    id = widget.localJsonData['id'];
    measurementTime = widget.localJsonData['measurement_time'];
  }

  void _retryUpload() {}

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
          child: Column(children: [
        Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 6, 6),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Id: $id", style: const TextStyle(fontSize: 24)))),
        Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 6, 6),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Date: $measurementTime",
                    style: const TextStyle(fontSize: 16)))),
        Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 6, 6),
            child: Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                    onPressed: () => {_retryUpload()},
                    child: const Text('Retry upload'))))
      ])),
    );
  }
}
