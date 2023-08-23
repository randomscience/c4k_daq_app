import 'package:c4k_daq/measurement_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    int textInt;
    try {
      textInt = int.parse(text);
    } catch (e) {
      return 'Wprowadź liczbę';
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
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      keyboardType: TextInputType.number,
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
