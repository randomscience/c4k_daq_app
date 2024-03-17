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
      required this.exerciseVideoMappingGetter,
      required this.userInformationGetter,
      required this.saveToFile});

  final Map<String, String?> Function() userInformationGetter;
  final Map<String, String?> Function() exerciseVideoMappingGetter;

  final Function showVideoModal;
  final Function showPhotoModal;

  final void Function(Map<String, String?>, Map<String, String?>,
      {String? uuid}) saveToFile;

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
      _textFieldGenerator(id, 'Wpisz ID z ankiety', 'Unikatowe ID dziecka',
          isID: true),
      _textFieldGenerator(height, 'Wpisz wzrost dziecka', 'Wzrost [cm]'),
      _textFieldGenerator(age, 'Wpisz wiek dziecka', 'Wiek [lata]'),
      _textFieldGenerator(sex, 'Wpisz biologiczną płeć dziecka', 'Wiek [lata]'),
      _exerciseGenerator(
          exercise1, "Zrób zdjęcie w pozycji 'T', przodem do kamery"),
      _exerciseGenerator(exercise2,
          "Zrób zdjęcie w pozycji stania na Baczność, przodem do kamery"),
      _exerciseGenerator(exercise3,
          "Zrób zdjęcie w pozycji stania na Baczność, lewym profilem do kamery"),
      _exerciseGenerator(exercise4,
          "Zrób zdjęcie w pozycji stania na Baczność, prawym profilem do kamery"),
      _exerciseGenerator(exercise5,
          "Nagraj dziecko idące przodem do kamery, z punktu D do punktu B"),
      _exerciseGenerator(exercise6,
          "Nagraj dziecko idące przodem do kamery, z punktu D do punktu B"),
      _exerciseGenerator(exercise7,
          "Nagraj dziecko idące przodem do kamery, z punktu D do punktu B"),
      _exerciseGenerator(exercise8,
          "Nagraj dziecko idące profilem do kamery, z punktu L do punktu P"),
      _exerciseGenerator(exercise9,
          "Nagraj dziecko idące profilem do kamery, z punktu L do punktu P"),
      _exerciseGenerator(exercise10,
          "Nagraj dziecko idące profilem do kamery, z punktu L do punktu P"),
      _exerciseGenerator(exercise11, "Nagraj dziecko skaczące wzwyż 5 razy"),
      _exerciseGenerator(
          exercise12, "Nagraj dziecko wykonujące w miejsu, skip A"),
      _exerciseGenerator(exercise13, "Nagraj dziecko trzymające ciężarki"),
      _exerciseGenerator(
          exercise14, "Przekarz dziecku telefon, z grą zręcznościową"),
      const Step(
          state: StepState.complete,
          title: Text("Zapisz pomiar"),
          content: Text(
              "Dziękujemy za wykonany pomiar, dane zostaną wysłane do naszej prywatnej bazy danych")),
    ];
  }

  _stepType(int index) {
    const listOfStepTypes = [
      StepTypes.inputBox,
      StepTypes.inputBox,
      StepTypes.inputBox,
      StepTypes.inputBox,
      StepTypes.photoCamera,
      StepTypes.photoCamera,
      StepTypes.photoCamera,
      StepTypes.photoCamera,
      StepTypes.videoCamera,
      StepTypes.videoCamera,
      StepTypes.videoCamera,
      StepTypes.videoCamera,
      StepTypes.videoCamera,
      StepTypes.videoCamera,
      StepTypes.videoCamera,
      StepTypes.videoCamera,
      StepTypes.videoCamera,
      StepTypes.game,
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

  _exerciseGenerator(String title, String exerciseExplanation) {
    StepState state = StepState.indexed;

    if (widget.exerciseVideoMappingGetter()[exerciseNameConverter(title)] !=
        null) {
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
    await widget.showVideoModal(textField.data);
    // if (widget.exerciseVideoMappingGetter()[_steps()[_index].title] != null) {
    setState(() {
      _index = _index + 1;
    });
    // }
  }

  _takePicture() async {
    Text textField = _steps()[_index].title;
    await widget.showPhotoModal(textField.data);
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

              // if (_stepType(_index) == StepTypes.info)
              //   FilledButton(
              //     onPressed: () => {
              //       rotateScreenVIsited = [
              //         rotateScreenVIsited[0] || _index == 5,
              //         rotateScreenVIsited[1] || _index == 12,
              //       ],
              //       controls.onStepContinue!(),
              //     },
              //     child: const Text('Dalej'),
              //   ),
              if (_stepType(_index) == StepTypes.videoCamera)
                FilledButton(
                  onPressed: _recordVideo,
                  child: const Text(
                    "Nagraj wideo",
                  ),
                ),
              if (_stepType(_index) == StepTypes.photoCamera)
                FilledButton(
                  onPressed: _takePicture,
                  child: const Text('Wykonaj zdjęcie'),
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
                          // rotateScreenVIsited = [false, false];
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
