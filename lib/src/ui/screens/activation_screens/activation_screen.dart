import 'package:biznex/biznex.dart';
import 'package:biznex/src/controllers/cloud_data_controller.dart';
import 'package:biznex/src/core/config/router.dart';
import 'package:biznex/src/core/database/app_database/app_state_database.dart';
import 'package:biznex/src/core/services/license_services.dart';
import 'package:biznex/src/providers/app_state_provider.dart';
import 'package:biznex/src/ui/pages/login_pages/onboard_page.dart';
import 'package:biznex/src/ui/widgets/custom/app_loading.dart';
import 'package:biznex/src/ui/widgets/custom/app_text_widgets.dart';
import 'package:biznex/src/ui/widgets/custom/app_toast.dart';
import 'package:biznex/src/ui/widgets/helpers/app_decorated_button.dart';
import 'package:biznex/src/ui/widgets/helpers/app_text_field.dart';
import 'package:flutter/services.dart';

class ActivationScreen extends StatefulHookConsumerWidget {
  final AppModel state;
  final AppColors theme;

  const ActivationScreen({super.key, required this.state, required this.theme});

  @override
  ConsumerState<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends ConsumerState<ActivationScreen> {
  AppModel get state => widget.state;
  final TextEditingController _textEditingController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _expireDateController = TextEditingController();
  LicenseServices licenseServices = LicenseServices();
  CloudDataController cloudDataController = CloudDataController();

  AppColors get theme => widget.theme;
  String deviceId = '';

   void _getDeviceId() async {
    final id = await licenseServices.getDeviceId();
    // setState o'zi mounted tekshiruvini amalga oshiradi,
    // lekin aniqlik uchun qo'shish mumkin.
    if (mounted) {
      setState(() {
        deviceId = id ?? '';
      });
    }
  }

  void _verifyLicenseKey() async {
    if (_textEditingController.text.trim().isEmpty) return;

    final key = _textEditingController.text.trim();
    final status = await licenseServices.verifyLicense(key);

     if (!mounted) return; 

    if (status) {
      AppModel newApp = state;
      newApp.licenseKey = key;
     
      await AppStateDatabase().updateApp(newApp);  

      // Agar updateApp Future qaytarmasa va .then ishlatilsa:
      /*
      AppStateDatabase().updateApp(newApp).then((_) {
        if (mounted) { // .then callback'i ichida ham tekshirish
          ref.invalidate(appStateProvider);
        }
      });
      */

      
      if (!mounted) return;
      ref.invalidate(appStateProvider); 

      await cloudDataController.createCloudAccount(
        _passwordController.text.trim(),
        (DateTime.tryParse(_expireDateController.text) ?? DateTime(3000)).toIso8601String(),
      );

      
      if (!mounted) return; 

      AppRouter.open(context, OnboardPage());
    } else {
      
      if (!mounted) return;
      ShowToast.error(context, AppLocales.licenseKeyError.tr(), alignment: Alignment.topCenter);
    }
  }

  @override
  void initState() {
    super.initState();
    _getDeviceId();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _passwordController.dispose();
    _expireDateController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: 24.all,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: theme.accentColor,
          ),
          constraints: BoxConstraints(maxWidth: 800, maxHeight: 800),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: 24,
            children: [
              Center(child: AppText.$32Bold(AppLocales.confirmLicenseKey.tr())),
              SimpleButton(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: deviceId));
                  ShowToast.success(context, AppLocales.copied.tr());
                },
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: theme.scaffoldBgColor,
                  ),
                  padding: Dis.only(lr: 24, tb: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(child: Text(deviceId, style: TextStyle(fontSize: 16))),
                      16.w,
                      Icon(Ionicons.copy_outline),
                    ],
                  ),
                ),
              ),
              AppTextField(
                title: AppLocales.enterKey.tr(),
                controller: _textEditingController,
                theme: theme,
                fillColor: theme.scaffoldBgColor,
                suffixIcon: SimpleButton(
                  child: Icon(Ionicons.clipboard_outline),
                  onPressed: () async {
                    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
                    String? clipboardText = clipboardData?.text;
                    _textEditingController.text = clipboardText ?? '';
                    setState(() {});
                  },
                ),
              ),
              Row(
                spacing: 24,
                children: [
                  Expanded(
                    child: AppTextField(
                      title: "Parol",
                      controller: _passwordController,
                      theme: theme,
                      prefixIcon: Icon(Ionicons.key_outline),
                    ),
                  ),
                  Expanded(
                    child: AppTextField(
                      onlyRead: true,
                      onTap: () {
                        showDatePicker(
                          context: context,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(Duration(days: 365000)),
                        ).then((value) {
                          if (value != null) {
                            _expireDateController.text = value.toLocal().toString();
                            setState(() {});
                          }
                        });
                      },
                      title: _expireDateController.text.isEmpty
                          ? "Muddat"
                          : DateFormat(DateFormat.YEAR_MONTH_DAY, 'uz').format(DateTime.parse(_expireDateController.text.split("T").first)),
                      controller: _expireDateController,
                      theme: theme,
                      prefixIcon: Icon(Ionicons.calendar_outline),
                    ),
                  ),
                ],
              ),
              AppPrimaryButton(
                theme: theme,
                onPressed: _verifyLicenseKey,
                title: AppLocales.login.tr(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
