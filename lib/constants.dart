import 'package:flutter/foundation.dart';

const gatewayKey = "dc48813b9f2371df0479fa27b112b64d";

const id = "id";
const height = "height";
const noseToFloor = "nose_to_floor";
const collarBoneToFloor = "collar_bone_to_floor";
const pelvisToFloor = "pelvis_to_floor";

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

const Map<String, String?> emptyExerciseVideoMapping = {
  "Ćwiczenie 1": null,
  "Ćwiczenie 2": null,
  "Ćwiczenie 3": null,
};
