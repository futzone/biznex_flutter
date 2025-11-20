import 'dart:io';
import 'package:biznex/src/core/config/locale.dart';
import 'package:biznex/src/core/database/database_schema/schema.dart';
import 'package:biznex/src/core/database/isar_database/isar.dart';
import 'package:biznex/src/core/extensions/device_type.dart';
import 'package:biznex/src/core/utils/printer_fonts.dart';
import 'package:biznex/src/providers/employee_provider.dart';
import 'package:biznex/src/providers/license_status_provider.dart';
import 'package:biznex/src/providers/places_provider.dart';
import 'package:biznex/src/providers/products_provider.dart';
import 'package:biznex/src/server/start.dart';
import 'package:biznex/src/ui/pages/login_pages/onboard_page.dart';
import 'package:biznex/src/ui/screens/sleep_screen/activity_wrapper.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:toastification/toastification.dart';
import 'package:path/path.dart' as path;

bool debugMode = true;
const appVersion = '2.5.3';
const appPageSize = 30;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows) {
    final appDir = await getApplicationSupportDirectory();
    final dir = Directory(path.join(appDir.path, 'database'));
    final isarDir = Directory(path.join(appDir.path));
    Hive.init(dir.path);
    await IsarDatabase.instance.init(isarDir.path);
    await PrinterFonts.instance.init();

    startServer();
  } else {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory(path.join(appDir.path));
    final hiveDir = Directory(path.join(appDir.path, 'database'));
    Hive.init(hiveDir.path);
    await IsarDatabase.instance.init(dir.path);
  }

  // await AppBackupDatabase.instance.init();
  await EasyLocalization.ensureInitialized();
  await onGenerateCyrillLocalization();

  // await DatabaseSchema().test();

  final container = ProviderContainer();
  await container.read(placesProvider.future);
  await container.read(employeeProvider.future);
  await container.read(productsProvider.future);

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('ru', 'RU'),
        Locale('uz', 'UZ'),
        Locale('uz', 'Cyrl'),
        Locale('en', 'US'),
      ],
      fallbackLocale: const Locale('uz', 'UZ'),
      path: 'assets/localization',
      child: UncontrolledProviderScope(
        container: container,
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return AppStateWrapper(
      mainContext: context,
      builder: (theme, app) {
        return ToastificationWrapper(
          child: MaterialApp(
            locale: context.locale,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            title: 'Biznex',
            debugShowCheckedModeBanner: false,
            theme: theme.themeData,
            home: getDeviceType(context) == DeviceType.mobile
                ? OnboardPage()
                : ActivityWrapper(ref: ref, child: LicenseStatusWrapper()),
          ),
        );
      },
    );
  }
}
