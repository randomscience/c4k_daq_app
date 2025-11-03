import 'dart:convert';
import 'dart:io';

const measurementTime = "measurement_time";

enum MeasurementType { id, number, dropdown, photo, video, save }

enum CameraOrientation { vertical, horizontal, none }

enum MeasurementGroup {
  generalInfo,
  photos,
  poseVideos,
  superPowersVideos,
  save
}

class Measurement {
  late MeasurementType type;
  late String title;
  late String description;
  late MeasurementGroup group;
  late String uniqueKeyword;
  late bool isRequired;
  late CameraOrientation cameraOrientation;
  Measurement(
      {required this.type,
      required this.title,
      required this.description,
      required this.group,
      required this.uniqueKeyword,
      this.cameraOrientation = CameraOrientation.none,
      this.isRequired = false});
}

_generateMeasurementList() async {
  var input = await File("assets/exercises.json").readAsString();
  var map = jsonDecode(input);
  print(map);
  var list = [
    Measurement(
        type: MeasurementType.save,
        title: "",
        description: '',
        group: MeasurementGroup.save,
        uniqueKeyword: "")
  ];
  return list;
}

List<Measurement> measurementList = [
  Measurement(
      type: MeasurementType.id,
      title: 'The Kidly ID',
      description: 'Wpisz Unikatowe ID dziecka',
      group: MeasurementGroup.generalInfo,
      uniqueKeyword: "theKidlyId",
      isRequired: true),
  Measurement(
      type: MeasurementType.number,
      title: 'Wzrost',
      description: 'Wpisz wzrost [cm]',
      group: MeasurementGroup.generalInfo,
      uniqueKeyword: "height",
      isRequired: true),
  Measurement(
      type: MeasurementType.number,
      title: 'Wiek',
      description: 'Wpisz wiek [lata]',
      group: MeasurementGroup.generalInfo,
      uniqueKeyword: "age",
      isRequired: true),
  Measurement(
      type: MeasurementType.dropdown,
      title: 'Płeć',
      description: 'Wybierz biologiczną płeć',
      group: MeasurementGroup.generalInfo,
      uniqueKeyword: "sex",
      isRequired: true),
  Measurement(
      type: MeasurementType.photo,
      title: '(1) Zdjęcie w pozycji "T"',
      description: 'Zrób zdjęcie w pozycji "T", przodem do kamery',
      group: MeasurementGroup.photos,
      uniqueKeyword: "t_pose_photo_front_1",
      cameraOrientation: CameraOrientation.vertical,
      isRequired: true),
  Measurement(
      type: MeasurementType.photo,
      title: '(1) Zdjęcie w pozycji "T"',
      description: 'Zrób zdjęcie w pozycji "T", przodem do kamery',
      group: MeasurementGroup.photos,
      uniqueKeyword: "t_pose_photo_front_1",
      cameraOrientation: CameraOrientation.vertical,
      isRequired: true),
  Measurement(
      type: MeasurementType.photo,
      title: '(1) Zdjęcie w pozycji "T"',
      description: 'Zrób zdjęcie w pozycji "T", przodem do kamery',
      group: MeasurementGroup.photos,
      uniqueKeyword: "t_pose_photo_front_1",
      cameraOrientation: CameraOrientation.vertical,
      isRequired: true),
  Measurement(
      type: MeasurementType.photo,
      title: '(1) Zdjęcie w pozycji stania na baczność',
      description: 'Zrób zdjęcie w pozycji "na baczność", przodem do kamery',
      group: MeasurementGroup.photos,
      uniqueKeyword: "attention_pose_photo_front_1",
      cameraOrientation: CameraOrientation.vertical,
      isRequired: true),
  Measurement(
      type: MeasurementType.photo,
      title: '(2) Zdjęcie w pozycji stania na baczność',
      description:
          'Zrób zdjęcie w pozycji "na baczność", lewym profilem do kamery',
      group: MeasurementGroup.photos,
      uniqueKeyword: "attention_pose_photo_left_2",
      cameraOrientation: CameraOrientation.vertical,
      isRequired: true),
  Measurement(
      type: MeasurementType.photo,
      title: '(3) Zdjęcie w pozycji stania na baczność',
      description:
          'Zrób zdjęcie w pozycji "na baczność", prawym profilem do kamery',
      group: MeasurementGroup.photos,
      uniqueKeyword: "attention_pose_photo_right_3",
      cameraOrientation: CameraOrientation.vertical,
      isRequired: true),
  
  Measurement(
      type: MeasurementType.save,
      title: "",
      description: '',
      group: MeasurementGroup.save,
      uniqueKeyword: "")
];
