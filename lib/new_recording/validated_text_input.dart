import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ValidatedTextInput extends StatefulWidget {
  final Function userInformationGetter;
  final String mapKey;
  final String title;
  final String hintText;
  final TextEditingController controller = TextEditingController();

  ValidatedTextInput(
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
    if (textInt >= 200) {
      return 'Wprowadzono za dużą wartość';
    }
    if (textInt < 20) {
      return 'Wprowadzono za małą wartość';
    }
    return null;
  }

  @override
  State<ValidatedTextInput> createState() => ValidatedTextInputState();
}

class ValidatedTextInputState extends State<ValidatedTextInput> {
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
