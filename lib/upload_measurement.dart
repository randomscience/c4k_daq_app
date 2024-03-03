import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:c4k_daq/constants.dart';
import 'package:c4k_daq/version.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'dart:io' as io;
import 'package:pocketbase/pocketbase.dart';
import 'package:http/http.dart' as http;

Future<(bool, String)> uploadMeasurementFromPath(String path) async {
  Map<String, dynamic> measurementInformation;
  String content = await io.File(path).readAsString();

  if (content.isNotEmpty) {
    measurementInformation = json.decode(content);
  } else {
    throw Exception("$path.json is empty");
  }

  final pb = PocketBase(pocketBaseUrl);
  await pb
      .collection('users')
      .authWithPassword(pocketBaseUserName, pocketBasePassword);

  final body = <String, dynamic>{
    "theKidlyId": measurementInformation[id],
    "appVersion": appVersion,
    "measurementTime": "test",
    "height": measurementInformation[height],
    "noseToFloor": measurementInformation[noseToFloor],
    "collarBoneToFloor": measurementInformation[collarBoneToFloor],
    "pelvisToFloor": measurementInformation[pelvisToFloor]
  };

  Map<String, String> exerciseVideoMapping = {};

  emptyExerciseVideoMapping.forEach((key, value) {
    exerciseVideoMapping[key] = measurementInformation[key];
  });

  Iterator videoIterator = exerciseVideoMapping.entries.iterator;

  List<MultipartFile> files = [];

  while (videoIterator.moveNext()) {
    MapEntry<String, String?> entry = videoIterator.current;
    files.add(http.MultipartFile.fromBytes(
      entry.key.replaceAll('_', ''),
      io.File(exerciseVideoMapping[entry.key]!).readAsBytesSync(),
      filename: entry.key,
    ));
  }

  try {
    await pb
        .collection('c4k_daq_app_dev')
        .create(body: body, files: files)
        .timeout(const Duration(minutes: 5));
  } on TimeoutException {
    return (
      false,
      "Wysyłanie pomiaru trwa za długo, połączenie internetowe jest za wolne"
    );
  } on SocketException {
    return (false, "Brak połączenia z serwerem, sprawdź ustawienia internetu");
  } catch (x) {
    return (false, "Napotkano nieznany błąd, szczegóły dla developerów: $x");
  }

  return (true, "");
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
