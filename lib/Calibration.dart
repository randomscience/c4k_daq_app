import 'package:flutter/material.dart';

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
        child: Text("Calibration view is not yet implemented",
            style: Theme.of(context).textTheme.headlineMedium));
  }
}
