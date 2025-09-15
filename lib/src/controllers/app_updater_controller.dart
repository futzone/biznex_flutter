import 'dart:developer';
import 'dart:io';

import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/config/router.dart';
import 'package:biznex/src/core/model/versioning_model/app_version.dart';
import 'package:biznex/src/core/release/app_updater.dart';
import 'package:biznex/src/ui/widgets/custom/app_toast.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:process_run/process_run.dart';

class AppUpdaterController {
  final BuildContext context;
  final AppVersion version;
  final AppUpdater updater = AppUpdater();
  final ValueNotifier<double> progressValue;

  AppUpdaterController({
    required this.progressValue,
    required this.context,
    required this.version,
  });

  void updateApp() async {
    showUpdateDialog(progressValue);
    final path = await updater.downloadUpdate(
      version: version,
      progress: progressValue,
    );

    log("dl path: $path");

    if (path == null || path.isEmpty) {
      AppRouter.close(context);
      return ShowToast.error(context, AppLocales.updateAppError.tr());
    }

    log("Path is done. Waiting for installation");
    await updater.saveAppVersion(version.version);
    await Future.delayed(Duration(seconds: 3));
    final shell = Shell();
    await shell.run('start "" "$path"').then((_) async {
      exit(0);
    });
  }

  void showUpdateDialog(progressValue) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return UpdaterDialogScreen(
          progressValue: progressValue,
        );
      },
    );
  }
}

class UpdaterDialogScreen extends StatelessWidget {
  final ValueNotifier<double> progressValue;

  const UpdaterDialogScreen({super.key, required this.progressValue});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ValueListenableBuilder(
          valueListenable: progressValue,
          builder: (context, value, child) {
            return Container(
              padding: 24.all,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
              ),
              // color: Colors.red,
              child: Column(
                spacing: 12,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 120,
                    width: 120,
                    child: Stack(
                      children: [
                        SizedBox(
                          height: 120,
                          width: 120,
                          child: CircularProgressIndicator(
                            value: value * 0.01,
                            backgroundColor:
                                AppColors(isDark: false).accentColor,
                            color: AppColors(isDark: false).mainColor,
                          ),
                        ),
                        Center(
                          child: Column(
                            spacing: 4,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Ionicons.download_outline),
                              Text(
                                "${(value).toStringAsFixed(2)} %",
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Text(AppLocales.downloadingUpdates.tr()),
                  ElevatedButton(
                    onPressed: () {
                      AppRouter.close(context);
                      progressValue.value = -10;
                    },
                    child: Text(AppLocales.cancel.tr()),
                  ),
                ],
              ),
            );
          }),
    );
  }
}
