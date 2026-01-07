import 'dart:io';
import 'package:biznex/src/controllers/orcer_percent_controller.dart';
import 'package:biznex/src/core/database/app_database/app_state_database.dart';
import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/core/model/order_models/percent_model.dart';
import 'package:biznex/src/providers/app_state_provider.dart';
import 'package:biznex/src/providers/price_percent_provider.dart';
import 'package:biznex/src/providers/printer_devices_provider.dart';
import 'package:biznex/src/ui/screens/settings_screen/app_updater_screen.dart';
import 'package:biznex/src/ui/screens/settings_screen/network_interface_screen.dart';
import 'package:biznex/src/ui/widgets/custom/app_custom_popup_menu.dart';
import 'package:biznex/src/ui/widgets/custom/app_error_screen.dart';
import 'package:biznex/src/ui/widgets/custom/app_list_tile.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:biznex/src/ui/widgets/custom/app_toast.dart';
import 'package:biznex/src/core/database/audit_log_database/logger_service.dart';
import 'package:biznex/src/ui/widgets/helpers/app_decorated_button.dart';
import 'package:biznex/src/ui/widgets/helpers/app_loading_screen.dart';
import 'package:biznex/src/ui/widgets/helpers/app_text_field.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:printing/printing.dart';
import '../../../../biznex.dart';
import '../../../core/network/endpoints.dart';
import '../../../providers/network_interface_provider.dart';
import '../../widgets/dialogs/app_custom_dialog.dart';
import 'cache_settings_screen.dart';
import 'language_settings_screen.dart';

class SettingsPageScreen extends HookConsumerWidget {
  const SettingsPageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider).value!;
    final nameController = useTextEditingController(text: appState.shopName);
    final printerController = useTextEditingController(text: appState.refresh);
    final phoneController = useTextEditingController(text: appState.printPhone);
    final addressController =
        useTextEditingController(text: appState.shopAddress);
    final byeTextController = useTextEditingController(text: appState.byeText);
    final printer =
        useState(Printer(url: appState.token, name: appState.refresh));

    final managerPrinter = useState(
      Printer(
        url: appState.generalPrintUrl ?? '',
        name: appState.generalPrintName ?? '',
      ),
    );

    final oldPincodeController = useTextEditingController();
    final newPincodeController = useTextEditingController();
    final percentController = useTextEditingController();
    final percentNameController = useTextEditingController();

    return AppStateWrapper(
      builder: (theme, state) {
        String? expireText;

        if (state.cloudToken != null) {
          expireText = DateFormat("yyyy, dd-MMMM, HH:mm").format(
            state.cloudToken!.subscriptionExpiresAt.toLocal(),
          );
        }

        return Scaffold(
          body: SingleChildScrollView(
            padding: context.w(24).lr,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: Dis.only(tb: context.h(24)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: context.w(16),
                    children: [
                      Expanded(
                        child: Text(
                          AppLocales.settings.tr(),
                          style: TextStyle(
                            fontSize: context.s(24),
                            fontFamily: mediumFamily,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      if (expireText != null)
                        Container(
                          padding: Dis.only(lr: 12, tb: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Text(
                                "${AppLocales.expireDate.tr()}:",
                                style: TextStyle(
                                  fontSize: context.s(14),
                                  fontFamily: mediumFamily,
                                  color: Colors.black,
                                ),
                              ),
                              2.w,
                              Text(
                                expireText,
                                style: TextStyle(
                                  fontSize: context.s(14),
                                  fontFamily: boldFamily,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      state.whenProviderData(
                        provider: appUpdaterProvider,
                        builder: (data) {
                          final current = data['current'];
                          final version = data['version'];
                          return SimpleButton(
                            onLongPress: () {
                              showDesktopModal(
                                body: NetworkConnection(),
                                context: context,
                              );
                            },
                            onPressed: () {
                              showDesktopModal(
                                context: context,
                                body: AppUpdaterScreen(
                                  version: version,
                                  theme: theme,
                                ),
                              );
                            },
                            child: Container(
                              padding: Dis.only(lr: 12, tb: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "${AppLocales.appVersions.tr()}: v$current",
                                style: TextStyle(
                                  fontSize: context.s(14),
                                  fontFamily: mediumFamily,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: context.s(20).all,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                    color: Colors.white,
                  ),
                  child: Column(
                    spacing: 24,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        AppLocales.settings.tr(),
                        style: TextStyle(
                          fontSize: context.s(24),
                          fontFamily: mediumFamily,
                          color: Colors.black,
                        ),
                      ),
                      Row(
                        spacing: 24,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              spacing: 12,
                              children: [
                                Text(
                                  AppLocales.shopName.tr(),
                                  style: TextStyle(
                                      fontSize: 16, fontFamily: mediumFamily),
                                ),
                                AppTextField(
                                    title: AppLocales.shopNameHint.tr(),
                                    controller: nameController,
                                    theme: theme),
                                0.h,
                                Text(
                                  AppLocales.shopAddressLabel.tr(),
                                  style: TextStyle(
                                      fontSize: 16, fontFamily: mediumFamily),
                                ),
                                AppTextField(
                                    title: AppLocales.shopAddressHint.tr(),
                                    controller: addressController,
                                    theme: theme),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              spacing: 12,
                              children: [
                                Text(
                                  AppLocales.phoneForPrintLabel.tr(),
                                  style: TextStyle(
                                      fontSize: 16, fontFamily: mediumFamily),
                                ),
                                AppTextField(
                                    title: AppLocales.enterPhoneNumber.tr(),
                                    controller: phoneController,
                                    theme: theme),
                                0.h,
                                Text(
                                  AppLocales.orderCheckByeText.tr(),
                                  style: TextStyle(
                                      fontSize: 16, fontFamily: mediumFamily),
                                ),
                                AppTextField(
                                  title: AppLocales.orderCheckByeTextHint.tr(),
                                  controller: byeTextController,
                                  theme: theme,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // 8.h,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        spacing: 24,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              spacing: 12,
                              children: [
                                Text(
                                  AppLocales.shopLogoLabel.tr(),
                                  style: TextStyle(
                                      fontSize: 16, fontFamily: mediumFamily),
                                ),
                                SimpleButton(
                                  onPressed: () {
                                    FilePicker.platform
                                        .pickFiles()
                                        .then((file) {
                                      if (file != null &&
                                          file.files.firstOrNull?.path !=
                                              null) {
                                        AppModel app = state;
                                        app.imagePath = file.files.first.path;
                                        AppStateDatabase()
                                            .updateApp(app)
                                            .then((_) {
                                          ref.refresh(appStateProvider);
                                          ref.invalidate(appStateProvider);
                                        });
                                      }
                                    });
                                  },
                                  child: Container(
                                    height: 160,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      // border: Border.all(color: theme.secondaryTextColor),
                                      color: theme.scaffoldBgColor,
                                      image: (state.imagePath == null ||
                                              (state.imagePath!.isEmpty))
                                          ? null
                                          : DecorationImage(
                                              image: FileImage(
                                                  File(state.imagePath ?? '')),
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                    // padding: 24.all,
                                    child: (state.imagePath == null ||
                                            (state.imagePath!.isEmpty))
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            spacing: 12,
                                            children: [
                                              Icon(
                                                Iconsax.document_upload,
                                                color: theme.secondaryTextColor,
                                                size: 32,
                                              ),
                                              Text(
                                                AppLocales.uploadImage.tr(),
                                                style: TextStyle(
                                                    fontFamily: mediumFamily,
                                                    fontSize: 16),
                                              )
                                            ],
                                          )
                                        : Align(
                                            alignment: Alignment.topRight,
                                            child: IconButton(
                                              onPressed: () {
                                                AppModel app = state;
                                                app.imagePath = null;
                                                AppStateDatabase()
                                                    .updateApp(app)
                                                    .then((_) {
                                                  ref.refresh(appStateProvider);
                                                  ref.invalidate(
                                                      appStateProvider);
                                                });
                                              },
                                              icon: Icon(
                                                Ionicons.close_circle_outline,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              spacing: 80,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  spacing: 12,
                                  children: [
                                    Text(
                                      AppLocales.printing.tr(),
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: mediumFamily),
                                    ),
                                    state.whenProviderData(
                                      provider: printerDevicesProvider,
                                      builder: (devices) {
                                        devices as List<Printer>;
                                        return CustomPopupMenu(
                                          theme: theme,
                                          children: [
                                            CustomPopupItem(
                                              icon: Icons.cancel_outlined,
                                              title: AppLocales.cancel.tr(),
                                              onPressed: () {
                                                AppModel kApp = state;
                                                kApp.token = '';
                                                kApp.refresh = '';
                                                AppStateDatabase()
                                                    .updateApp(kApp)
                                                    .then((_) {
                                                  ref.invalidate(
                                                      appStateProvider);
                                                });

                                                printer.value =
                                                    Printer(url: '');
                                                printerController.clear();
                                                ShowToast.success(
                                                    context,
                                                    AppLocales.savedSuccessfully
                                                        .tr());
                                              },
                                            ),
                                            for (final device in devices)
                                              CustomPopupItem(
                                                title: device.name,
                                                icon: Iconsax.printer_copy,
                                                onPressed: () {
                                                  printer.value = device;
                                                  printerController.text =
                                                      device.name;
                                                },
                                              ),
                                          ],
                                          child: IgnorePointer(
                                            ignoring: true,
                                            child: AppTextField(
                                              prefixIcon:
                                                  Icon(Iconsax.printer_copy),
                                              onlyRead: true,
                                              title: printer.value.name.isEmpty
                                                  ? AppLocales.print.tr()
                                                  : printer.value.name,
                                              controller: printerController,
                                              theme: theme,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    0.h,
                                    Text(
                                      AppLocales.generalPrint.tr(),
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: mediumFamily),
                                    ),
                                    state.whenProviderData(
                                      provider: printerDevicesProvider,
                                      builder: (devices) {
                                        devices as List<Printer>;
                                        return CustomPopupMenu(
                                          theme: theme,
                                          children: [
                                            CustomPopupItem(
                                              icon: Icons.cancel_outlined,
                                              title: AppLocales.cancel.tr(),
                                              onPressed: () async {
                                                AppModel kApp = state;
                                                kApp.generalPrintName = null;
                                                kApp.generalPrintUrl = null;
                                                await AppStateDatabase()
                                                    .updateApp(kApp);
                                                await LoggerService.save(
                                                  logType: LogType.printer,
                                                  actionType: ActionType.update,
                                                  itemId: "general_printer",
                                                  newValue:
                                                      "url: null, name: null",
                                                );
                                                ref.invalidate(
                                                    appStateProvider);

                                                managerPrinter.value =
                                                    Printer(url: '');
                                                printerController.clear();
                                                ShowToast.success(
                                                    context,
                                                    AppLocales.savedSuccessfully
                                                        .tr());
                                              },
                                            ),
                                            for (final device in devices)
                                              CustomPopupItem(
                                                title: device.name,
                                                icon: Iconsax.printer_copy,
                                                onPressed: () async {
                                                  managerPrinter.value = device;
                                                  AppModel settings = state;
                                                  settings.generalPrintUrl =
                                                      device.url;
                                                  settings.generalPrintName =
                                                      device.name;
                                                  await AppStateDatabase()
                                                      .updateApp(settings);
                                                  await LoggerService.save(
                                                    logType: LogType.printer,
                                                    actionType:
                                                        ActionType.update,
                                                    itemId: "general_printer",
                                                    newValue:
                                                        "url: ${device.url}, name: ${device.name}",
                                                  );
                                                  ref.invalidate(
                                                      appStateProvider);
                                                },
                                              ),
                                          ],
                                          child: IgnorePointer(
                                            ignoring: true,
                                            child: AppTextField(
                                              prefixIcon:
                                                  Icon(Iconsax.printer_copy),
                                              onlyRead: true,
                                              title: managerPrinter
                                                      .value.name.isEmpty
                                                  ? AppLocales.print.tr()
                                                  : managerPrinter.value.name,
                                              controller: TextEditingController(
                                                text: managerPrinter.value.name,
                                              ),
                                              theme: theme,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                ConfirmCancelButton(
                                  onlyConfirm: true,
                                  confirmText: AppLocales.save.tr(),
                                  onConfirm: () async {
                                    AppModel newState = state;

                                    newState.shopName =
                                        nameController.text.trim();
                                    newState.printPhone =
                                        phoneController.text.trim();
                                    newState.shopAddress =
                                        addressController.text.trim();
                                    newState.byeText =
                                        byeTextController.text.trim();
                                    newState.token = printer.value.url;
                                    newState.refresh = printer.value.name;

                                    if (managerPrinter.value.name.isNotEmpty) {
                                      newState.generalPrintUrl =
                                          managerPrinter.value.url;
                                      newState.generalPrintName =
                                          managerPrinter.value.name;
                                    }

                                    await AppStateDatabase()
                                        .updateApp(newState);
                                    await LoggerService.save(
                                      logType: LogType.app,
                                      actionType: ActionType.update,
                                      itemId: "app_settings",
                                      newValue: jsonEncode(newState.toJson()),
                                    );
                                    ref.refresh(appStateProvider);
                                    ref.invalidate(appStateProvider);

                                    ShowToast.success(context,
                                        AppLocales.savedSuccessfully.tr());
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                24.h,
                Container(
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
                        AppLocales.employeePasswordLabel.tr(),
                        style: TextStyle(
                          fontSize: context.s(24),
                          fontFamily: mediumFamily,
                          color: Colors.black,
                        ),
                      ),
                      Row(
                        spacing: 24,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              spacing: 12,
                              children: [
                                Text(
                                  AppLocales.oldPincodeLabel.tr(),
                                  style: TextStyle(
                                      fontSize: 16, fontFamily: mediumFamily),
                                ),
                                AppTextField(
                                  title: AppLocales.oldPincodeHint.tr(),
                                  controller: oldPincodeController,
                                  theme: theme,
                                  maxLength: 4,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              spacing: 12,
                              children: [
                                Text(
                                  AppLocales.newPincodeLabel.tr(),
                                  style: TextStyle(
                                      fontSize: 16, fontFamily: mediumFamily),
                                ),
                                AppTextField(
                                  title: AppLocales.enterNewPincode.tr(),
                                  controller: newPincodeController,
                                  theme: theme,
                                  maxLength: 4,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(flex: 3, child: SizedBox()),
                          Expanded(
                            flex: 3,
                            child: ConfirmCancelButton(
                              onlyConfirm: true,
                              confirmText: AppLocales.save.tr(),
                              onConfirm: () async {
                                AppModel newState = state;
                                if (newPincodeController.text
                                        .trim()
                                        .isNotEmpty &&
                                    oldPincodeController.text.trim() !=
                                        state.pincode) {
                                  return ShowToast.error(context,
                                      AppLocales.incorrectPincode.tr());
                                }

                                if (oldPincodeController.text.trim() ==
                                        state.pincode &&
                                    newPincodeController.text.trim().length ==
                                        4) {
                                  newState.pincode =
                                      newPincodeController.text.trim();
                                }

                                await AppStateDatabase().updateApp(newState);
                                await LoggerService.save(
                                  logType: LogType.app,
                                  actionType: ActionType.update,
                                  itemId: "app_settings",
                                  newValue: jsonEncode(newState.toJson()),
                                );
                                ref.refresh(appStateProvider);
                                ref.invalidate(appStateProvider);
                                ShowToast.success(
                                    context, AppLocales.savedSuccessfully.tr());

                                newPincodeController.clear();
                                oldPincodeController.clear();
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                24.h,
                state.whenProviderData(
                  provider: orderPercentProvider,
                  builder: (percents) {
                    percents as List<Percent>;

                    return Container(
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
                            AppLocales.percentsForOrder.tr(),
                            style: TextStyle(
                              fontSize: context.s(24),
                              fontFamily: mediumFamily,
                              color: Colors.black,
                            ),
                          ),
                          for (final item in percents)
                            AppListTile(
                              title: item.name,
                              subtitle: "${item.percent.toMeasure} %",
                              theme: theme,
                              margin: Dis.only(),
                              onDelete: () {
                                OrderPercentController apc =
                                    OrderPercentController(
                                        context: context, state: state);
                                apc.delete(item.id);
                              },
                              // onEdit: () {

                              // },/
                            ),
                          Row(
                            spacing: 24,
                            children: [
                              Expanded(
                                flex: 3,
                                child: AppTextField(
                                  title: AppLocales.enterPercentName.tr(),
                                  controller: percentNameController,
                                  theme: theme,
                                ),
                              ),
                              Expanded(
                                child: AppTextField(
                                  textInputType: TextInputType.number,
                                  title: AppLocales.pricePercentHint.tr(),
                                  controller: percentController,
                                  theme: theme,
                                  suffixIcon: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "%",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: theme.secondaryTextColor,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              AppPrimaryButton(
                                theme: theme,
                                onPressed: () {
                                  if (percentNameController.text
                                      .trim()
                                      .isEmpty) {
                                    ShowToast.error(context,
                                        AppLocales.percentNameInputError.tr());
                                    return;
                                  }

                                  final percent = double.tryParse(
                                      percentController.text.trim());
                                  if (percent == null || percent == 0.0) {
                                    ShowToast.error(context,
                                        AppLocales.percentInputError.tr());
                                    return;
                                  }

                                  OrderPercentController opc =
                                      OrderPercentController(
                                          context: context, state: state);
                                  Percent percentModel = Percent(
                                      name: percentNameController.text.trim(),
                                      percent: percent);
                                  opc.create(percentModel).then((_) {
                                    percentNameController.clear();
                                    percentController.clear();
                                  });
                                },
                                icon: Ionicons.add,
                                padding: Dis.only(lr: 12, tb: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                24.h,
                Container(
                  padding: context.s(20).all,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                    color: Colors.white,
                  ),
                  child: Column(
                    spacing: 8,
                    children: [
                      SwitchListTile(
                        activeThumbColor: theme.mainColor,
                        contentPadding: Dis.only(),
                        title: Text(AppLocales.firstDecrease.tr()),
                        value: appState.firstDecrease,
                        onChanged: (val) {
                          appState.firstDecrease = val;
                          AppStateDatabase().updateApp(appState).then((_) {
                            ref.invalidate(appStateProvider);
                          });
                        },
                      ),
                      Divider(),
                      SwitchListTile(
                        activeThumbColor: theme.mainColor,
                        contentPadding: Dis.only(),
                        title: Text(AppLocales.allowCloseWaiter.tr()),
                        value: appState.allowCloseWaiter,
                        onChanged: (val) {
                          appState.allowCloseWaiter = val;
                          AppStateDatabase().updateApp(appState).then((_) {
                            ref.invalidate(appStateProvider);
                          });
                        },
                      ),
                    ],
                  ),
                ),
                24.h,
                AppLanguageBar(),
                24.h,
                Row(
                  spacing: 24,
                  children: [
                    Expanded(
                      child: Container(
                        padding: context.s(20).all,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                          color: Colors.white,
                        ),
                        child: SwitchListTile(
                          activeThumbColor: theme.mainColor,
                          contentPadding: Dis.only(),
                          title: Text(AppLocales.offlineFormat.tr()),
                          value: appState.offline,
                          onChanged: (val) {
                            appState.offline = val;
                            AppStateDatabase().updateApp(appState).then((_) {
                              ref.invalidate(appStateProvider);
                            });
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: SimpleButton(
                        onPressed: () {
                          showDesktopModal(
                            context: context,
                            body: CacheSettingsScreen(),
                          );
                        },
                        child: Container(
                            padding: context.s(20).all,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                              color: Colors.white,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    spacing: 4,
                                    children: [
                                      Text(
                                        AppLocales.clearCache.tr(),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: boldFamily,
                                        ),
                                      ),
                                      Text(
                                        AppLocales.clearCacheInfoText.tr(),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: regularFamily,
                                        ),
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
                                Center(
                                  child: Icon(
                                    Icons.cleaning_services_rounded,
                                  ),
                                )
                              ],
                            )),
                      ),
                    ),
                  ],
                ),
                // 24.h,
                // Container(
                //   padding: context.s(20).all,
                //   decoration: BoxDecoration(
                //     borderRadius: BorderRadius.circular(12),
                //     border: Border.all(color: Colors.grey.shade200),
                //     color: Colors.white,
                //   ),
                //   child: SwitchListTile(
                //     activeThumbColor: theme.mainColor,
                //     contentPadding: Dis.only(),
                //     title: Text(AppLocales.cancelOrderFeature.tr()),
                //     value: appState.allowCancelOrder,
                //     onChanged: (val) {
                //       appState.allowCancelOrder = val;
                //       AppStateDatabase().updateApp(appState).then((_) {
                //         ref.invalidate(appStateProvider);
                //       });
                //     },
                //   ),
                // ),
                24.h,
                if ((ref.watch(networkInterfaceProvider).value ?? [])
                    .isNotEmpty)
                  NetworkInterfaceScreen(),
                24.h,
              ],
            ),
          ),
        );
      },
    );
  }
}

final _provider = FutureProvider((ref) async {
  try {
    final dio = Dio();
    await dio.get("${ApiEndpoints.baseUrl}/docs");
    return "Connected to server!";
  } catch (_) {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      return "Internet connection failed";
    }

    return "Internet connection success. But not connected to server";
  }
});

class NetworkConnection extends ConsumerWidget {
  const NetworkConnection({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return ref.watch(_provider).when(
          data: (data) {
            return Center(child: Text(data.toString()));
          },
          error: RefErrorScreen,
          loading: () => AppLoadingScreen(),
        );
  }
}
