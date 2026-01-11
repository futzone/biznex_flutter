import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/ui/pages/cloud_pages/cloud_config.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:biznex/src/ui/widgets/custom/app_toast.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';

final GlobalKey qrKey = GlobalKey();

class CloudPage extends HookConsumerWidget {
  const CloudPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppStateWrapper(
      builder: (theme, state) {
        final branchId = state.cloudToken?.branchId;
        return Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: Dis.only(
                  lr: context.w(24),
                  top: context.h(24),
                  bottom: context.h(24),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: context.w(16),
                  children: [
                    Expanded(
                      child: Text(
                        AppLocales.cloudData.tr(),
                        style: TextStyle(
                          fontSize: context.s(24),
                          fontFamily: mediumFamily,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    0.w,
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    24.w,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        spacing: 16,
                        children: [
                          Text(
                            AppLocales.qrMenuAbout.tr(),
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: mediumFamily,
                            ),
                          ),
                          RepaintBoundary(
                            key: qrKey,
                            child: QrImageView(
                              data: "https://menu.biznex.uz/$branchId",
                              version: QrVersions.auto,
                              size: 400,
                              backgroundColor: theme.white,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await saveQrAsPng().then((_) {
                                ShowToast.success(context,
                                    "${AppLocales.savedSuccessfully.tr()}: \nUser/Documents/qr_code.png");
                              });
                            },
                            icon: Icon(Iconsax.document_download_copy),
                            label: Text(
                              AppLocales.save.tr(),
                            ),
                          )
                        ],
                      ),
                    ),
                    24.w,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        spacing: 16,
                        children: [
                          Text(
                            AppLocales.dashboardAbout.tr(),
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: mediumFamily,
                            ),
                          ),
                          QrImageView(
                            data: "https://client.biznex.uz/",
                            version: QrVersions.auto,
                            size: 400,
                            backgroundColor: theme.white,
                          ),
                        ],
                      ),
                    ),
                    24.w,
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
