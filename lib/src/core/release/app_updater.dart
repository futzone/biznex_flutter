import 'dart:convert';
import 'dart:developer';
import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/database/app_database/app_database.dart';
import 'package:biznex/src/core/model/versioning_model/app_version.dart';
import 'package:http/http.dart' as http;
import 'package:process_run/process_run.dart';
import '../../../main.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class AppUpdater {
  Future<String> getAppVersion() async {
    final box = await Hive.openBox("app_version_box");
    final data = await box.get("app_version_key");
    return data ?? appVersion;
  }

  Future<void> saveAppVersion(String version) async {
    final box = await Hive.openBox("app_version_box");
    await box.put("app_version_key", version);
  }

  Future<AppVersion?> checkForUpdates() async {
    final String updateApiUrl =
        'https://noco.biznex.uz/api/collections/updates/records/?filter=fastfood=false&sort=-created&perPage=1';
    try {
      final response = await http.get(Uri.parse(updateApiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> updateInfo = json.decode(response.body);
        if (updateInfo['items'] == null || updateInfo['items'].length == 0) {
          return null;
        }

        final AppVersion appVersion =
            AppVersion.fromJson(updateInfo['items'][0]);

        final oldVersion = await getAppVersion();

        if (isNewerVersion(appVersion.version, oldVersion)) {
          return appVersion;
        }
      }
    } catch (e) {
      log('ERROR GET UPDATES: $e');
    }
    return null;
  }

  bool isNewerVersion(String latest, String current) {
    List<int> latestParts = latest.split('.').map(int.parse).toList();
    List<int> currentParts = current.split('.').map(int.parse).toList();

    for (int i = 0; i < latestParts.length; i++) {
      if (i >= currentParts.length || latestParts[i] > currentParts[i]) {
        return true;
      }
      if (latestParts[i] < currentParts[i]) {
        return false;
      }
    }
    return false;
  }

  Future<String?> downloadUpdate({
    required AppVersion version,
    required ValueNotifier<double> progress,
  }) async {
    try {
      final url = Uri.parse(
        "https://noco.biznex.uz/api/files/${version.collectionId}/${version.id}/${version.file}",
      );

      final client = http.Client();
      final request = http.Request('GET', url);
      final response = await client.send(request);

      final contentLength = response.contentLength ?? 0;
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/update_installer.exe';
      final file = File(filePath);
      final sink = file.openWrite();

      int received = 0;

      await for (var chunk in response.stream) {
        if (progress.value == -10) return null;
        received += chunk.length;
        sink.add(chunk);
        double progressV = (received / contentLength) * 100;
        progress.value = progressV;
        log(progress.value.toStringAsFixed(1));
      }

      await sink.flush();
      await sink.close();
      client.close();
      return filePath;
    } catch (e) {
      print("❌ Exception: $e");
    }
    return null;
  }

  Future<void> installNewVersion(String filePath) async {
    try {
      await Process.start(filePath, []);

      exit(0);
    } catch (e) {
      print("❌ O'rnatishda xato: $e");
    }
  }
}
