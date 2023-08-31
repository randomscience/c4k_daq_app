import 'package:flutter/material.dart';

class ValidatedTextIDInput extends StatefulWidget {
  final Function userInformationGetter;
  final String mapKey;
  final String title;
  final String hintText;
  final TextEditingController controller = TextEditingController();

  ValidatedTextIDInput(
      {super.key,
      required this.userInformationGetter,
      required this.mapKey,
      required this.title,
      required this.hintText});

  String? _errorText() {
    final text = controller.value.text;
    if (text.isEmpty) {
      return 'Pole nie może być puste';
    }
    return null;
  }

  @override
  State<ValidatedTextIDInput> createState() => ValidatedTextIDInputState();
}

class ValidatedTextIDInputState extends State<ValidatedTextIDInput> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() =>
        widget.userInformationGetter()[widget.mapKey] = widget.controller.text);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.userInformationGetter()[widget.mapKey] != null) {
      widget.controller.text =
          widget.userInformationGetter()[widget.mapKey].toString();
    }

    return TextField(
      // onChanged: (text) => setState(),
      controller: widget.controller,

      decoration: InputDecoration(
        errorText: widget._errorText(),
        labelText: widget.title,
        hintText: widget.hintText,
      ),
      onChanged: (text) =>
          setState(() => widget.userInformationGetter()[widget.mapKey] = text),
    );
  }
}
