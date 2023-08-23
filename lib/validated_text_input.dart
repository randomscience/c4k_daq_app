import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ValidatedTextInput extends StatefulWidget {
  Function userInformationGetter;
  String mapKey;
  String title;
  String hintText;
  ValidatedTextInput(
      {super.key,
      required this.userInformationGetter,
      required this.mapKey,
      required this.title,
      required this.hintText});

  TextEditingController controller = TextEditingController();

  String? _errorText() {
    final text = controller.value.text;
    if (text.isEmpty) {
      return 'Can\'t be empty';
    }
    int textInt;
    try {
      textInt = int.parse(text);
    } catch (e) {
      return 'Provided text must be int';
    }
    if (textInt >= 200) {
      return 'Too long';
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
      onChanged: (text) => setState(
          () => {widget.userInformationGetter()[widget.mapKey] = text}),
    );
  }
}
