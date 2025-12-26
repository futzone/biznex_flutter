class CloudResponse {
  bool unauthorized;
  bool success;
  bool sizeUnder;
  String? message;
  dynamic data;

  CloudResponse({
    this.unauthorized = false,
    this.success = true,
    this.data,
    this.sizeUnder = false,
    this.message,
  });
}
