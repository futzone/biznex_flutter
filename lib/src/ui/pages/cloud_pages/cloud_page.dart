import 'dart:convert';
import 'dart:developer';
import 'package:biznex/biznex.dart';
import 'package:biznex/src/controllers/cloud_data_controller.dart';
import 'package:biznex/src/core/config/router.dart';
import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/core/extensions/for_dynamic.dart';
import 'package:biznex/src/core/model/cloud_models/client.dart';
import 'package:biznex/src/core/network/network_services.dart';
import 'package:biznex/src/providers/app_state_provider.dart';
import 'package:biznex/src/ui/widgets/custom/app_loading.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:biznex/src/ui/widgets/custom/app_toast.dart';
import 'package:biznex/src/ui/widgets/helpers/app_decorated_button.dart';
import 'package:biznex/src/ui/widgets/helpers/app_text_field.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CloudPage extends HookConsumerWidget {
  const CloudPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passwordController = useTextEditingController();
    final expireDateController = useTextEditingController();
    final channelAddressController = useTextEditingController();
    final tokenController = useTextEditingController();
    final countController = useTextEditingController();
    return AppStateWrapper(
      builder: (theme, state) {
        return Scaffold(
          body: state.whenProviderData(
            provider: clientStateProvider,
            builder: (client) {
              if (client == null) {
                return Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                    ),
                    constraints: BoxConstraints(maxWidth: 600),
                    padding: Dis.all(context.s(20)),
                    margin: Dis.all(context.s(24)),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        spacing: context.h(16),
                        children: [
                          Center(
                            child: Text(
                              "Biznex Owner",
                              style: TextStyle(
                                fontSize: context.s(24),
                                fontFamily: boldFamily,
                                color: theme.mainColor,
                              ),
                            ),
                          ),
                          AppTextField(
                            title: AppLocales.passwordHint.tr(),
                            controller: passwordController,
                            theme: theme,
                            prefixIcon: const Icon(Iconsax.lock_1_copy),
                          ),
                          AppTextField(
                            onlyRead: true,
                            title: AppLocales.expireDate.tr(),
                            controller: expireDateController,
                            theme: theme,
                            prefixIcon: const Icon(Iconsax.calendar_1_copy),
                            onTap: () {
                              showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                              ).then((date) {
                                if (date != null) {
                                  expireDateController.text = DateFormat('yyyy-MM-dd').format(date);
                                }
                              });
                            },
                          ),
                          AppPrimaryButton(
                            theme: theme,
                            title: AppLocales.login.tr(),
                            onPressed: () {
                              showAppLoadingDialog(context);
                              CloudDataController cloudDataController = CloudDataController();
                              cloudDataController
                                  .createCloudAccount(
                                passwordController.text,
                                expireDateController.text,
                              )
                                  .then((v) {
                                AppRouter.close(context);
                                if (v == true) {
                                  ref.invalidate(clientStateProvider);
                                } else {
                                  ShowToast.error(
                                    context,
                                    AppLocales.errorOnCreatingCloudAccount.tr(),
                                  );
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              client as Client;
              log(client.hiddenPassword);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: Dis.only(lr: context.w(24), top: context.h(24)),
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
                        Container(
                          padding: Dis.only(lr: context.w(16), tb: context.h(8)),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: theme.white,
                          ),
                          child: Text(
                            "${AppLocales.lastUpdatedTime.tr()}:  ${DateFormat(
                              'yyyy, dd-MMMM, HH:mm',
                              context.locale.languageCode,
                            ).format(
                              DateTime.parse(client.updatedAt).add(Duration(hours: 2)),
                            )}",
                            style: TextStyle(
                              fontSize: context.s(14),
                              color: Colors.black54,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: Dis.all(32),
                      child: Row(
                        spacing: 24,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.white,
                              ),
                              padding: Dis.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    AppLocales.cloudAddressForThisAccount.tr(),
                                    style: TextStyle(
                                      fontSize: context.s(18),
                                      color: Colors.black,
                                      fontFamily: boldFamily,
                                    ),
                                  ),
                                  16.h,
                                  QrImageView(
                                    data: "${client.id}#${client.hiddenPassword}",
                                    version: QrVersions.auto,
                                    // size: context.s(400.0),
                                  ),
                                  16.h,
                                  Text(
                                    AppLocales.cloudAddressQrCodeDescription.tr(),
                                    style: TextStyle(
                                      fontSize: context.s(14),
                                      fontFamily: regularFamily,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.white,
                              ),
                              padding: Dis.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      if (jsonDecode(client.name) is Map && jsonDecode(client.name)['token'].toString().isNotEmpty)
                                        Icon(
                                          Ionicons.checkmark_done_circle_outline,
                                          color: theme.mainColor,
                                        ),
                                      if (jsonDecode(client.name) is Map && jsonDecode(client.name)['token'].toString().isNotEmpty) 12.w,
                                      Text(
                                        AppLocales.telegramNotificationFields.tr(),
                                        style: TextStyle(
                                          fontSize: context.s(18),
                                          color: Colors.black,
                                          fontFamily: boldFamily,
                                        ),
                                      ),
                                    ],
                                  ),
                                  16.h,
                                  AppTextField(
                                    title: AppLocales.botToken.tr(),
                                    controller: tokenController,
                                    theme: theme,
                                    suffixIcon: IconButton(
                                      onPressed: () async {
                                        await Clipboard.getData('text/plain').then((data) {
                                          tokenController.text = data?.text ?? "";
                                        });
                                      },
                                      icon: Icon(
                                        Iconsax.clipboard_text_copy,
                                        color: theme.secondaryTextColor,
                                      ),
                                    ),
                                  ),
                                  16.h,
                                  AppTextField(
                                    title: AppLocales.channelAddress.tr(),
                                    controller: channelAddressController,
                                    theme: theme,
                                    suffixIcon: IconButton(
                                      onPressed: () async {
                                        await Clipboard.getData('text/plain').then((data) {
                                          channelAddressController.text = data?.text ?? "";
                                        });
                                      },
                                      icon: Icon(
                                        Iconsax.clipboard_text_copy,
                                        color: theme.secondaryTextColor,
                                      ),
                                    ),
                                  ),
                                  16.h,
                                  AppTextField(
                                    title: AppLocales.productLimitNotification.tr(),
                                    controller: countController,
                                    theme: theme,
                                    textInputType: TextInputType.number,
                                    maxLines: 1,
                                  ),
                                  16.h,
                                  AppPrimaryButton(
                                    theme: theme,
                                    title: AppLocales.save.tr(),
                                    onPressed: () async {
                                      showAppLoadingDialog(context);
                                      Client newClient = client;
                                      final oldMap = jsonDecode(client.name) is Map ? jsonDecode(client.name) : {};
                                      newClient.updatedAt = DateTime.now().toIso8601String();
                                      newClient.name = jsonEncode({
                                        "name": state.shopName.notNullOrEmpty("Biznex Client"),
                                        "channel": channelAddressController.text.trim().isEmpty
                                            ? (oldMap["channel"] ?? '')
                                            : channelAddressController.text.trim(),
                                        "token": tokenController.text.trim().isEmpty ? (oldMap["token"] ?? '') : tokenController.text.trim(),
                                        "count": int.tryParse(countController.text.trim()) ?? 10,
                                      });

                                      NetworkServices ns = NetworkServices();
                                      await ns.updateClient(newClient).then((_) {
                                        AppRouter.close(context);
                                        ref.invalidate(clientStateProvider);
                                        ShowToast.success(context, AppLocales.savedSuccessfully.tr());
                                        channelAddressController.clear();
                                        tokenController.clear();
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // AppPrimaryButton(
                          //   theme: theme,
                          //   onPressed: () async {
                          //     CloudReportsController reportsController = CloudReportsController(
                          //       ref: ref,
                          //       context: context,
                          //       progress: progressValue,
                          //     );
                          //
                          //     await reportsController.startSendReports();
                          //   },
                          //   title: AppLocales.updateCloudData.tr(),
                          // ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
