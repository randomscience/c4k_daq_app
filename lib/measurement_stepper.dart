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
      required this.userInformationGetter});

  final Function userInformationGetter;
  final Function exerciseVideoMappingGetter;

  final Function showModalBottomSheet;

  final Function saveMeasurement;

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
          'Wpisz odległość od obojczyka do ziemi',
          'Odległość od obojczyka do ziemi [cm]'),
      _textFieldGenerator(pelvisToFloor, 'Wpisz odległość od pasa do ziemi',
          'Odległość od pasa do ziemi [cm]'),
      Step(
          isActive: rotateScreenVIsited[0],
          state:
              rotateScreenVIsited[0] ? StepState.complete : StepState.indexed,
          title: const Text("Obróć telefon"),
          content: const Text(
              "Obróć telefon tak żeby znajdował sie w pozycji wertykalnej")),
      _exerciseGenerator(
          "Ćwiczenie 1", "Nagraj dziecko idace od punktu N do punktu S"),
      _exerciseGenerator(
          "Ćwiczenie 2", "Nagraj dziecko wykonujące skłony w punkcie O"),
      Step(
          isActive: rotateScreenVIsited[1],
          state:
              rotateScreenVIsited[1] ? StepState.complete : StepState.indexed,
          title: const Text("Obróć telefon"),
          content: const Text(
              "Obróć telefon tak żeby znajdował sie w pozycji horyzontalnej")),
      _exerciseGenerator(
          "Ćwiczenie 3", "Nagraj dziecko idace od punktu L do punktu P"),
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
      StepTypes.info,
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
    if (index <= 5) {
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
      physics: const BouncingScrollPhysics(),
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
                ElevatedButton(
                  onPressed: controls.onStepContinue,
                  child: const Text('DALEJ'),
                ),
              if (_stepType(_index) == StepTypes.info)
                ElevatedButton(
                  onPressed: () => {
                    rotateScreenVIsited = [
                      rotateScreenVIsited[0] || _index == 5,
                      rotateScreenVIsited[1] || _index == 8,
                    ],
                    controls.onStepContinue!(),
                  },
                  child: const Text('DALEJ'),
                ),
              if (_stepType(_index) == StepTypes.camera)
                ElevatedButton(
                  onPressed: _recordVideo,
                  child: const Text(
                    "NAGRAJ WIDEO",
                  ),
                ),
              if (_stepType(_index) == StepTypes.save)
                ElevatedButton(
                  onPressed: _saveMeasurement,
                  child: const Text('WYŚLIJ'),
                ),
              if (_index != 0)
                TextButton(
                  onPressed: controls.onStepCancel,
                  child: const Text(
                    'WRÓĆ',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
            ],
          ),
        );
      },
      steps: _steps(),
    );
  }
}
