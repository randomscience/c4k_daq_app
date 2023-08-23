import 'package:c4k_daq/saving_states.dart';
import 'package:c4k_daq/upload_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Exercise.dart';

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
  var _text = '';
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

class MeasurementStepper extends StatefulWidget {
  MeasurementStepper(
      {super.key,
      required this.showModalBottomSheet,
      required this.saveMeasurement,
      required this.userInformationGetter,
      required this.exerciseVideoMappingGetter,
      required this.setUserInformation,
      required this.clearData});
  Function userInformationGetter;
  Function exerciseVideoMappingGetter;

  Function clearData;

  Function showModalBottomSheet;

  Function saveMeasurement;
  Function setUserInformation;

  _noSteps() {
    return userInformationGetter().length + exerciseVideoMappingGetter().length;
  }

  _steps() {
    return <Step>[
      _textFieldGenerator("id", 'Enter Unique ID', 'Child ID'),
      _textFieldGenerator(
          "height", 'Enter size of the child', 'Height in [cm]'),
      _textFieldGenerator(
          'nose_to_floor', 'Enter nose to floor', 'Height in [cm]'),
      _textFieldGenerator('collar_bone_to_floor', 'Enter collarbone to floor',
          'Height in [cm]'),
      _textFieldGenerator(
          'pelvis_to_floor', 'Enter d2f of the child', 'Height in [cm]'),
      _exerciseGenerator("Exercise 1", "do a flip, bitch!"),
      const Step(title: Text("Save Measurement"), content: Text("that's it")),
    ];
  }

  _textFieldGenerator(String mapKey, String title, String hintText) {
    bool isActive = false;
    if (userInformationGetter()[mapKey] != null) {
      isActive = true;
    }
    return Step(
        isActive: isActive,
        title: Text(title),
        content: ValidatedTextInput(
            mapKey: mapKey,
            title: title,
            hintText: hintText,
            userInformationGetter: userInformationGetter));
  }

  _exerciseGenerator(String title, String exerciseExplanation) {
    bool isActive = false;
    if (exerciseVideoMappingGetter()[title] != null) {
      isActive = true;
    }

    return Step(
      isActive: isActive,
      title: Text(title),
      content:
          Align(alignment: Alignment.topLeft, child: Text(exerciseExplanation)),
    );
  }

  @override
  State<MeasurementStepper> createState() => _MeasurementStepperState();
}

class Steps {}

class _MeasurementStepperState extends State<MeasurementStepper> {
  _recordVideo() {
    Text textField = widget._steps()[_index].title;

    widget.showModalBottomSheet(textField.data);

    if (widget.exerciseVideoMappingGetter()[widget._steps()[_index].title] !=
        null) {
      setState(() {
        _index = _index + 1;
      });
    }
  }

  _saveMeasurement() {
    widget.saveMeasurement();

    setState(() {
      _index = 0;
    });
  }

  int _index = 0;
  @override
  Widget build(BuildContext context) {
    return Stepper(
      physics: const ClampingScrollPhysics(),
      currentStep: _index,
      onStepCancel: () {
        setState(() {
          _index = _index - 1;
        });
      },
      onStepContinue: () {
        setState(() {
          _index = _index + 1;
        });
      },
      onStepTapped: (int index) {
        setState(() {
          _index = index;
        });
      },
      controlsBuilder: (BuildContext context, ControlsDetails controls) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            children: <Widget>[
              if (_index < widget.userInformationGetter().length)
                ElevatedButton(
                  onPressed: controls.onStepContinue,
                  child: const Text('NEXT'),
                ),
              if (_index >= widget.userInformationGetter().length &&
                  _index < widget._noSteps())
                ElevatedButton(
                  onPressed: _recordVideo,
                  child: const Text(
                    "RECORD VIDEO",
                  ),
                ),
              if (_index == widget._noSteps())
                ElevatedButton(
                  onPressed: _saveMeasurement,
                  child: const Text('SAVE'),
                ),
              if (_index != 0)
                TextButton(
                  onPressed: controls.onStepCancel,
                  child: const Text(
                    'BACK',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
            ],
          ),
        );
      },
      steps: widget._steps(),
    );
  }
}
