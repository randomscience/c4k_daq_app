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

Future<String?> uploadMeasurementFromPath(String path) async {
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
    "appVersion": appVersion,
    "measurementTime": measurementInformation[measurementTime],
  };

  for (final measurement in measurementList) {
    if (measurement.group == MeasurementGroup.generalInfo &&
        measurementInformation.containsKey(measurement.uniqueKeyword)) {
      body[measurement.uniqueKeyword] =
          measurementInformation[measurement.uniqueKeyword];
    }
  }
  var result;
  try {
    result = await pb
        .collection('c4k_daq_app_dev')
        .create(body: body)
        .timeout(const Duration(minutes: 5));

  } on TimeoutException {
    return "Wysyłanie pomiaru trwa za długo, połączenie internetowe jest za wolne";
  } on SocketException {
    return "Brak połączenia z serwerem, sprawdź ustawienia internetu";
  } catch (x) {
    return "Napotkano nieznany błąd, szczegóły dla developerów: $x";
  }

  // List<MultipartFile> files = [];
  for (final measurement in measurementList) {
    if ((measurement.group == MeasurementGroup.photos ||
            measurement.group == MeasurementGroup.poseVideos ||
            measurement.group == MeasurementGroup.superPowersVideos) &&
        measurementInformation.containsKey(measurement.uniqueKeyword)) {
      print("uploading${measurementInformation[measurement.uniqueKeyword]}");

      try {
        List<MultipartFile> file = [
          http.MultipartFile.fromBytes(
              measurement.group.toString().split('.')[1],
              io.File(measurementInformation[measurement.uniqueKeyword]!)
                  .readAsBytesSync(),
              filename: measurement.uniqueKeyword)
        ];

        await pb
            .collection('c4k_daq_app_dev')
            .update(result.id, files: file)
            .timeout(const Duration(minutes: 5));
      } on TimeoutException {
        return "Wysyłanie pomiaru trwa za długo, połączenie internetowe jest za wolne";
      } on SocketException {
        return "Brak połączenia z serwerem, sprawdź ustawienia internetu";
      } catch (x) {
        return "Napotkano nieznany błąd, szczegóły dla developerów: $x";
      }
    }
  }

  return null;
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

  if (content.isNotEmpty) {
    Map<String, dynamic> localJsonData = json.decode(content);

    for (Measurement measurement in measurementList) {
      if ((measurement.group == MeasurementGroup.photos ||
              measurement.group == MeasurementGroup.poseVideos ||
              measurement.group == MeasurementGroup.superPowersVideos) &&
          localJsonData.containsKey(measurement.uniqueKeyword)) {
        io.File(localJsonData[measurement.uniqueKeyword]!).delete();
      }
    }
  }
  file.delete();
}

Future<void> saveToFile(io.File localFile, String uuid,
    Map<String, String?> userInformation) async {
  await localFile.writeAsString(
      json.encode({
        ...{"unique_id": uuid},
        ...userInformation,
        ...{"measurement_time": "${DateTime.now()}"},
        ...{"app_version": appVersion}
      }),
      flush: true);
}
