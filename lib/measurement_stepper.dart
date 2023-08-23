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
      required this.userInformationGetter,
      required this.exerciseVideoMappingGetter,
      required this.setUserInformation});

  final Function userInformationGetter;
  final Function exerciseVideoMappingGetter;

  final Function showModalBottomSheet;

  final Function saveMeasurement;
  final Function setUserInformation;

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
      _exerciseGenerator(
          "Ćwiczenie 1", "Nagraj dziecko idace od punktu N do punktu S"),
      _exerciseGenerator(
          "Ćwiczenie 2", "Nagraj dziecko wykonujace skłony w punkcie O"),
      const Step(
          state: StepState.indexed,
          title: Text("Obróć telefon"),
          content: Text(
              "Obróć telefon tak żeby znajdował sie w pozycji horyzontalnej")),
      _exerciseGenerator(
          "Ćwiczenie 3", "Nagraj dziecko idace od punktu L do punktu P"),
      const Step(
          state: StepState.complete,
          title: Text("Zapisz pomiar"),
          content: Text("TODO: Opis koniec pomiaru")),
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

    if (userInformationGetter()[mapKey] != null) {
      state = StepState.complete;
    }
    var inputBox;
    if (isID) {
      inputBox = ValidatedTextIDInput(
          mapKey: mapKey,
          title: hintText,
          hintText: '',
          userInformationGetter: userInformationGetter);
    } else {
      inputBox = ValidatedTextInput(
          mapKey: mapKey,
          title: hintText,
          hintText: '',
          userInformationGetter: userInformationGetter);
    }

    return Step(
        isActive: state == StepState.complete ? true : false,
        state: state,
        title: Text(title),
        content: inputBox);
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
  var scrollController = ScrollController();

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

  void _animateToIndex(int index) {
    if (index <= 6) {
      scrollController.animateTo(
        index * 40,
        duration: const Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
      );
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
              if (widget._stepType(_index) == StepTypes.inputBox ||
                  widget._stepType(_index) == StepTypes.info)
                ElevatedButton(
                  onPressed: controls.onStepContinue,
                  child: const Text('DALEJ'),
                ),
              if (widget._stepType(_index) == StepTypes.camera)
                ElevatedButton(
                  onPressed: _recordVideo,
                  child: const Text(
                    "NAGRAJ WIDEO",
                  ),
                ),
              if (widget._stepType(_index) == StepTypes.save)
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
      steps: widget._steps(),
    );
  }
}
