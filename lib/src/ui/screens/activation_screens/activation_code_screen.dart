import 'package:biznex/src/controllers/app_subscription_controller.dart';
import 'package:biznex/src/core/services/license_services.dart';
import 'package:biznex/src/providers/app_state_provider.dart';
import 'package:biznex/src/ui/widgets/helpers/app_loading_screen.dart';
import '../../../../biznex.dart';
import '../../../core/cloud/cloud_services.dart';
import '../../../core/config/router.dart';
import '../../../core/database/app_database/app_state_database.dart';
import '../../../providers/license_status_provider.dart';
import '../../widgets/custom/app_loading.dart';
import '../../widgets/custom/app_state_wrapper.dart';
import '../../widgets/custom/app_toast.dart';
import '../../widgets/helpers/app_decorated_button.dart';
import '../../widgets/helpers/app_text_field.dart';

class ActivationCodeScreen extends StatefulWidget {
  final WidgetRef ref;
  final AppModel state;

  const ActivationCodeScreen(
      {super.key, required this.ref, required this.state});

  @override
  State<ActivationCodeScreen> createState() => _ActivationTestPageState();
}

class _ActivationTestPageState extends State<ActivationCodeScreen> {
  // late AppSubscriptionController _controller;
  // int? code;
  // bool _initializing = true;
  //
  // _initialize() async {
  //   setState(() {
  //     _controller = AppSubscriptionController(context);
  //   });
  //
  //   await _controller.createSubscription().then((co) {
  //     setState(() {
  //       code = co;
  //       _initializing = false;
  //     });
  //   });
  //
  //   await _controller.listenChanges(onChanged: (String token) async {
  //     AppModel newApp = widget.state;
  //     newApp.licenseKey = token;
  //     await LicenseServices().verifyLicense(token);
  //
  //     AppStateDatabase().updateApp(newApp).then((_) {
  //       widget.ref.invalidate(appStateProvider);
  //     });
  //   });
  // }
  //
  // @override
  // void initState() {
  //   super.initState();
  //   _initialize();
  // }
  //
  // @override
  // Widget build(BuildContext context) {
  //   final theme = AppColors(isDark: false);
  //   return Scaffold(
  //     body: Center(
  //       child: _initializing
  //           ? AppLoadingScreen()
  //           : Container(
  //               padding: 16.all,
  //               constraints: BoxConstraints(maxWidth: 600),
  //               margin: Dis.only(lr: 160, tb: 48),
  //               decoration: BoxDecoration(
  //                 borderRadius: BorderRadius.circular(24),
  //                 color: theme.cardColor,
  //               ),
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 crossAxisAlignment: CrossAxisAlignment.center,
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 spacing: 16,
  //                 children: [
  //                   Image.asset(
  //                     "assets/icons/expired.png",
  //                     height: 100,
  //                   ),
  //                   Text(
  //                     AppLocales.subscriptionPaymentTextForCode.tr(),
  //                     style: TextStyle(fontSize: 16, fontFamily: mediumFamily),
  //                     textAlign: TextAlign.center,
  //                   ),
  //                   Text(
  //                     code.toString().split('').join(' '),
  //                     style: TextStyle(
  //                       color: theme.mainColor,
  //                       fontSize: 48,
  //                       fontFamily: boldFamily,
  //                     ),
  //                   ),
  //                   Text(
  //                     "${AppLocales.contactWithUs.tr()}:  +998 94 244 99 89",
  //                     style: TextStyle(fontSize: 16, fontFamily: mediumFamily),
  //                     textAlign: TextAlign.center,
  //                   ),
  //                 ],
  //               ),
  //             ),
  //     ),
  //   );
  // }

  final BiznexCloudServices biznexCloudServices = BiznexCloudServices();
  final TextEditingController loginController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  void _onLogin(WidgetRef ref) async {
    if (int.tryParse(addressController.text.trim().replaceAll(".", "")) !=
        null) {
      final AppStateDatabase stateDatabase = AppStateDatabase();
      AppModel model = widget.state;
      model.apiUrl = addressController.text.trim();
      await stateDatabase.updateApp(model);
      try {
        ref.invalidate(appStateProvider);
      } catch (_) {}
      return;
    }

    final password = passwordController.text.trim();
    final username = loginController.text.trim();

    if (password.isEmpty) {
      ShowToast.error(context, AppLocales.passwordInputError.tr());
      return;
    }

    if (username.isEmpty) {
      ShowToast.error(context, AppLocales.loginInputError.tr());
      return;
    }

    showAppLoadingDialog(context);
    final response = await biznexCloudServices.signIn(password, username);

    if (mounted) AppRouter.close(context);

    if (response.success) {
      ref.refresh(licenseStatusProvider);
      ref.invalidate(licenseStatusProvider);
      ref.invalidate(appStateProvider);
      return;
    }

    if (response.unauthorized) {
      ShowToast.error(context, "Login yoki parol noto'g'ri kiritilgan!");
      return;
    }

    ShowToast.error(
      context,
      response.message ?? AppLocales.internetConnectionError.tr(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppStateWrapper(
      builder: (theme, state) {
        return Scaffold(
          body: Center(
            child: Container(
              padding: Dis.only(lr: 24, tb: 16),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16), color: theme.white),
              width: 480,
              child: Column(
                spacing: 16,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 16,
                    children: [
                      Icon(Ionicons.log_in_outline, size: 48),
                      Text(
                        AppLocales.login.tr(),
                        style: TextStyle(
                          fontSize: 24,
                          fontFamily: boldFamily,
                        ),
                      ),
                    ],
                  ),
                  AppTextField(
                    prefixIcon: Icon(Icons.login),
                    title: AppLocales.loginHint.tr(),
                    controller: loginController,
                    theme: theme,
                  ),
                  AppTextField(
                    prefixIcon: Icon(Icons.password),
                    title: AppLocales.passwordHint.tr(),
                    controller: passwordController,
                    theme: theme,
                  ),
                  Text(AppLocales.ifRemoteDevice.tr()),
                  AppTextField(
                    prefixIcon: Icon(Icons.desktop_windows_outlined, size: 20),
                    title: "192.168.X.X",
                    controller: addressController,
                    theme: theme,
                  ),
                  Consumer(
                    builder: (context, ref, child) {
                      return AppPrimaryButton(
                        theme: theme,
                        onPressed: () => _onLogin(ref),
                        title: AppLocales.login.tr(),
                      );
                    },
                  ),
                  Text(
                    "${AppLocales.contactWithUs.tr()}: +998 94 244 99 89",
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: boldFamily,
                      color: theme.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
