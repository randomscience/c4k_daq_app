import 'package:c4k_daq/NewRecording.dart';
import 'package:c4k_daq/upload_result.dart';
import 'package:flutter/material.dart';

class UploadDataDialog extends StatefulWidget {
  Function exitButton;
  Function awaitedFunction;

  Function userInformationGetter;
  Function exerciseVideoMappingGetter;

  UploadDataDialog(
      {super.key,
      required this.exitButton,
      required this.userInformationGetter,
      required this.exerciseVideoMappingGetter,
      required this.awaitedFunction});
  @override
  UploadDataDialogState createState() => UploadDataDialogState();
}

class UploadDataDialogState extends State<UploadDataDialog> {
  bool isAwaiting = true;
  String description = 'Uploading data to remote database.';

  TextButton okButton = TextButton(
    onPressed: () => {},
    child: const CircularProgressIndicator(),
  );

  _runAwaitedFunction() async {
    Map<String, String?> userInformation = widget.userInformationGetter();

    for (MapEntry<String, String?> field in userInformation.entries) {
      if (field.value == null) {
        description = "Fill out all required fields before uploading data!";
        okButton = TextButton(
            onPressed: () => widget.exitButton(), child: const Text('ok'));
        setState(() => isAwaiting = false);
        return;
      }
    }

    Map<String, String?> exerciseVideoMapping =
        widget.exerciseVideoMappingGetter();

    for (MapEntry<String, String?> field in exerciseVideoMapping.entries) {
      if (field.value == null) {
        description =
            "Record all required exercises before uploading data! Missing exercise: ${field.key}";
        okButton = TextButton(
            onPressed: () => widget.exitButton(), child: const Text('ok'));
        setState(() => isAwaiting = false);
        return;
      }
    }

    List<UploadResult>? result;
    try {
      result = await widget.awaitedFunction();
    } catch (e) {
      description = 'Unknown Application Error accrued. details:$e';
      okButton = TextButton(
          onPressed: () => widget.exitButton(), child: const Text('ok'));
      setState(() => isAwaiting = false);
      return;
    }

    if (result != null) {
      bool singleOverallResult = true;
      result.forEach(
          (element) => singleOverallResult = element.isSuccess() && true);

      if (singleOverallResult) {
        description = "Upload succeeded! There's no more to be done.";
        okButton = TextButton(
            onPressed: () => widget.exitButton(), child: const Text('ok'));
        setState(() => isAwaiting = false);
        return;
      } else {
        description = "Upload failed, here's list of responses:";

        result.forEach(
            (element) => description = '$description\n${element.body}');

        okButton = TextButton(
            onPressed: () => widget.exitButton(), child: const Text('ok'));

        setState(() => isAwaiting = false);
        return;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _runAwaitedFunction();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: ListBody(
      children: <Widget>[
        Text(description),
        Align(alignment: Alignment.bottomRight, child: okButton)
      ],
    ));
  }
}
