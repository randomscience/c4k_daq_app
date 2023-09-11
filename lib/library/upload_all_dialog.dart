import 'dart:async';
import 'dart:io';

import 'package:c4k_daq/upload_measurement.dart';
import 'package:c4k_daq/upload_result.dart';
import 'package:flutter/material.dart';

class UploadAllDialog extends StatefulWidget {
  final void Function() exitButton;
  final Map<String, Map<String, dynamic>?> measurementFiles;
  final void Function(int) updateBadgeNumber;
  const UploadAllDialog({
    super.key,
    required this.exitButton,
    required this.measurementFiles,
    required this.updateBadgeNumber,
  });

  @override
  State<UploadAllDialog> createState() => _UploadAllDialogState();
}

class _UploadAllDialogState extends State<UploadAllDialog>
    with TickerProviderStateMixin {
  late int _noMeasurements;
  late int _currentNoMeasurements;
  late AnimationController controller;
  String? _message;

  @override
  void initState() {
    super.initState();
    _noMeasurements = widget.measurementFiles.keys.length;
    _currentNoMeasurements = widget.measurementFiles.keys.length;
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(() {
        setState(() {});
      });
    controller.repeat();

    _uploadAll();
  }

  void _uploadAll() async {
    setState(
        () => _currentNoMeasurements = widget.measurementFiles.keys.length);

    List<String> measurementsInFile = List.from(widget.measurementFiles.keys);

    for (String measurementConfigFilePath in measurementsInFile) {
      List<UploadResult> overallResult = [];

      try {
        overallResult =
            await uploadMeasurementFromPath(measurementConfigFilePath);
      } on TimeoutException {
        logError(
            "Measurement upload failed, measurement path: $measurementConfigFilePath",
            errorType: "TimeoutException");
        setState(() => {
              _currentNoMeasurements = widget.measurementFiles.keys.length,
              _message =
                  "Wysyłanie pomiaru trwa za długo, połączenie internetowe jest za wolne"
            });
        return;
      } on SocketException {
        setState(() => {
              _currentNoMeasurements = widget.measurementFiles.keys.length,
              _message =
                  "Brak połączenia z serwerem, sprawdź ustawienia internetu"
            });
        return;
      } catch (x) {
        logError(
            "Measurement upload failed, Unknown error: $x, measurement path: $measurementConfigFilePath",
            errorType: x.runtimeType.toString());
        setState(() => {
              _currentNoMeasurements = widget.measurementFiles.keys.length,
              _message =
                  "Napotkano nieznany błąd, szczegóły dla developerów: $x"
            });
        return;
      }

      bool singleOverallResult = true;

      for (var element in overallResult) {
        singleOverallResult = element.isSuccess() && singleOverallResult;
      }

      if (singleOverallResult && overallResult.isNotEmpty) {
        if (!mounted) return;
        deleteMeasurement(measurementConfigFilePath);
        widget.measurementFiles.remove(measurementConfigFilePath);
        widget.updateBadgeNumber(widget.measurementFiles.keys.length);

        if (!mounted) return;
        if (_currentNoMeasurements <= 0) {
          setState(() => {
                _currentNoMeasurements = widget.measurementFiles.keys.length,
                _message = "All measurements are uploaded"
              });
          return;
        } else {
          setState(() =>
              _currentNoMeasurements = widget.measurementFiles.keys.length);
        }
      } else {
        setState(() => {
              _currentNoMeasurements = widget.measurementFiles.keys.length,
              _message = "upload failed"
            });
        return;
      }
    }
    if (!mounted) return;
    if (_currentNoMeasurements <= 0) {
      setState(() => {
            _currentNoMeasurements = widget.measurementFiles.keys.length,
            _message = "All measurements are uploaded"
          });
    } else {
      setState(
          () => _currentNoMeasurements = widget.measurementFiles.keys.length);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Text buttonText;
    if (_message == null) {
      buttonText = const Text('Anuluj Wysyłanie');
    } else {
      buttonText = const Text('Ok');
    }

    return SingleChildScrollView(
        child: ListBody(
      children: <Widget>[
        if (_message == null)
          Text(
              "Wysyłanie pomiaru (${1 + _noMeasurements - _currentNoMeasurements}/$_noMeasurements)"),
        if (_message == null)
          LinearProgressIndicator(
            value: controller.value,
            semanticsLabel: 'Linear progress indicator',
          ),
        if (_message != null) Text(_message!),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Align(
                alignment: Alignment.bottomRight,
                child: FilledButton.tonal(
                    onPressed: () => widget.exitButton(), child: buttonText)),
          ],
        )
      ],
    ));
  }
}
