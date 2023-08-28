import 'package:c4k_daq/constants.dart';
import 'package:flutter/material.dart';
import 'validated_text_id_input.dart';
import 'validated_text_input.dart';

enum StepTypes { inputBox, camera, info, save }

class MeasurementStepper extends StatefulWidget {
  const MeasurementStepper(
      {super.key,
      required this.showModalBottomSheet,
      required this.saveMeasurement,
      required this.exerciseVideoMappingGetter,
      required this.userInformationGetter,
      required this.saveToFile});

  // _saveToFile(Map<String, String?> userInformation,
  //     Map<String, String?> exerciseVideoMapping,
  //     {String? uuid})

  final Map<String, String?> Function() userInformationGetter;
  final Map<String, String?> Function() exerciseVideoMappingGetter;

  final Function showModalBottomSheet;

  final Function saveMeasurement;

  final void Function(Map<String, String?>, Map<String, String?>,
      {String? uuid}) saveToFile;

  @override
  State<MeasurementStepper> createState() => _MeasurementStepperState();
}

class _MeasurementStepperState extends State<MeasurementStepper> {
  var rotateScreenVIsited = [false, false];
  var scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    rotateScreenVIsited = [false, false];
  }

  _enableSave() {
    for (MapEntry<String, String?> field
        in widget.userInformationGetter().entries) {
      if (field.value == null) {
        return false;
      }
    }

    for (MapEntry<String, String?> field
        in widget.exerciseVideoMappingGetter().entries) {
      if (field.value == null) {
        return false;
      }
    }

    return true;
  }

  _steps() {
    return <Step>[
      _textFieldGenerator(
          id, 'Wpisz ID ktore otrzymałeś z ankiety', 'Unikatowe ID dziecka',
          isID: true),
      _textFieldGenerator(height, 'Wpisz wzrost dziecka', 'Wzrost [cm]'),
      _textFieldGenerator(noseToFloor, 'Wpisz odległość od ziemi do nosa',
          'Odległość od ziemi do nosa [cm]'),
      _textFieldGenerator(
          collarBoneToFloor,
          'Wpisz odległość od ziemi do obojczyka',
          'Odległość od ziemi do obojczyka [cm]'),
      _textFieldGenerator(pelvisToFloor, 'Wpisz odległość od ziemi do bioder',
          'Odległość od ziemi do bioder [cm]'),
      Step(
          isActive: rotateScreenVIsited[0],
          state:
              rotateScreenVIsited[0] ? StepState.complete : StepState.indexed,
          title: const Text("Ustaw telefon w pozycji pionowej"),
          content: const Text(
              "Obróć telefon tak żeby znajdował sie w pozycji pionowej")),
      _exerciseGenerator(exercise1,
          "Nagraj dziecko idace przodem do kamery, z punktu D do punktu B"),
      _exerciseGenerator(exercise2,
          "Nagraj dziecko idace przodem do kamery, z punktu D do punktu B"),
      _exerciseGenerator(exercise3,
          "Nagraj dziecko idace przodem do kamery, z punktu D do punktu B"),
      _exerciseGenerator(exercise4,
          "Nagraj dziecko wykonujące skłony przodem do kamery, w punkcie S"),
      _exerciseGenerator(exercise5,
          "Nagraj dziecko wykonujące skłony przodem do kamery, w punkcie S"),
      _exerciseGenerator(exercise6,
          "Nagraj dziecko wykonujące skłony przodem do kamery, w punkcie S"),
      Step(
          isActive: rotateScreenVIsited[1],
          state:
              rotateScreenVIsited[1] ? StepState.complete : StepState.indexed,
          title: const Text("Ustaw telefon w pozycji poziomej"),
          content: const Text(
              "Obróć telefon tak żeby znajdował sie w pozycji poziomej")),
      _exerciseGenerator(exercise7,
          "Nagraj dziecko idace profilem do kamery, z punktu L do punktu P"),
      _exerciseGenerator(exercise8,
          "Nagraj dziecko idace profilem do kamery, z punktu L do punktu P"),
      _exerciseGenerator(exercise9,
          "Nagraj dziecko idace profilem do kamery, z punktu L do punktu P"),
      Step(
          state: _enableSave() ? StepState.complete : StepState.disabled,
          title: const Text("Zapisz pomiar"),
          content: const Text(
              "Dziękujemy za wykonany pomiar, dane zostaną wysłane do naszej prywatnej bazy danych")),
    ];
  }

  _stepType(int index) {
    const listOfStepTypes = [
      StepTypes.inputBox,
      StepTypes.inputBox,
      StepTypes.inputBox,
      StepTypes.inputBox,
      StepTypes.inputBox,
      StepTypes.info,
      StepTypes.camera,
      StepTypes.camera,
      StepTypes.camera,
      StepTypes.camera,
      StepTypes.camera,
      StepTypes.camera,
      StepTypes.info,
      StepTypes.camera,
      StepTypes.camera,
      StepTypes.camera,
      StepTypes.save
    ];
    return listOfStepTypes[index];
  }

  _textFieldGenerator(String mapKey, String title, String hintText,
      {bool isID = false}) {
    StepState state = StepState.indexed;

    if (widget.userInformationGetter()[mapKey] != null) {
      state = StepState.complete;
    }
    var inputBox;
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

  _exerciseGenerator(String title, String exerciseExplanation) {
    StepState state = StepState.indexed;

    if (widget.exerciseVideoMappingGetter()[title] != null) {
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
    Text textField = _steps()[_index].title;
    await widget.showModalBottomSheet(textField.data);
    // if (widget.exerciseVideoMappingGetter()[_steps()[_index].title] != null) {
    setState(() {
      _index = _index + 1;
    });
    // }
  }

  void _animateToIndex(int index) {
    if (index <= 9) {
      scrollController.animateTo(
        index * 30,
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  _saveMeasurement() {
    widget.saveMeasurement();
    _animateToIndex(0);
    setState(() {
      _index = 0;
      rotateScreenVIsited = [false, false];
    });
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
              if (_stepType(_index) == StepTypes.inputBox)
                FilledButton(
                  onPressed: controls.onStepContinue,
                  child: const Text('Dalej'),
                ),
              if (_stepType(_index) == StepTypes.info)
                FilledButton(
                  onPressed: () => {
                    rotateScreenVIsited = [
                      rotateScreenVIsited[0] || _index == 5,
                      rotateScreenVIsited[1] || _index == 12,
                    ],
                    controls.onStepContinue!(),
                  },
                  child: const Text('Dalej'),
                ),
              if (_stepType(_index) == StepTypes.camera)
                FilledButton(
                  onPressed: _recordVideo,
                  child: const Text(
                    "Nagraj wideo",
                  ),
                ),
              if (_stepType(_index) == StepTypes.save)
                FilledButton(
                  onPressed: _saveMeasurement,
                  child: const Text('Wyślij'),
                ),
              if (_stepType(_index) == StepTypes.save)
                Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                    child: FilledButton.tonal(
                      onPressed: () async => {
                        widget.saveToFile(widget.userInformationGetter(),
                            widget.exerciseVideoMappingGetter()),
                        _animateToIndex(0),
                        setState(() {
                          _index = 0;
                          rotateScreenVIsited = [false, false];
                        })
                      },
                      child: const Text('Zapisz'),
                    )),
              if (_index != 0 && _stepType(_index) != StepTypes.save)
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
