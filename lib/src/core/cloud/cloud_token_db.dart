import 'dart:developer';

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
    } catch (error) {
      log('error on get token: $error', error: error);
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
  String branchId;
  int expires;
  DateTime subscriptionExpiresAt;

  CloudToken({
    required this.refresh,
    required this.token,
    required this.expires,
    required this.branchId,
    required this.subscriptionExpiresAt,
  });

  factory CloudToken.fromJson(dynamic json) {
    return CloudToken(
      token: json['token'] as String,
      branchId: json['branchId'] as String,
      refresh: json['refresh'] as String,
      expires: json['expires'] as int,
      subscriptionExpiresAt:
          DateTime.tryParse(json['subscriptionExpiresAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'branchId': branchId,
      'refresh': refresh,
      'expires': expires,
      'subscriptionExpiresAt': subscriptionExpiresAt.toIso8601String(),
    };
  }
}
