import 'dart:async';
import 'dart:convert';
import 'package:c4k_daq/constants.dart';
import 'package:c4k_daq/gateway_url.dart';
import 'package:c4k_daq/version.dart';
import 'package:c4k_daq/upload_result.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io' as io;

import 'package:path_provider/path_provider.dart';

void logError(
  String message, {
  String errorType = "Unknown",
}) async {
  http
      .post(
        Uri.parse("${gatewayUrl}log_error"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          ...{"gateway_key": gatewayKeyValue},
          ...{"message": message},
          ...{"hardware_id": await getId()},
          ...{"timestamp": "${DateTime.now()}"},
          ...{"error_type": errorType},
          ...{"app_version": appVersion}
        }),
      )
      .timeout(const Duration(seconds: 5));
}

Future<List<UploadResult>> uploadMeasurementFromId(String uniqueId) async {
  String directory = (await getApplicationDocumentsDirectory()).path;
  io.File measurementInformationFile;
  Map<String, dynamic> measurementInformation;

  try {
    measurementInformationFile = io.File("$directory/c4k_daq/$uniqueId.json");
  } on io.PathNotFoundException {
    rethrow;
  } catch (x) {
    rethrow;
  }
  String content = await measurementInformationFile.readAsString();

  if (content.isNotEmpty) {
    measurementInformation = json.decode(content);
  } else {
    throw Exception("$id.json is empty");
  }

  List<UploadResult> overallResult = [];

  try {
    overallResult.add(await uploadInformation({
      ...{"gateway_key": gatewayKeyValue},
      ...{"unique_id": uniqueId},
      ...{"hardware_key": await getId()},
      ...{"app_version": appVersion},
      ...{
        id: measurementInformation[id],
        height: measurementInformation[height],
        noseToFloor: measurementInformation[noseToFloor],
        collarBoneToFloor: measurementInformation[collarBoneToFloor],
        pelvisToFloor: measurementInformation[pelvisToFloor],
      },
    }).timeout(const Duration(seconds: 10)));
  } on TimeoutException {
    throw TimeoutException("parsedUserInformation upload took to long.");
  } catch (x) {
    rethrow;
  }

  Map<String, String> exerciseVideoMapping = {};

  emptyExerciseVideoMapping.forEach((key, value) {
    exerciseVideoMapping[key] = measurementInformation[key];
  });

  Iterator videoIterator = exerciseVideoMapping.entries.iterator;

  while (videoIterator.moveNext()) {
    MapEntry<String, String?> entry = videoIterator.current;
    try {
      overallResult.add(await uploadMeasurementVideo(
              exerciseVideoMapping[entry.key]!, entry.key, uniqueId)
          .timeout(const Duration(seconds: 30)));
    } on TimeoutException {
      throw TimeoutException("${entry.key} upload took to long.");
    } catch (x) {
      rethrow;
    }
  }
  return overallResult;
}

Future<List<UploadResult>> uploadMeasurementFromPath(String path) async {
  io.File measurementInformationFile;
  Map<String, dynamic> measurementInformation;

  try {
    measurementInformationFile = io.File(path);
  } on io.PathNotFoundException {
    rethrow;
  } catch (x) {
    rethrow;
  }
  String content = await measurementInformationFile.readAsString();

  if (content.isNotEmpty) {
    measurementInformation = json.decode(content);
  } else {
    throw Exception("$id.json is empty");
  }

  List<UploadResult> overallResult = [];

  try {
    overallResult.add(await uploadInformation({
      ...{"gateway_key": gatewayKeyValue},
      ...{"unique_id": measurementInformation["unique_id"]},
      ...{"hardware_key": await getId()},
      ...{
        id: measurementInformation[id],
        height: measurementInformation[height],
        noseToFloor: measurementInformation[noseToFloor],
        collarBoneToFloor: measurementInformation[collarBoneToFloor],
        pelvisToFloor: measurementInformation[pelvisToFloor],
      },
      // ...{"app_version": appVersion}
    }).timeout(const Duration(minutes: 1)));
  } on TimeoutException {
    throw TimeoutException("parsedUserInformation upload took to long.");
  } catch (x) {
    rethrow;
  }

  Map<String, String> exerciseVideoMapping = {};

  emptyExerciseVideoMapping.forEach((key, value) {
    exerciseVideoMapping[key] = measurementInformation[key];
  });

  Iterator videoIterator = exerciseVideoMapping.entries.iterator;

  while (videoIterator.moveNext()) {
    MapEntry<String, String?> entry = videoIterator.current;
    try {
      overallResult.add(await uploadMeasurementVideo(
              exerciseVideoMapping[entry.key]!,
              entry.key,
              measurementInformation["unique_id"])
          .timeout(const Duration(minutes: 5)));
    } on TimeoutException {
      throw TimeoutException("${entry.key} upload took to long.");
    } catch (x) {
      rethrow;
    }
  }
  return overallResult;
}

Future<UploadResult> uploadInformation(Map<String, String> measurement) async {
  measurement['measurement_upload_time'] = DateTime.now().toString();

  final resp = await http.post(
    Uri.parse("${gatewayUrl}upload_measurement_info"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(measurement),
  );

  return UploadResult(statusCode: resp.statusCode, body: resp.body.toString());
}

Future<UploadResult> uploadMeasurementVideo(
  String path,
  String fileName,
  String id,
) async {
  var request = http.MultipartRequest(
    'POST',
    Uri.parse("${gatewayUrl}upload_measurement_video/$gatewayKeyValue/$id"),
  );

  request.files.add(
    http.MultipartFile.fromBytes(
      fileName,
      io.File(path).readAsBytesSync(),
      filename: fileName,
    ),
  );
  final resp = await request.send();

  return UploadResult(
      statusCode: resp.statusCode, body: await resp.stream.bytesToString());
}

deleteMeasurement(String pathToMeasurement) async {
  io.File file;
  try {
    file = io.File(pathToMeasurement);
  } on io.PathNotFoundException {
    debugPrint('file :$pathToMeasurement does not exist');
    return;
  }

  String content = await file.readAsString();

  if (content.isEmpty) {
    file.delete();
  }

  var localJsonData = json.decode(content);

  Map<String, String?> exerciseVideoMapping =
      Map<String, String?>.from(emptyExerciseVideoMapping);

  var keysList = List.from(exerciseVideoMapping.keys);
  for (var element in keysList) {
    io.File(localJsonData[element].toString()).delete();
  }
  file.delete();
}

Future<void> saveToFile(
    io.File localFile,
    String uuid,
    Map<String, String?> userInformation,
    Map<String, String?> exerciseVideoMapping) async {
  await localFile.writeAsString(
      json.encode({
        ...{"unique_id": uuid},
        ...userInformation,
        ...exerciseVideoMapping,
        ...{"measurement_time": "${DateTime.now()}"},
        ...{"app_version": appVersion}
      }),
      flush: true);
}
