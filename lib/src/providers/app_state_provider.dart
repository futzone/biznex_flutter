import 'package:biznex/src/core/database/app_database/app_state_database.dart';
import 'package:biznex/src/core/database/url_database/url_database.dart';
import 'package:biznex/src/core/model/app_model.dart';
import 'package:biznex/src/core/network/network_services.dart';
import 'package:biznex/src/core/release/app_updater.dart';
import 'package:biznex/src/core/services/license_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final StateProvider<BuildContext?> mainContextProvider =
    StateProvider<BuildContext?>((ref) => null);
final StateProvider<bool> serverAppProvider =
    StateProvider<bool>((ref) => false);

final appStateProvider = FutureProvider((ref) async {
  AppStateDatabase stateDatabase = AppStateDatabase();
  AppModel initialState = await stateDatabase.getApp();
  UrlDatabase urlDatabase = UrlDatabase();
  final baseUrl = await urlDatabase.get();
  initialState.baseUrl = "$baseUrl";
  // initialState.licenseKey = '';
  ref
      .read(serverAppProvider.notifier)
      .update((state) => initialState.isServerApp);
  await stateDatabase.updateApp(initialState);
  return initialState;
});

final clientStateProvider = FutureProvider((ref) async {
  final NetworkServices networkServices = NetworkServices();
  final LicenseServices licenseServices = LicenseServices();
  final deviceID = await licenseServices.getDeviceId();
  final client = await networkServices.getClient(deviceID ?? '');
  return client;
});

final appUpdaterProvider = FutureProvider((ref) async {
  final AppUpdater appUpdater = AppUpdater();
  final version = await appUpdater.checkForUpdates();
  final current = await appUpdater.getAppVersion();
  return {"version": version, "current": current};
});

final appExpireProvider = FutureProvider((ref) async {
  final LicenseServices licenseServices = LicenseServices();
  return await licenseServices.getJwtDaysLeft();
});
