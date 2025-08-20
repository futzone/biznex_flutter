import 'dart:convert';
import 'dart:io';

import 'package:shelf/src/response.dart';

class AppResponse {
  String? error;
  String? message;
  int statusCode;
  dynamic data;

  AppResponse({
    required this.statusCode,
    this.data,
    this.error,
    this.message,
  });

  Response toResponse() {
    if (statusCode >= 200 && statusCode <= 299) {
      if (message != null && data == null) {
        return Response(statusCode, body: jsonEncode({"message": message}));
      }
      return Response.ok(jsonEncode(data));
    }

    return Response(statusCode, body: jsonEncode({'error': error}));
  }

  Response toImageResponse() {
    if (statusCode >= 200 && statusCode <= 299) {
      return Response.ok(
        data,
        headers: {'Content-Type': 'application/octet-stream', 'Content-Disposition': 'attachment; filename="$message"'},
      );
    }

    return Response(statusCode, body: jsonEncode({'error': error}));
  }

  bool get isSuccess {
    return (statusCode > 199 && statusCode < 300);
  }
}
