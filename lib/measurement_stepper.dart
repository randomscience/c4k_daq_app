import 'package:c4k_daq/constants.dart';
import 'package:flutter/material.dart';
import 'validated_text_input.dart';

enum StepTypes { inputBox, camera, info, save }

class MeasurementStepper extends StatefulWidget {
  const MeasurementStepper(
      {super.key,
      required this.showModalBottomSheet,
      required this.saveMeasurement,
      required this.userInformationGetter,
      required this.exerciseVideoMappingGetter,
      required this.setUserInformation,
      required this.clearData});

  final Function userInformationGetter;
  final Function exerciseVideoMappingGetter;

  final Function clearData;

  final Function showModalBottomSheet;

  final Function saveMeasurement;
  final Function setUserInformation;

  _noSteps() {
    return userInformationGetter().length + exerciseVideoMappingGetter().length;
  }

  _steps() {
    return <Step>[
      _textFieldGenerator(id, 'Enter Unique ID', 'Child ID'),
      _textFieldGenerator(height, 'Enter size of the child', 'Height in [cm]'),
      _textFieldGenerator(noseToFloor, 'Enter nose to floor', 'Height in [cm]'),
      _textFieldGenerator(
          collarBoneToFloor, 'Enter collarbone to floor', 'Height in [cm]'),
      _textFieldGenerator(
          pelvisToFloor, 'Enter d2f of the child', 'Height in [cm]'),
      _exerciseGenerator("Exercise 1", "do a flip, bitch!"),
      const Step(
          title: Text("Rotate the phone"),
          content: Text("rotate horizontally")),
      _exerciseGenerator("Exercise 2", "do a flip, bitch!"),
      const Step(title: Text("Save Measurement"), content: Text("that's it")),
    ];
  }

  _stepType(int index) {
    const listOfStepTypes = [
      StepTypes.inputBox,
      StepTypes.inputBox,
      StepTypes.inputBox,
      StepTypes.inputBox,
      StepTypes.inputBox,
      StepTypes.camera,
      StepTypes.info,
      StepTypes.camera,
      StepTypes.save
    ];
    return listOfStepTypes[index];
  }

  _textFieldGenerator(String mapKey, String title, String hintText) {
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
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
          child: Row(
            children: <Widget>[
              if (widget._stepType(_index) == StepTypes.inputBox ||
                  widget._stepType(_index) == StepTypes.info)
                ElevatedButton(
                  onPressed: controls.onStepContinue,
                  child: const Text('NEXT'),
                ),
              if (widget._stepType(_index) == StepTypes.camera)
                ElevatedButton(
                  onPressed: _recordVideo,
                  child: const Text(
                    "RECORD VIDEO",
                  ),
                ),
              if (widget._stepType(_index) == StepTypes.save)
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
