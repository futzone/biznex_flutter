import 'package:dio/dio.dart';

extension ResponseStatus on Response? {
  bool get success {
    if (this != null && this!.statusCode != null && this!.statusCode! > 199 && this!.statusCode! < 300) {
      return true;
    }

    return false;
  }
}
