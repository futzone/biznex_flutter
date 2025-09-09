import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/providers/network_interface_provider.dart';
import 'package:biznex/src/ui/widgets/custom/app_toast.dart';
import 'package:biznex/src/ui/widgets/dialogs/app_custom_dialog.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../biznex.dart';
import '../../widgets/custom/app_state_wrapper.dart';

class NetworkInterfaceScreen extends StatefulWidget {
  const NetworkInterfaceScreen({super.key});

  @override
  State<NetworkInterfaceScreen> createState() => _AppLanguageBarState();
}

class _AppLanguageBarState extends State<NetworkInterfaceScreen> {
  @override
  Widget build(BuildContext context) {
    return AppStateWrapper(builder: (theme, state) {
      return Container(
        // margin: Dis.only(),
        padding: context.s(20).all,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          spacing: 24,
          children: [
            Text(
              AppLocales.addresses.tr(),
              style: TextStyle(
                fontSize: context.s(24),
                fontFamily: mediumFamily,
                color: Colors.black,
              ),
            ),
            state.whenProviderData(
              provider: networkInterfaceProvider,
              builder: (data) {
                return Column(
                  spacing: 8,
                  children: [
                    for (final item in data)
                      Row(
                        spacing: 8,
                        children: [
                          Text(
                            item.toString(),
                            style: TextStyle(
                                fontFamily: mediumFamily, fontSize: 16),
                          ),
                          IconButton(
                            onPressed: () async {
                              await Clipboard.setData(ClipboardData(
                                text: item
                                    .toString()
                                    .split(":")
                                    .lastOrNull
                                    .toString(),
                              )).then((_) {
                                ShowToast.success(
                                    context, AppLocales.copied.tr());
                              });
                            },
                            icon: Icon(
                              Iconsax.copy_copy,
                              color: theme.mainColor,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              showDesktopModal(
                                context: context,
                                body: Center(
                                  child: QrImageView(
                                    size: 400,
                                    data: item
                                        .toString()
                                        .split(":")
                                        .lastOrNull
                                        .toString(),
                                  ),
                                ),
                              );
                            },
                            icon: Icon(
                              Ionicons.qr_code_outline,
                              color: theme.mainColor,
                            ),
                          )
                        ],
                      )
                  ],
                );
              },
            ),
          ],
        ),
      );
    });
  }
}
