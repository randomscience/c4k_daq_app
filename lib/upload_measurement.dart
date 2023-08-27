import 'dart:convert';
import 'package:c4k_daq/constants.dart';
import 'package:c4k_daq/version.dart';
import 'package:c4k_daq/upload_result.dart';
import 'package:http/http.dart' as http;
import 'dart:io' as io;

Future<UploadResult> uploadMeasurement(Map<String, String> measurement) async {
  final resp = await http.post(
    Uri.parse(
        "https://external.randomscience.org/c4k/api/v1/upload_measurement_info"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(measurement),
  );

  return UploadResult(statusCode: resp.statusCode, body: resp.body.toString());
}

uploadMeasurementVideo(
  String path,
  String fileName,
  String id,
  String gatewayKey,
) async {
  var request = http.MultipartRequest(
    'POST',
    Uri.parse(
        "https://external.randomscience.org/c4k/api/v1/upload_measurement_video/$gatewayKey/$id"),
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
  var file = io.File(pathToMeasurement);
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
