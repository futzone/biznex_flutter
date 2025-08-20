import 'dart:io';
import 'package:biznex/biznex.dart';
import 'package:biznex/src/controllers/orcer_percent_controller.dart';
import 'package:biznex/src/core/config/router.dart';
import 'package:biznex/src/core/database/app_database/app_state_database.dart';
import 'package:biznex/src/core/model/order_models/percent_model.dart';
import 'package:biznex/src/providers/app_state_provider.dart';
import 'package:biznex/src/providers/price_percent_provider.dart';
import 'package:biznex/src/providers/printer_devices_provider.dart';
import 'package:biznex/src/ui/widgets/custom/app_custom_popup_menu.dart';
import 'package:biznex/src/ui/widgets/custom/app_list_tile.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:biznex/src/ui/widgets/custom/app_text_widgets.dart';
import 'package:biznex/src/ui/widgets/helpers/app_decorated_button.dart';
import 'package:biznex/src/ui/widgets/helpers/app_text_field.dart';
import 'package:image_picker/image_picker.dart';
import 'package:printing/printing.dart';

class OrderSettingsScreen extends HookConsumerWidget {
  final AppModel state;

  const OrderSettingsScreen(this.state, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final percentNameController = useTextEditingController();
    final percentController = useTextEditingController();
    final showNameController = useTextEditingController(text: state.shopName);
    final showAddressController = useTextEditingController(text: state.shopAddress);
    final byeTextController = useTextEditingController(text: state.byeText);
    final printPhone = useTextEditingController(text: state.printPhone);
    final imagePath = useState<String?>(state.imagePath);

    return AppStateWrapper(builder: (theme, state) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              spacing: 16,
              children: [
                SimpleButton(child: Icon(Icons.arrow_back_ios_new), onPressed: () => AppRouter.close(context)),
                AppText.$18Bold(AppLocales.settings.tr()),
              ],
            ),

            24.h,
            AppText.$18Bold(AppLocales.printing.tr()),
            8.h,

            ///
            state.whenProviderData(
              provider: printerDevicesProvider,
              builder: (devices) {
                devices as List<Printer>;
                return CustomPopupMenu(
                  theme: theme,
                  children: [
                    for (final item in devices)
                      CustomPopupItem(
                        icon: Ionicons.print_outline,
                        title: item.name,
                        onPressed: () {
                          AppModel kApp = state;
                          kApp.token = item.url;
                          kApp.refresh = item.name;
                          AppStateDatabase().updateApp(kApp).then((_) {
                            ref.invalidate(appStateProvider);
                          });
                        },
                      ),
                  ],
                  child: Container(
                    width: double.infinity,
                    padding: 12.all,
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.secondaryTextColor),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      spacing: 16,
                      children: [
                        Icon(Ionicons.print_outline, size: 20, color: theme.textColor),
                        Text(
                          AppLocales.printing.tr(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            ///
            24.h,
            AppText.$18Bold(AppLocales.percentsForOrder.tr()),
            8.h,

            Row(
              spacing: 16,
              children: [
                Expanded(
                  flex: 5,
                  child: AppTextField(
                    title: AppLocales.enterPercentName.tr(),
                    controller: percentNameController,
                    theme: theme,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: AppTextField(
                    title: '%',
                    controller: percentController,
                    textInputType: TextInputType.number,
                    theme: theme,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: AppPrimaryButton(
                    theme: theme,
                    onPressed: () {
                      OrderPercentController opController = OrderPercentController(
                        context: context,
                        state: state,
                        onCompleted: () {
                          percentController.clear();
                          percentNameController.clear();
                        },
                      );
                      Percent percent = Percent(
                        name: percentNameController.text.trim(),
                        percent: double.tryParse(percentController.text.trim()) ?? 0,
                      );

                      opController.create(percent);
                    },
                    padding: 13.tb,
                    icon: Icons.add,
                  ),
                ),
              ],
            ),
            state.whenProviderData(
              provider: orderPercentProvider,
              builder: (percents) {
                percents as List<Percent>;

                return Column(
                  children: [
                    if (percents.isNotEmpty) 8.h,
                    for (final percent in percents)
                      AppListTile(
                        title: "${percent.name} — ${percent.percent.toStringAsFixed(1)} %",
                        theme: theme,
                        onDelete: () {
                          OrderPercentController opController = OrderPercentController(context: context, state: state);
                          opController.delete(percent.id);
                        },
                      )
                  ],
                );
              },
            ),
            24.h,
            AppText.$18Bold(AppLocales.shopName.tr()),
            8.h,
            AppTextField(title: AppLocales.shopNameHint.tr(), controller: showNameController, theme: theme),
            24.h,
            AppText.$18Bold(AppLocales.shopAddressLabel.tr()),
            8.h,
            AppTextField(title: AppLocales.shopAddressHint.tr(), controller: showAddressController, theme: theme),
            24.h,
            AppText.$18Bold(AppLocales.orderCheckByeText.tr()),
            8.h,
            AppTextField(title: AppLocales.orderCheckByeTextHint.tr(), controller: byeTextController, theme: theme),
            24.h,
            AppText.$18Bold(AppLocales.phoneForPrintLabel.tr()),
            8.h,
            AppTextField(title: AppLocales.enterPhoneNumber.tr(), controller: printPhone, theme: theme),
            24.h,
            AppText.$18Bold(AppLocales.shopLogoLabel.tr()),
            8.h,
            SimpleButton(
              onPressed: () {
                ImagePicker().pickImage(source: ImageSource.gallery).then((img) {
                  if (img != null) imagePath.value = img.path;
                });
              },
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: theme.accentColor,
                  image: imagePath.value == null || imagePath.value!.isEmpty
                      ? null
                      : DecorationImage(
                          image: FileImage(File(imagePath.value!)),
                          fit: BoxFit.cover,
                        ),
                ),
                child: imagePath.value == null || imagePath.value!.isEmpty ? Icon(Icons.cloud_upload_outlined, size: 60) : null,
              ),
            ),
            24.h,
            ConfirmCancelButton(
              onConfirm: () {
                AppModel newModel = state;
                newModel.shopName = showNameController.text.trim();
                newModel.shopAddress = showAddressController.text.trim();
                newModel.byeText = byeTextController.text.trim();
                newModel.printPhone = printPhone.text.trim();
                newModel.imagePath = imagePath.value;

                AppStateDatabase().updateApp(newModel).then((_) {
                  ref.invalidate(appStateProvider);
                  ref.invalidate(appStateProvider);
                  ref.refresh(appStateProvider);
                  AppRouter.close(context);
                });
              },
              confirmText: AppLocales.save.tr(),
            ),
            24.h,
          ],
        ),
      );
    });
  }
}
