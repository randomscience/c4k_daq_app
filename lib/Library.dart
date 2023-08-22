import 'package:flutter/material.dart';

class Library extends StatefulWidget {
  const Library({super.key});
  @override
  State<Library> createState() => _Library();
}

class _Library extends State<Library> {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Text("Library view is not yet implemented",
            style: Theme.of(context).textTheme.headlineMedium));
  }
}
