class CloudResponse {
  bool unauthorized;
  bool success;
  String? message;
  dynamic data;

  CloudResponse({
    this.unauthorized = false,
    this.success = true,
    this.data,
    this.message,
  });
}
