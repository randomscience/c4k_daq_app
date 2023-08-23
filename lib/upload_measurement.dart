import 'dart:convert';
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
