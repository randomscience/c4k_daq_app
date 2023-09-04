import 'package:flutter/material.dart'
    show
        BuildContext,
        Center,
        State,
        StatefulWidget,
        Text,
        TextButton,
        Theme,
        Widget;

class Calibration extends StatefulWidget {
  const Calibration({super.key});
  @override
  State<Calibration> createState() => _Calibration();
}

// TODO floating overlay https://pub.dev/packages/floating_overlay
class _Calibration extends State<Calibration> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        child: const Text("Calibration"),
        onPressed: () {},
      ),
    );
  }
}
