import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:shelf/src/request.dart';

class AuthorizationServices {
  static const _secret = 'JMDChqiOC4cwmpQ1zEjet5ChFeD8yfF9VYszEm27b24qB29iBatgt7HsvNt1hkrK';
  static const _tokenExpireTime = 10;

  bool verifyToken(String token) {
    try {
      JWT.verify(token, SecretKey(_secret));

      return true;
    } on JWTExpiredException {
      return false;
    } on JWTException catch (_) {
      return false;
    }
  }

  String generateToken() {
    final jwt = JWT({'exp': DateTime.now().add(Duration(minutes: _tokenExpireTime)).millisecondsSinceEpoch ~/ 1000});
    return jwt.sign(SecretKey(_secret));
  }

  bool requestAuthChecker(Request request) {
    return true;
    try {
      final headers = request.headers['token'];
      if (headers == null) return false;
      return verifyToken(headers);
    } catch (_) {
      return false;
    }
  }
}
