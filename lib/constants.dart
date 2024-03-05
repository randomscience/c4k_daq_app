import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

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

emptyUserInformation() {
  if (kDebugMode) {
    return Map<String, String?>.from({
      id: "1331231",
      height: "96",
      age: "52",
      sex: "98",
    });
  }
  return Map<String, String?>.from({
    id: null,
    height: null,
    age: null,
    sex: null,
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
  "exercise_1": null,
  "exercise_2": null,
  "exercise_3": null,
  "exercise_4": null,
  "exercise_5": null,
  "exercise_6": null,
  "exercise_7": null,
  "exercise_8": null,
  "exercise_9": null,
  "exercise_10": null,
  "exercise_11": null,
  "exercise_12": null,
  "exercise_13": null,
  "exercise_14": null,
};

Future<AndroidDeviceInfo> getAndroidDevice() async {
  var deviceInfo = DeviceInfoPlugin();
  return deviceInfo.androidInfo;
  // unique ID on Android
}

Future<String> getId() async {
  return (await getAndroidDevice()).fingerprint;
}
