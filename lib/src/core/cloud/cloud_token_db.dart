import 'package:hive/hive.dart';

class CloudTokenDB {
  final _boxName = "cloud_token_data";
  final _key = "token_data";

  Future<CloudToken?> getToken() async {
    final box = await Hive.openBox(_boxName);
    final cloudData = await box.get(_key);

    if (cloudData == null) return null;

    try {
      return CloudToken.fromJson(cloudData);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveToken(CloudToken model) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_key, model.toJson());
  }

  Future<void> clear(CloudToken model) async {
    final box = await Hive.openBox(_boxName);
    await box.clear();
  }
}

class CloudToken {
  String token;
  String refresh;
  int expires;

  CloudToken({
    required this.refresh,
    required this.token,
    required this.expires,
  });

  factory CloudToken.fromJson(Map<String, dynamic> json) {
    return CloudToken(
      token: json['token'] as String,
      refresh: json['refresh'] as String,
      expires: json['expires'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'refresh': refresh,
      'expires': expires,
    };
  }
}
