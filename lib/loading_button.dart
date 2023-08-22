import 'package:c4k_daq/NewRecording.dart';
import 'package:flutter/material.dart';

class LoadingButton extends StatefulWidget {
  Function onPressFunction;
  LoadingButton({super.key, required this.onPressFunction});

  @override
  LoadingButtonState createState() => LoadingButtonState();
}

class LoadingButtonState extends State<LoadingButton> {
  bool isAwaiting = true;

  setAwaitingState(bool isAwaiting) {
    setState(() => isAwaiting = isAwaiting);
  }

  @override
  Widget build(BuildContext context) {
    if (isAwaiting) {
      return TextButton(
        onPressed: () => {},
        child: const CircularProgressIndicator(),
      );
    } else {
      return TextButton(
          onPressed: () => widget.onPressFunction(), child: const Text('ok'));
    }
  }
}
