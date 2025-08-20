import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:biznex/src/server/app_response.dart';
import 'package:biznex/src/server/constants/api_endpoints.dart';
import 'package:biznex/src/server/constants/response_messages.dart';
import 'package:biznex/src/server/docs.dart';
import 'package:shelf/src/request.dart';

class FileRouter {
  Future<AppResponse> getImage(Request request) async {
    final data = request.headers;

    final imagePath = data['path'];
    if (imagePath == null) {
      return AppResponse(statusCode: 400, error: ResponseMessages.imagePathRequired);
    }

    log("Path is: $imagePath");

    final file = File(imagePath);
    if (!await file.exists()) {
      log("File is not found");
      return AppResponse(statusCode: 404, error: ResponseMessages.imageNotFound);
    }

    final bytes = await file.readAsBytes();
    return AppResponse(
      statusCode: 200,
      data: bytes,
      message: file.uri.pathSegments.last,
    );
  }

  static ApiRequest docs() => ApiRequest(
        name: 'Get image',
        path: ApiEndpoints.getImage,
        method: 'GET',
        headers: {'Content-Type': 'application/json', 'pin': 'XXXX', 'path': '/image/path'},
        body: "{}",
        contentType: 'application/octet-stream',
        errorResponse: {'error': ResponseMessages.unauthorized},
        response: 'Image bytes',
      );
}
