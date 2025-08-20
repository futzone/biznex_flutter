import 'dart:convert';
import 'package:biznex/src/core/model/app_model.dart';
import 'package:hive/hive.dart';

class AppStateDatabase {
  Future<AppModel> getApp() async {
    final box = await Hive.openBox("app");
    final app = await box.get("data");

    if (app == null) {
      return AppModel(
        isDark: false,
        role: "admin",
        token: "",
        data: "",
        locale: 'uz',
        notificationCount: 0,
        orderCount: 0,
        isMe: false,
        pincode: '',
      );
    }
    return AppModel.fromJson(jsonDecode(app));
  }

  Future<void> updateApp(AppModel app) async {
    final box = await Hive.openBox("app");
    await box.put("data", jsonEncode(app.toJson()));
  }

  Future<void> deleteApp() async {
    final box = await Hive.openBox("app");
    await box.clear();
    // await box.put("data", jsonEncode(app.toJson()));
  }
}
