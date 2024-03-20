import 'package:c4k_daq/constants.dart';
import 'package:flutter/material.dart';
import 'validated_text_id_input.dart';
import 'validated_text_input.dart';

enum StepTypes { inputBox, videoCamera, photoCamera, info, game, save }

class MeasurementStepper extends StatefulWidget {
  const MeasurementStepper(
      {super.key,
      required this.showVideoModal,
      required this.showPhotoModal,
      required this.userInformationGetter,
      required this.saveToFile});

  final Map<String, String?> Function() userInformationGetter;

  final Function showVideoModal;
  final Function showPhotoModal;

  final void Function(Map<String, String?>, {String? uuid}) saveToFile;

  @override
  State<MeasurementStepper> createState() => _MeasurementStepperState();
}

class _MeasurementStepperState extends State<MeasurementStepper> {
  // var rotateScreenVIsited = [false, false];
  var scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // rotateScreenVIsited = [false, false];
  }

  _steps() {
    List<Step> steps = [];

    for (final e in test) {
      if (e.type == MeasurementType.id) {
        steps.add(_textFieldGenerator(e.uniqueKeyword, e.title, e.description,
            isID: true));
      }
      if (e.type == MeasurementType.number) {
        steps.add(_textFieldGenerator(e.uniqueKeyword, e.title, e.description));
      }
      if (e.type == MeasurementType.dropdown) {
        steps.add(_dropdownGenerator(e.uniqueKeyword, e.title, e.description));
      }
      if (e.type == MeasurementType.photo) {
        steps.add(_exerciseGenerator(e.uniqueKeyword, e.title, e.description));
      }
      if (e.type == MeasurementType.video) {
        steps.add(_exerciseGenerator(e.uniqueKeyword, e.title, e.description));
      }
      if (e.type == MeasurementType.save) {
        steps.add(
          const Step(
              state: StepState.complete,
              title: Text("Zapisz pomiar"),
              content: Text(
                  "Dziękujemy za wykonany pomiar, dane zostaną wysłane do naszej prywatnej bazy danych")),
        );
      }
    }
    return steps;
  }

  _dropdownGenerator(String mapKey, String title, String hintText) {
    StepState state = StepState.indexed;
    String? dropdownValue;
    if (widget.userInformationGetter().containsKey(mapKey)) {
      state = StepState.complete;
      dropdownValue = widget.userInformationGetter()[mapKey]!;
    }

    StatefulWidget inputBox = DropdownButton(
        value: dropdownValue,
        hint: Text(hintText),
        items: const [
          DropdownMenuItem(
            value: "male",
            child: Text("Mężczyzna"),
          ),
          DropdownMenuItem(
            value: "female",
            child: Text("Kobieta"),
          )
        ],
        onChanged: (String? newValue) {
          setState(() {
            widget.userInformationGetter()[mapKey] = newValue!;
          });
        });

    return Step(
        isActive: state == StepState.complete ? true : false,
        state: state,
        title: Text(title),
        content: inputBox);
  }

  _textFieldGenerator(String mapKey, String title, String hintText,
      {bool isID = false}) {
    StepState state = StepState.indexed;

    if (widget.userInformationGetter().containsKey(mapKey)) {
      state = StepState.complete;
    }

    StatefulWidget inputBox;
    if (isID) {
      inputBox = ValidatedTextIDInput(
          mapKey: mapKey,
          title: hintText,
          hintText: '',
          userInformationGetter: widget.userInformationGetter);
    } else {
      inputBox = ValidatedTextInput(
          mapKey: mapKey,
          title: hintText,
          hintText: '',
          userInformationGetter: widget.userInformationGetter);
    }

    return Step(
        isActive: state == StepState.complete ? true : false,
        state: state,
        title: Text(title),
        content: inputBox);
  }

  _exerciseGenerator(String mapKey, String title, String exerciseExplanation) {
    StepState state = StepState.indexed;

    if (widget.userInformationGetter().containsKey(mapKey)) {
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

  _recordVideo() async {
    // Text textField = _steps()[_index].title;
    await widget.showVideoModal(_index);
    // if (widget.exerciseVideoMappingGetter()[_steps()[_index].title] != null) {
    setState(() {
      _index = _index + 1;
    });
    // }
  }

  _takePicture() async {
    // Text textField = _steps()[_index].title;
    await widget.showPhotoModal(_index);
    // if (widget.exerciseVideoMappingGetter()[_steps()[_index].title] != null) {
    setState(() {
      _index = _index + 1;
    });
    // }
  }

  void _animateToIndex(int index) {
    if (index <= 9) {
      scrollController.animateTo(
        index * 32,
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  bool enableSave() {
    return true;
  }

  int _index = 0;
  @override
  Widget build(BuildContext context) {
    return Stepper(
      controller: scrollController,
      physics: const ClampingScrollPhysics(),
      currentStep: _index,
      onStepCancel: () {
        _animateToIndex(_index - 1);
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
        print(index);
        _animateToIndex(index);
        setState(() {
          _index = index;
        });
      },
      controlsBuilder: (BuildContext context, ControlsDetails controls) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
          child: Row(
            children: <Widget>[
              if (test[_index].type == MeasurementType.id ||
                  test[_index].type == MeasurementType.number ||
                  test[_index].type == MeasurementType.dropdown)
                FilledButton(
                  onPressed: controls.onStepContinue,
                  child: const Text('Dalej'),
                ),
              if (test[_index].type == MeasurementType.video)
                FilledButton(
                  onPressed: _recordVideo,
                  child: const Text(
                    "Nagraj wideo",
                  ),
                ),
              if (test[_index].type == MeasurementType.photo)
                FilledButton(
                  onPressed: _takePicture,
                  child: const Text('Wykonaj zdjęcie'),
                ),
              if (test[_index].type == MeasurementType.save)
                Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                    child: FilledButton(
                      onPressed: enableSave()
                          ? () async => {
                                widget
                                    .saveToFile(widget.userInformationGetter()),
                                _animateToIndex(0),
                                setState(() {
                                  _index = 0;
                                })
                              }
                          : null,
                      child: const Text('Zapisz'),
                    )),
              if (_index != 0 && test[_index].type == MeasurementType.save)
                Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                    child: FilledButton.tonal(
                      onPressed: controls.onStepCancel,
                      child: const Text(
                        'Wróć',
                        // style: TextStyle(color: Colors.grey),
                      ),
                    )),
            ],
          ),
        );
      },
      steps: _steps(),
    );
  }
}
