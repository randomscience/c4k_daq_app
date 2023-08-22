class UploadResult {
  int statusCode;
  String body;

  UploadResult({required this.statusCode, required this.body});

  isSuccess() {
    return statusCode == 200;
  }
}
