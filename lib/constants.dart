import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const gatewayKeyValue = "dc48813b9f2371df0479fa27b112b64d";

const id = "id";
const height = "height";
const age = "age";
const sex = "sex";

const noseToFloor = "nose_to_floor";
const collarBoneToFloor = "collar_bone_to_floor";
const pelvisToFloor = "pelvis_to_floor";

const gatewayKey = "gateway_key";
const uniqueID = "unique_id";
const measurementTime = "measurement_time";
const version = "app_version";

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

List<Measurement> test = [
  Measurement(
      type: MeasurementType.id,
      title: 'Wpisz ID z ankiety',
      description: 'Unikatowe ID dziecka',
      group: MeasurementGroup.generalInfo,
      uniqueKeyword: "theKidlyId",
      isRequired: true),
  Measurement(
      type: MeasurementType.number,
      title: 'Wpisz wzrost dziecka',
      description: 'Wzrost [cm]',
      group: MeasurementGroup.generalInfo,
      uniqueKeyword: "height",
      isRequired: true),
  Measurement(
      type: MeasurementType.number,
      title: 'Wpisz wiek dziecka',
      description: 'Wiek [lata]',
      group: MeasurementGroup.generalInfo,
      uniqueKeyword: "age",
      isRequired: true),
  Measurement(
      type: MeasurementType.dropdown,
      title: 'Wybierz biologiczną płeć dziecka',
      description: 'Płeć',
      group: MeasurementGroup.generalInfo,
      uniqueKeyword: "sex",
      isRequired: true),
  Measurement(
      type: MeasurementType.photo,
      title: 'Zrób zdjęcie w pozycji "T"',
      description: 'Przodem do kamery',
      group: MeasurementGroup.photos,
      uniqueKeyword: "t_pose_photo_front",
      isRequired: true),
  Measurement(
      type: MeasurementType.photo,
      title: 'Zrób zdjęcie w pozycji stania na Baczność, przodem do kamery',
      description: 'Przodem do kamery',
      group: MeasurementGroup.photos,
      uniqueKeyword: "attention_pose_photo_front",
      isRequired: true),
  Measurement(
      type: MeasurementType.photo,
      title:
          'Zrób zdjęcie w pozycji stania na Baczność, lewym profilem do kamery',
      description: 'lewym profilem do kamery',
      group: MeasurementGroup.photos,
      uniqueKeyword: "attention_pose_photo_left",
      isRequired: true),
  Measurement(
      type: MeasurementType.photo,
      title:
          'Zrób zdjęcie w pozycji stania na Baczność, prawym profilem do kamery',
      description: 'prawym profilem do kamery',
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
      title: "Nagraj dziecko skaczące wzwyż 5 razy",
      description: 'Nagraj dziecko skaczące wzwyż 5 razy',
      group: MeasurementGroup.superPowersVideos,
      uniqueKeyword: "jump"),
  Measurement(
      type: MeasurementType.video,
      title: "Nagraj dziecko wykonujące w miejsu, skip A",
      description: 'Nagraj dziecko wykonujące w miejsu, skip A',
      group: MeasurementGroup.superPowersVideos,
      uniqueKeyword: "skip"),
  Measurement(
      type: MeasurementType.video,
      title: "Nagraj dziecko trzymające ciężarki",
      description: 'Nagraj dziecko trzymające ciężarki',
      group: MeasurementGroup.superPowersVideos,
      uniqueKeyword: "strength"),
  Measurement(
      type: MeasurementType.save,
      title: "",
      description: '',
      group: MeasurementGroup.save,
      uniqueKeyword: "")
];

emptyUserInformation() {
  // if (kDebugMode) {
  //   return Map<String, String?>.from({
  //     id: "1331231",
  //     height: "96",
  //     age: "52",
  //     sex: "Male",
  //   });
  // }
  return Map<String, String?>.from({
    // id: null,
    // height: null,
    // age: null,
    // sex: null,
  });
}

const String exercise1 = "Zdjęcie w pozycji 'T', przodem do kamery";
const String exercise2 =
    "Zdjęcie w pozycji stania na Baczność, przodem do kamery";
const String exercise3 =
    "Zdjęcie w pozycji stania na Baczność, lewym profilem do kamery";
const String exercise4 =
    "Zrób zdjęcie w pozycji stania na Baczność, prawym profilem do kamery";

const String exercise5 = "(1) Przejście z punktu D do punktu B";
const String exercise6 = "(2) Przejście z punktu D do punktu B";
const String exercise7 = "(3) Przejście z punktu D do punktu B";

const String exercise8 = "(1) Przejście z punktu L do punktu P";
const String exercise9 = "(2) Przejście z punktu L do punktu P";
const String exercise10 = "(3) Przejście z punktu L do punktu P";

const String exercise11 = "Nagraj dziecko skaczące wzwyż 5 razy";
const String exercise12 = "Nagraj dziecko wykonujące w miejsu, skip A";
const String exercise13 = "Nagraj dziecko trzymające ciężarki";
const String exercise14 = "Przekarz dziecku telefon, z grą zręcznościową";

String exerciseNameConverter(String exerciseName) {
  if (exerciseName == exercise1) return "exercise_1";
  if (exerciseName == exercise2) return "exercise_2";
  if (exerciseName == exercise3) return "exercise_3";
  if (exerciseName == exercise4) return "exercise_4";
  if (exerciseName == exercise5) return "exercise_5";
  if (exerciseName == exercise6) return "exercise_6";

  if (exerciseName == exercise7) return "exercise_7";
  if (exerciseName == exercise8) return "exercise_8";
  if (exerciseName == exercise9) return "exercise_9";

  if (exerciseName == exercise10) return "exercise_10";
  if (exerciseName == exercise11) return "exercise_11";
  if (exerciseName == exercise12) return "exercise_12";

  if (exerciseName == exercise13) return "exercise_13";
  if (exerciseName == exercise14) return "exercise_14";

  return "unknown_exercise";
}

const Map<String, String?> emptyExerciseVideoMapping = {
  // "exercise_1": null,
  // "exercise_2": null,
  // "exercise_3": null,
  // "exercise_4": null,
  // "exercise_5": null,
  // "exercise_6": null,
  // "exercise_7": null,
  // "exercise_8": null,
  // "exercise_9": null,
  // "exercise_10": null,
  // "exercise_11": null,
  // "exercise_12": null,
  // "exercise_13": null,
  // "exercise_14": null,
};

Future<AndroidDeviceInfo> getAndroidDevice() async {
  var deviceInfo = DeviceInfoPlugin();
  return deviceInfo.androidInfo;
  // unique ID on Android
}

Future<String> getId() async {
  return (await getAndroidDevice()).fingerprint;
}
