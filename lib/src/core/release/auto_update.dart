import 'dart:developer';

import 'package:biznex/biznex.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:process_run/shell.dart';
import 'package:pub_semver/pub_semver.dart';
import '../../../main.dart';

final String updateApiUrl =
    'https://noco.biznex.uz/api/collections/updates/records/?filter=fastfood=false&sort=-created&perPage=1';

class AppUpdate {
  String text;
  String step;
  bool haveUpdate;
  double progress;

  static const String checkingStep = "checkingStep";
  static const String updatingStep = "updatingStep";
  static const String installingStep = "installingStep";

  AppUpdate({
    required this.text,
    this.haveUpdate = false,
    this.step = AppUpdate.checkingStep,
    this.progress = 0.0,
  });
}

Future<void> checkAndUpdate(ValueNotifier<AppUpdate> appUpdate,
    ValueNotifier<String> lastVersion, WidgetRef ref) async {
  if (ref.watch(_checkerProvider)) return;
  if (!(await isConnected())) {
    appUpdate.value = AppUpdate(
      text: AppLocales.chekingForUpdates.tr(),
      haveUpdate: false,
      step: AppUpdate.checkingStep,
    );

    ref.read(_checkerProvider.notifier).state = true;
    return;
  }

  log("checking for updates");
  final response = await http.get(Uri.parse(updateApiUrl));

  if (response.statusCode == 200 || response.statusCode == 201) {
    final data = jsonDecode(response.body);

    if(data['items'].length == 0)return;
    final latestVersion = data['items'][0];

    final latest = Version.parse(latestVersion['version']);
    lastVersion.value = latestVersion['version'];
    final currentVersion = await _getVersion();
    final current = Version.parse(currentVersion);

    log("current: ${current.toString()}");
    log("latest: ${latest.toString()}");

    if (latest > current) {
      appUpdate.value = AppUpdate(
        text: AppLocales.downloadingUpdates.tr(),
        haveUpdate: true,
        step: AppUpdate.updatingStep,
      );
      final url = data['url'];
      final client = http.Client();
      final request = http.Request('GET', Uri.parse(url));
      final response = await client.send(request);

      final contentLength = response.contentLength ?? 0;
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/update_installer.exe';
      final file = File(filePath);
      final sink = file.openWrite();

      int received = 0;

      await for (var chunk in response.stream) {
        received += chunk.length;
        sink.add(chunk);
        double progress = (received / contentLength) * 100;
        AppUpdate updatedApp = appUpdate.value;
        updatedApp.progress = progress;
        appUpdate.value = updatedApp;
      }

      await sink.flush();
      await sink.close();
      client.close();

      log("downloaded. running...");
      appUpdate.value = AppUpdate(
        text: AppLocales.installingNewVersion.tr(),
        haveUpdate: true,
        step: AppUpdate.installingStep,
      );
      ref.read(_checkerProvider.notifier).state = true;
      await _updateVersion(data['version']);
      final shell = Shell();
      await shell.run('start "" "$filePath"');

      exit(0);
    } else {
      appUpdate.value = AppUpdate(
        text: AppLocales.downloadingUpdates.tr(),
        haveUpdate: false,
        step: AppUpdate.updatingStep,
      );
    }
  }
  ref.read(_checkerProvider.notifier).state = true;
}

const _releaseBox = "release_version";

Future<void> skipUpdates(ValueNotifier<String> latest) async {
  await _updateVersion(latest.value);
}

Future<void> _updateVersion(String newVersion) async {
  final box = await Hive.openBox(_releaseBox);
  await box.put(_releaseBox, newVersion);
  log("saved version: $newVersion");
}

Future<String> _getVersion() async {
  final box = await Hive.openBox(_releaseBox);
  final version = await box.get(_releaseBox);
  return version ?? appVersion;
}

Future<bool> isConnected() async {
  try {
    final result = await InternetAddress.lookup('google.com');
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } on SocketException catch (_) {
    return false;
  }
}

// final appVersionProvider = FutureProvider((ref) async => await _getVersion());
final _checkerProvider = StateProvider((ref) => false);
