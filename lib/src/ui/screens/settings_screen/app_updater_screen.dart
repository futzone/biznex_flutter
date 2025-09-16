import 'package:biznex/src/controllers/app_updater_controller.dart';
import 'package:biznex/src/core/config/router.dart';
import 'package:biznex/src/core/model/versioning_model/app_version.dart';
import 'package:biznex/src/ui/widgets/helpers/app_decorated_button.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../biznex.dart';

class AppUpdaterScreen extends HookWidget {
  final AppVersion? version;
  final AppColors theme;

  const AppUpdaterScreen({
    super.key,
    required this.version,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final progressValue = useState(0.0);
    if (version == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppLocales.alreadyLastVersion.tr(),
            style: TextStyle(
              fontSize: 16,
              fontFamily: boldFamily,
            ),
          ),
          8.h,
          ElevatedButton(
            onPressed: () {
              AppRouter.close(context);
            },
            child: Text(AppLocales.close.tr()),
          ),
        ],
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "v${version!.version}",
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: boldFamily,
                ),
              ),
              16.w,
              if (version!.demo)
                Container(
                  padding: Dis.only(lr: 12, tb: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber),
                  ),
                  child: Text(AppLocales.test.tr(),
                      style: TextStyle(color: Colors.amber)),
                )
              else
                Container(
                  padding: Dis.only(lr: 12, tb: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Row(
                    spacing: 8,
                    children: [
                      Icon(
                        Iconsax.verify_copy,
                        size: 18,
                        color: Colors.green,
                      ),
                      Text(AppLocales.stable.tr(),
                          style: TextStyle(color: Colors.green)),
                    ],
                  ),
                ),
            ],
          ),
          if (version!.text != null && version!.text!.isNotEmpty) 12.h,
          if (version!.text != null && version!.text!.isNotEmpty)
            Text(
              "${version!.text}",
              style: TextStyle(
                fontSize: 14,
                fontFamily: regularFamily,
              ),
            ),
          12.h,
          Text(
            "${AppLocales.createdDate.tr()}: ${DateFormat("yyyy.MM.dd").format(DateTime.parse(version!.created))}",
            style: TextStyle(
              fontSize: 14,
              fontFamily: regularFamily,
            ),
          ),
          12.h,
          AppPrimaryButton(
            theme: theme,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 12,
              children: [
                Icon(Ionicons.download_outline, color: Colors.white),
                Text(
                  "${AppLocales.update.tr()} (${version!.size.toStringAsFixed(2)} MB)",
                  style: TextStyle(
                    fontFamily: mediumFamily,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            onPressed: () {
              AppUpdaterController auc = AppUpdaterController(
                progressValue: progressValue,
                context: context,
                version: version!,
              );

              auc.updateApp();
            },
          ),
        ],
      ),
    );
  }
}
