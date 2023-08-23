import 'package:flutter/material.dart';

class Information extends StatefulWidget {
  const Information({super.key});
  @override
  State<Information> createState() => _Information();
}

// TODO floating overlay https://pub.dev/packages/floating_overlay
class _Information extends State<Information> {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Text("Information view is not yet implemented",
            style: Theme.of(context).textTheme.headlineMedium));
  }
}
