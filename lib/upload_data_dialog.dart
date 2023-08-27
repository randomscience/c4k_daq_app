import 'package:c4k_daq/upload_result.dart';
import 'package:flutter/material.dart';

class UploadDataDialog extends StatefulWidget {
  final Function exitButton;
  final Function awaitedFunction;

  final Function userInformationGetter;
  final Function exerciseVideoMappingGetter;

  const UploadDataDialog(
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
  String description = 'Trwa wysyłanie danych do zewnętrznego serwera.';

  FilledButton okButton = FilledButton(
    onPressed: () => {},
    child: const Padding(
        padding: EdgeInsets.all(8),
        child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 3.0,
            ))),
  );

  _runAwaitedFunction() async {
    Map<String, String?> userInformation = widget.userInformationGetter();

    for (MapEntry<String, String?> field in userInformation.entries) {
      if (field.value == null) {
        description =
            "Wszystkie wymagane pola muszą być wypełnione przed wysłaniem danych.";
        okButton = FilledButton(
            onPressed: () => widget.exitButton(), child: const Text('Ok'));
        setState(() => isAwaiting = false);
        return;
      }
    }

    Map<String, String?> exerciseVideoMapping =
        widget.exerciseVideoMappingGetter();

    for (MapEntry<String, String?> field in exerciseVideoMapping.entries) {
      if (field.value == null) {
        description =
            "Wszystkie wymagane ćwiczenia muszą być nagrane przed wysłaniem danych. Brakujące nagranie: ${field.key}";
        okButton = FilledButton(
            onPressed: () => widget.exitButton(), child: const Text('Ok'));
        setState(() => isAwaiting = false);
        return;
      }
    }

    List<UploadResult>? result;
    try {
      result = await widget.awaitedFunction();
    } catch (e) {
      description = "Napotkano błąd w aplikacji. Szczegóły dla deweloperów: $e";
      okButton = FilledButton(
          onPressed: () => widget.exitButton(), child: const Text('Ignoruj'));
      setState(() => isAwaiting = false);
      return;
    }

    if (result != null) {
      bool singleOverallResult = true;

      for (var element in result) {
        singleOverallResult = element.isSuccess() && true;
      }

      if (singleOverallResult) {
        description = "Wysyłanie danych zakończyło się powodzeniem.";
        okButton = FilledButton(
            onPressed: () => widget.exitButton(), child: const Text('Ok'));
        setState(() => isAwaiting = false);
        return;
      } else {
        description =
            "Nastąpił błąd połączenia z serwerem, dane zapisane zostały w pamięci urządzenia. Szczegóły dla deweloperów:";

        for (var element in result) {
          description = '$description\n${element.body}';
        }

        okButton = FilledButton(
            onPressed: () => widget.exitButton(), child: const Text('Ok'));

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
