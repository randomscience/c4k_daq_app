import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

const gatewayKeyValue = "dc48813b9f2371df0479fa27b112b64d";

const id = "id";
const height = "height";
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
      noseToFloor: "52",
      collarBoneToFloor: "98",
      pelvisToFloor: "133"
    });
  }
  return Map<String, String?>.from({
    id: null,
    height: null,
    noseToFloor: null,
    collarBoneToFloor: null,
    pelvisToFloor: null
  });
}

const String exercise1 = "(1) Przejście z punktu D do punktu B";
const String exercise2 = "(2) Przejście z punktu D do punktu B";
const String exercise3 = "(3) Przejście z punktu D do punktu B";

const String exercise4 = "(1) Skłon w punkcie S";
const String exercise5 = "(2) Skłon w punkcie S";
const String exercise6 = "(3) Skłon w punkcie S";

const String exercise7 = "(1) Przejście z punktu L do punktu P";
const String exercise8 = "(2) Przejście z punktu L do punktu P";
const String exercise9 = "(3) Przejście z punktu L do punktu P";

String exerciseNameConverter(String escorcieName) {
  if (escorcieName == exercise1) return "exercise_1";
  if (escorcieName == exercise2) return "exercise_2";
  if (escorcieName == exercise3) return "exercise_3";
  if (escorcieName == exercise4) return "exercise_4";
  if (escorcieName == exercise5) return "exercise_5";
  if (escorcieName == exercise6) return "exercise_6";

  if (escorcieName == exercise7) return "exercise_7";
  if (escorcieName == exercise8) return "exercise_8";
  if (escorcieName == exercise9) return "exercise_9";

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
};

Future<AndroidDeviceInfo> getAndroidDevice() async {
  var deviceInfo = DeviceInfoPlugin();
  return deviceInfo.androidInfo;
  // unique ID on Android
}

Future<String> getId() async {
  return (await getAndroidDevice()).fingerprint;
}
