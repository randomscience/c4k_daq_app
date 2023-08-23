import 'package:flutter/material.dart';
import 'validated_text_input.dart';

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

    StepState state = StepState.indexed;

    if (userInformationGetter()[mapKey] != null) {
      state = StepState.complete;
    }

    return Step(
        isActive: state == StepState.complete ? true : false,
        state: state,
        title: Text(title),
        content: ValidatedTextInput(
            mapKey: mapKey,
            title: title,
            hintText: hintText,
            userInformationGetter: userInformationGetter));
  }

  _exerciseGenerator(String title, String exerciseExplanation) {
    StepState state = StepState.indexed;

    if (exerciseVideoMappingGetter()[title] != null) {
      state = StepState.complete;
    }

    return Step(
      isActive: state == StepState.complete ? true : false,
      state: state,
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
                if (widget.exerciseVideoMappingGetter()[
                        widget._steps()[_index].title] !=
                    null)
                  ElevatedButton(
                    onPressed: _recordVideo,
                    child: const Text(
                      "RE_RECORD VIDEO",
                    ),
                  ),
              if (_index >= widget.userInformationGetter().length &&
                  _index < widget._noSteps())
                if (widget.exerciseVideoMappingGetter()[
                        widget._steps()[_index].title] ==
                    null)
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
