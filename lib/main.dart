import 'dart:io';
import 'package:biznex/src/core/database/isar_database/isar.dart';
import 'package:biznex/src/core/extensions/device_type.dart';
import 'package:biznex/src/core/utils/action_listener.dart';
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
const appVersion = '2.6.19';
const appPageSize = 30;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows) {
    final appDir = await getApplicationSupportDirectory();
    final dbPath = path.join(appDir.path, 'database');
    final dir = Directory(dbPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final isarDir = Directory(path.join(appDir.path));

    Hive.init(dir.path);
    await IsarDatabase.instance.init(isarDir.path);

    await ActionController.onSyncOwner(false);

    ActionController.stream.listen((_) async {
      await ActionController.onSyncOwner(false);
    });

    startServer();
  } else {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory(path.join(appDir.path));

    final hivePath = path.join(appDir.path, 'database');
    final hiveDir = Directory(hivePath);
    if (!await hiveDir.exists()) {
      await hiveDir.create(recursive: true);
    }

    Hive.init(hiveDir.path);
    await IsarDatabase.instance.init(dir.path);
  }

  // await AppBackupDatabase.instance.init();
  await EasyLocalization.ensureInitialized();
  // await onGenerateCyrillLocalization();
  // await DatabaseSchema().test();

  final container = ProviderContainer();
  try {
    await container.read(placesProvider.future);
    await container.read(employeeProvider.future);
    await container.read(productsProvider.future);
  } catch (_) {}

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

  // runZonedGuarded(() async {
  //   WidgetsFlutterBinding.ensureInitialized();
  //
  //   FlutterError.onError = (FlutterErrorDetails details) {
  //     FlutterError.presentError(details);
  //     runApp(ErrorApp(
  //         message: details.exception.toString(), stackTrace: details.stack));
  //   };
  //
  //   try {
  //     if (Platform.isWindows) {
  //       final appDir = await getApplicationSupportDirectory();
  //       final dbPath = path.join(appDir.path, 'database');
  //       final dir = Directory(dbPath);
  //       if (!await dir.exists()) {
  //         await dir.create(recursive: true);
  //       }
  //
  //       final isarDir = Directory(path.join(appDir.path));
  //
  //       Hive.init(dir.path);
  //       await IsarDatabase.instance.init(isarDir.path);
  //       await PrinterFonts.instance.init();
  //
  //       startServer();
  //     } else {
  //       final appDir = await getApplicationDocumentsDirectory();
  //       final dir = Directory(path.join(appDir.path));
  //
  //       final hivePath = path.join(appDir.path, 'database');
  //       final hiveDir = Directory(hivePath);
  //       if (!await hiveDir.exists()) {
  //         await hiveDir.create(recursive: true);
  //       }
  //
  //       Hive.init(hiveDir.path);
  //       await IsarDatabase.instance.init(dir.path);
  //     }
  //
  //     // await AppBackupDatabase.instance.init();
  //     await EasyLocalization.ensureInitialized();
  //     // await onGenerateCyrillLocalization();
  //     // await DatabaseSchema().test();
  //
  //     final container = ProviderContainer();
  //     try {
  //       await container.read(placesProvider.future);
  //       await container.read(employeeProvider.future);
  //       await container.read(productsProvider.future);
  //     } catch (_) {}
  //
  //     runApp(
  //       EasyLocalization(
  //         supportedLocales: const [
  //           Locale('ru', 'RU'),
  //           Locale('uz', 'UZ'),
  //           Locale('uz', 'Cyrl'),
  //           Locale('en', 'US'),
  //         ],
  //         fallbackLocale: const Locale('uz', 'UZ'),
  //         path: 'assets/localization',
  //         child: UncontrolledProviderScope(
  //           container: container,
  //           child: MyApp(),
  //         ),
  //       ),
  //     );
  //   } catch (error, stack) {
  //     runApp(ErrorApp(message: error.toString(), stackTrace: stack));
  //   }
  // }, (error, stack) {
  //   runApp(ErrorApp(message: error.toString(), stackTrace: stack));
  // });
}

class ErrorApp extends StatelessWidget {
  final String message;
  final StackTrace? stackTrace;

  const ErrorApp({super.key, required this.message, this.stackTrace});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: Colors.red, size: 48),
                    const SizedBox(width: 15),
                    const Expanded(
                      child: Text(
                        "Dasturni ishga tushirishda xatolik yuz berdi",
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  "Iltimos, pastdagi xatolik matnini nusxalab, dasturchiga yuboring:",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: SelectableText(
                        "ERROR:\n$message\n\nSTACKTRACE:\n$stackTrace",
                        style: const TextStyle(
                          fontFamily: 'Consolas', // Monospace shrift
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    onPressed: () => exit(0), // Dasturdan chiqish
                    child: const Text("Dasturni yopish",
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
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
                : app.alwaysWaiter
                    ? OnboardPage()
                    : ActivityWrapper(
                        ref: ref,
                        context: context,
                        child: LicenseStatusWrapper(),
                      ),
          ),
        );
      },
    );
  }
}
