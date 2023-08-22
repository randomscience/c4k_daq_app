import 'package:c4k_daq/NewRecording.dart';
import 'package:c4k_daq/upload_result.dart';
import 'package:flutter/material.dart';

class AwaitingButton extends StatefulWidget {
  AwaitingButton({
    super.key,
    required this.awaitedFunction,
    required this.onPress,
  });

  Function onPress;
  Function awaitedFunction;
  @override
  _AwaitingButtonState createState() => _AwaitingButtonState();
}

class _AwaitingButtonState extends State<AwaitingButton> {
  bool _isEnabled = false;
  bool isSuccess = true;
  String explanation = "Upload succeeded";

  _toggleOnAwaitEnd() async {
    List<UploadResult> overallResult = await widget.awaitedFunction();
    for (var element in overallResult) {
      isSuccess = element.isSuccess() && isSuccess;
      if (!element.isSuccess()) {
        explanation =
            'Server responded with status code: ${element.statusCode}, detailed error: ${element.body}. Measurement is saved in library.';
      }
    }
    setState(() => _isEnabled = true);
  }

  @override
  void initState() {
    super.initState();
    _toggleOnAwaitEnd();
  }

  @override
  Widget build(BuildContext context) {
    if (_isEnabled) {
      return TextButton(
        onPressed: () => widget.onPress(),
        child: const Text('ok'),
      );
    } else {
      return TextButton(
        onPressed: () => widget.onPress(),
        child: const CircularProgressIndicator(),
      );
    }
  }
}
