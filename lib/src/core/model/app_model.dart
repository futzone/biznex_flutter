import 'dart:developer';
import 'package:biznex/src/core/model/app_screen_model.dart';
import 'package:biznex/src/core/model/employee_models/employee_model.dart';
import 'package:biznex/src/ui/widgets/helpers/app_loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const boldFamily = "Extra-Bold";
const regularFamily = "Regular";
const mediumFamily = "Medium";
const bool appRoleState = false;

class AppModel {
  bool after;
  bool isServerApp;
  String baseUrl;
  String? apiUrl;
  Employee? currentEmployee;
  String? shopName;
  String? orderHeight;
  String? orderWidth;
  String? checkWidth;
  String? checkHeight;
  int? currentWarehouse;
  bool isDark;
  int notificationCount;
  int orderCount;
  String role;
  String token;
  String refresh;
  String data;
  WidgetRef? ref;
  String locale;
  String boldFamily = "Extra-Bold";
  String regularFamily = "Regular";
  String mediumFamily = "Medium";
  String pincode;
  String licenseKey;

  String? imagePath;
  String? shopAddress;
  String? byeText;
  String? printPhone;

  bool get isAdmin => role == "admin";

  bool isMe = appRoleState;

  bool get isSeller => role == "seller";

  final bool isMobile = false;
  final bool isDesktop = true;
  AppScreen screen;
  final bool isTablet = false;

  bool offline;
  bool allowCancelOrder;

  void console(dynamic data, {Object? error, StackTrace? stackTrace}) {
    log("$data", error: error, stackTrace: stackTrace);
  }

  bool get alwaysWaiter {
    return apiUrl != null && apiUrl!.length > 6;
  }

  AppModel({
    this.offline = true,
    this.allowCancelOrder = false,
    this.after = true,
    this.baseUrl = '',
    this.currentEmployee,
    this.isServerApp = false,
    this.currentWarehouse,
    required this.isDark,
    required this.role,
    required this.token,
    required this.data,
    required this.notificationCount,
    required this.orderCount,
    required this.pincode,
    this.screen = AppScreen.appScreen,
    this.ref,
    this.refresh = '',
    this.locale = '',
    this.licenseKey = '',
    required this.isMe,
    this.checkHeight,
    this.checkWidth,
    this.shopName,
    this.orderWidth,
    this.printPhone,
    this.orderHeight,
    this.imagePath,
    this.shopAddress,
    this.byeText,
    this.apiUrl,
  });

  factory AppModel.fromJson(dynamic json) {
    return AppModel(
      isDark: json['isDark'] ?? false,
      locale: json['locale'] ?? 'uz',
      role: json['role'],
      isServerApp: json['apiUrl'] != null,
      token: json['token'],
      refresh: json['refresh'],
      data: json['data'],
      notificationCount: json['notificationCount'],
      orderCount: json['orderCount'],
      isMe: json['isMe'] ?? false,
      currentWarehouse: json['currentWarehouse'],
      checkHeight: json['checkHeight'],
      checkWidth: json['checkWidth'],
      orderHeight: json['orderHeight'],
      orderWidth: json['orderWidth'],
      shopName: json['shopName'],
      pincode: json['pincode'] ?? '',
      byeText: json['byeText'] ?? "",
      imagePath: json['imagePath'] ?? '',
      shopAddress: json['shopAddress'] ?? '',
      printPhone: json['printPhone'] ?? '',
      licenseKey: json['licenseKey'] ?? '',
      baseUrl: json['baseUrl'] ?? '',
      apiUrl: json['apiUrl'],
      after: json['after'] ?? true,
      offline: json['offline'] ?? true,
      allowCancelOrder: json['allowCancelOrder'] ?? false,
    );
  }

  int get animationDuration => 300;

  double get getSpacing {
    if (isDesktop) return 24;
    if (isTablet) return 20;
    return 16;
  }

  double get padding {
    if (isDesktop) return 24;
    if (isTablet) return 20;
    return 16;
  }

  Widget whenProviderData(
      {required dynamic provider,
      required Widget Function(dynamic data) builder}) {
    if (ref == null) return const SizedBox();

    return ref!.watch(provider as FutureProvider).when(
          loading: () => const AppLoadingScreen(),
          error: (error, stackTrace) {
            log("$provider error: ", error: error, stackTrace: stackTrace);
            return const Center(child: Text("An Unknown Error: "));
          },
          data: (data) => builder(data),
        );
  }

  Widget whenProviderDataSliver(
      {required dynamic provider,
      required Widget Function(dynamic data) builder}) {
    if (ref == null) return const SliverToBoxAdapter();

    return ref!.watch(provider as FutureProvider).when(
          loading: () => const SliverToBoxAdapter(child: AppLoadingScreen()),
          error: (error, stackTrace) {
            log("$provider error: ", error: error, stackTrace: stackTrace);
            return const SliverToBoxAdapter(
                child: Center(child: Text("An Unknown Error")));
          },
          data: (data) => builder(data),
        );
  }

  Map<String, dynamic> toJson() {
    return {
      "after": after,
      "isDark": isDark,
      "token": token,
      "role": role,
      "data": data,
      "refresh": refresh,
      "orderCount": orderCount,
      "locale": locale,
      "isMe": isMe,
      "notificationCount": notificationCount,
      "currentWarehouse": currentWarehouse,
      "shopName": shopName,
      "checkHeight": checkHeight,
      "checkWidth": checkWidth,
      "orderWidth": orderWidth,
      "orderHeight": orderHeight,
      "pincode": pincode,
      "shopAddress": shopAddress,
      "imagePath": imagePath,
      "byeText": byeText,
      "printPhone": printPhone,
      "licenseKey": licenseKey,
      "isServerApp": isServerApp,
      "baseUrl": baseUrl,
      "apiUrl": apiUrl,
      "offline": offline,
      "allowCancelOrder": allowCancelOrder,
    };
  }
}
