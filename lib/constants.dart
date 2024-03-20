import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const measurementTime = "measurement_time";

enum MeasurementType { id, number, dropdown, photo, video, save }

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

  Measurement(
      {required this.type,
      required this.title,
      required this.description,
      required this.group,
      required this.uniqueKeyword,
      this.isRequired = false});
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
      title: 'Zdjęcie w pozycji "T"',
      description: 'Zrób zdjęcie w pozycji "T", przodem do kamery',
      group: MeasurementGroup.photos,
      uniqueKeyword: "t_pose_photo_front",
      isRequired: true),
  Measurement(
      type: MeasurementType.photo,
      title: '(1) Zdjęcie w pozycji stania na baczność',
      description: 'Zrób zdjęcie w pozycji "na baczność", przodem do kamery',
      group: MeasurementGroup.photos,
      uniqueKeyword: "attention_pose_photo_front",
      isRequired: true),
  Measurement(
      type: MeasurementType.photo,
      title: '(2) Zdjęcie w pozycji stania na baczność',
      description:
          'Zrób zdjęcie w pozycji "na baczność", lewym profilem do kamery',
      group: MeasurementGroup.photos,
      uniqueKeyword: "attention_pose_photo_left",
      isRequired: true),
  Measurement(
      type: MeasurementType.photo,
       title: '(3) Zdjęcie w pozycji stania na baczność',
      description:
          'Zrób zdjęcie w pozycji "na baczność", prawym profilem do kamery',
      group: MeasurementGroup.photos,
      uniqueKeyword: "attention_pose_photo_right",
      isRequired: true),
  Measurement(
      type: MeasurementType.video,
      title: "(1) Przejście z punktu D do punktu B",
      description:
          'Nagraj dziecko idące przodem do kamery, z punktu D do punktu B',
      group: MeasurementGroup.poseVideos,
      uniqueKeyword: "move_from_d_b_1"),
  Measurement(
      type: MeasurementType.video,
      title: "(2) Przejście z punktu D do punktu B",
      description:
          'Nagraj dziecko idące przodem do kamery, z punktu D do punktu B',
      group: MeasurementGroup.poseVideos,
      uniqueKeyword: "move_from_d_b_2"),
  Measurement(
      type: MeasurementType.video,
      title: "(3) Przejście z punktu D do punktu B",
      description:
          'Nagraj dziecko idące przodem do kamery, z punktu D do punktu B',
      group: MeasurementGroup.poseVideos,
      uniqueKeyword: "move_from_d_b_3"),
  Measurement(
      type: MeasurementType.video,
      title: "(1) Przejście z punktu L do punktu P",
      description:
          'Nagraj dziecko idące profilem do kamery, z punktu L do punktu P',
      group: MeasurementGroup.poseVideos,
      uniqueKeyword: "move_from_l_p_1"),
  Measurement(
      type: MeasurementType.video,
      title: "(2) Przejście z punktu L do punktu P",
      description:
          'Nagraj dziecko idące profilem do kamery, z punktu L do punktu P',
      group: MeasurementGroup.poseVideos,
      uniqueKeyword: "move_from_l_p_2"),
  Measurement(
      type: MeasurementType.video,
      title: "(3) Przejście z punktu L do punktu P",
      description:
          'Nagraj dziecko idące profilem do kamery, z punktu L do punktu P',
      group: MeasurementGroup.poseVideos,
      uniqueKeyword: "move_from_l_p_3"),
  Measurement(
      type: MeasurementType.video,
      title: "Skok",
      description: 'Nagraj dziecko skaczące 5 razy',
      group: MeasurementGroup.superPowersVideos,
      uniqueKeyword: "high_jump_5"),
  Measurement(
      type: MeasurementType.video,
      title: "Skip A",
      description: 'Nagraj dziecko wykonujące w miejscu skip A',
      group: MeasurementGroup.superPowersVideos,
      uniqueKeyword: "skip_a"),
  Measurement(
      type: MeasurementType.video,
      title: "Pajacyki",
      description: 'Nagraj dziecko wykonujące pajacyki',
      group: MeasurementGroup.superPowersVideos,
      uniqueKeyword: "rompers"),
  Measurement(
      type: MeasurementType.video,
      title: "Podpór przodem",
      description: 'Nagraj dziecko wykonujące podpór przodem',
      group: MeasurementGroup.superPowersVideos,
      uniqueKeyword: "plank"),
  Measurement(
      type: MeasurementType.video,
      title: "Pół przysiad",
      description:
          'Nagraj dziecko wykonujące pół przysiad z rękami wyprostowanymi w przód',
      group: MeasurementGroup.superPowersVideos,
      uniqueKeyword: "squat"),
  Measurement(
      type: MeasurementType.video,
      title: "Ciężarki",
      description: 'Nagraj dziecko trzymające ciężarki o wadze 1 kg, w pozycji "T"',
      group: MeasurementGroup.superPowersVideos,
      uniqueKeyword: "strength_doubles"),
    Measurement(
      type: MeasurementType.video,
      title: "Leżenie na brzuchu z kończynami uniesionymi",
      description: 'Nagraj dziecko leżące na brzuchu z kończynami uniesionymi',
      group: MeasurementGroup.superPowersVideos,
      uniqueKeyword: "laying_down_banana_style"),
      
  Measurement(
      type: MeasurementType.save,
      title: "",
      description: '',
      group: MeasurementGroup.save,
      uniqueKeyword: "")
];

Future<AndroidDeviceInfo> getAndroidDevice() async {
  var deviceInfo = DeviceInfoPlugin();
  return deviceInfo.androidInfo;
  // unique ID on Android
}

Future<String> getId() async {
  return (await getAndroidDevice()).fingerprint;
}
