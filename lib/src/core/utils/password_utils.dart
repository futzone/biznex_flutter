import 'dart:convert';
import 'package:encrypt/encrypt.dart';

class PasswordEncryptor {
  static final _key = Key.fromUtf8('H7n39xKDlpVyWqL0BgUtEcRfAvmZTsQy');
  static final _iv = IV.fromUtf8('9xLqR4vWz2TkM1eB');

  String encryptPassword(String plainPassword) {
    final encrypter = Encrypter(AES(_key, mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(plainPassword, iv: _iv);
    return safeBase64Encode(encrypted.base64);
  }

  String decryptPassword(String encryptedPassword) {
    final encrypter = Encrypter(AES(_key, mode: AESMode.cbc));
    final decoded = safeBase64Decode(encryptedPassword);
    final decrypted = encrypter.decrypt(Encrypted.fromBase64(decoded), iv: _iv);
    return decrypted;
  }

  String safeBase64Encode(String input) {
    return base64.encode(utf8.encode(input)).replaceAll('+', 'A').replaceAll('/', 'B').replaceAll('=', 'C');
  }

  String safeBase64Decode(String input) {
    String normalized = input.replaceAll('A', '+').replaceAll('B', '/').replaceAll('C', '=');
    return utf8.decode(base64.decode(normalized));
  }
}
