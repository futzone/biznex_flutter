import 'dart:developer';
import 'dart:ui';
import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/config/router.dart';
import 'package:biznex/src/core/database/app_database/app_database.dart';
import 'package:biznex/src/core/database/app_database/app_state_database.dart';
import 'package:biznex/src/core/extensions/device_type.dart';
import 'package:biznex/src/core/network/api.dart';
import 'package:biznex/src/providers/app_state_provider.dart';
import 'package:biznex/src/providers/category_provider.dart';
import 'package:biznex/src/providers/employee_provider.dart';
import 'package:biznex/src/core/services/network_services.dart';
import 'package:biznex/src/providers/products_provider.dart';
import 'package:biznex/src/server/constants/api_endpoints.dart';
import 'package:biznex/src/ui/pages/login_pages/login_page.dart';
import 'package:biznex/src/ui/widgets/custom/app_error_screen.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:biznex/src/ui/widgets/dialogs/app_custom_dialog.dart';
import 'package:biznex/src/ui/widgets/helpers/app_decorated_button.dart';
import 'package:biznex/src/ui/widgets/helpers/app_loading_screen.dart';
import 'package:biznex/src/ui/widgets/helpers/app_text_field.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fullscreen_window/fullscreen_window.dart';
import '../../../core/database/app_database/app_screen_database.dart';
import '../../screens/onboarding_screens/onboard_card.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'api_address_screen.dart';
import 'onboard_mobile.dart';

class OnboardPage extends ConsumerStatefulWidget {
  const OnboardPage({super.key});

  @override
  ConsumerState<OnboardPage> createState() => _OnboardPageState();
}

class _OnboardPageState extends ConsumerState<OnboardPage> {
  final TextEditingController _controller = TextEditingController();
  bool showWarning = true;

  @override
  Widget build(BuildContext context) {
    return AppStateWrapper(
      builder: (theme, state) {
        return ref.watch(employeeProvider).when(
              error: (error, stackTrace) {
                log('onboard', error: error, stackTrace: stackTrace);
                return AppErrorScreen();
              },
              loading: () => AppLoadingScreen(),
              data: (employees) {
                if (employees.isEmpty &&
                    getDeviceType(context) == DeviceType.mobile) {
                  return Scaffold(
                    body: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 16,
                          children: [
                            Text(
                              AppLocales.enterAddress.tr(),
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: boldFamily,
                              ),
                            ),
                            AppTextField(
                              title: "192.168.X.X",
                              controller: _controller,
                              theme: theme,
                              useBorder: true,
                              fillColor: theme.accentColor,
                              textInputType: TextInputType.number,
                            ),
                            AppPrimaryButton(
                              padding: Dis.only(tb: 12),
                              theme: theme,
                              onPressed: () {
                                AppModel nm = state;
                                nm.apiUrl = _controller.text.trim();
                                AppStateDatabase().updateApp(nm).then((_) {
                                  ref.invalidate(appStateProvider);
                                  ref.invalidate(employeeProvider);
                                });

                                // if(ApiBase().get(baseUrl: , path: path))
                              },
                              child: Text(
                                AppLocales.login,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: boldFamily,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                if (employees.isEmpty) {
                  return LoginPageHarom(
                      model: state, theme: theme, fromAdmin: true);
                }
                if (getDeviceType(context) == DeviceType.mobile) {
                  return OnboardMobile(
                      employees: employees, theme: theme, state: state);
                }

                return Scaffold(
                  body: Container(
                    height: double.infinity,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                            'assets/images/0307ca967f3a160c45813e6188ae5bf31a7a7ecf.png'),
                        filterQuality: FilterQuality.low,
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.2),
                      child: Column(
                        children: [
                          state.whenProviderData(
                              provider: appExpireProvider,
                              builder: (data) {
                                log(data.toString());
                                if (data <= 3 && showWarning) {
                                  return Container(
                                    padding: Dis.only(lr: 16, tb: 16),
                                    decoration: BoxDecoration(
                                      color: theme.white,
                                    ),
                                    child: Row(
                                      spacing: 12,
                                      children: [
                                        Icon(
                                          Ionicons.warning_outline,
                                          color: Colors.amber.shade700,
                                          size: 24,
                                        ),
                                        Expanded(
                                          child: Text(
                                            AppLocales.subscriptionPaymentText
                                                .tr(),
                                            style: TextStyle(
                                              fontFamily: mediumFamily,
                                              color: Colors.amber.shade700,
                                            ),
                                          ),
                                        ),
                                        SimpleButton(
                                          onPressed: () => setState(
                                              () => showWarning = false),
                                          child: Container(
                                            padding: Dis.only(lr: 12, tb: 4),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: theme.secondaryTextColor,
                                              ),
                                            ),
                                            child: Row(
                                              spacing: 8,
                                              children: [
                                                Icon(
                                                  Icons.close,
                                                  size: 16,
                                                  color:
                                                      theme.secondaryTextColor,
                                                ),
                                                Text(
                                                  AppLocales.close.tr(),
                                                  style: TextStyle(
                                                    fontFamily: regularFamily,
                                                    fontSize: 12,
                                                    color: theme
                                                        .secondaryTextColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                return 0.h;
                              }),
                          ClipRRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: 56,
                                sigmaY: 56,
                              ),
                              child: Container(
                                padding: Dis.only(lr: 24, tb: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SvgPicture.asset(
                                        "assets/images/Vector.svg"),
                                    Spacer(),
                                    IconButton(
                                      onPressed: () {
                                        ref.invalidate(employeeProvider);
                                        ref.invalidate(productsProvider);
                                        ref.invalidate(allCategoryProvider);
                                        ref.invalidate(categoryProvider);
                                      },
                                      icon: Icon(
                                        Icons.sync,
                                        size: 32,
                                        color: Colors.white,
                                      ),
                                    ),
                                    IconButton(
                                      onLongPress: () async {
                                        state.apiUrl = null;
                                        AppStateDatabase().updateApp(state);
                                      },
                                      onPressed: () async {
                                        showDesktopModal(
                                            context: context,
                                            body: ApiAddressScreen(),
                                            width: 400);
                                      },
                                      icon: Icon(
                                        Icons.language,
                                        size: 28,
                                        color: Colors.white,
                                      ),
                                    ),
                                    IconButton(
                                      // onLongPress: ,
                                      onPressed: () async {
                                        final isFullScreen =
                                            await ScreenDatabase.get();
                                        await FullScreenWindow.setFullScreen(
                                                !isFullScreen)
                                            .then((_) async {
                                          await ScreenDatabase.set();
                                        });
                                      },
                                      icon: Icon(
                                        Icons.fullscreen,
                                        size: 32,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GridView.builder(
                              padding: 16.all,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 2.0,
                              ),
                              itemCount: state.apiUrl == null
                                  ? employees.length + 1
                                  : employees.length,
                              itemBuilder: (context, index) {
                                if (index == 0 && state.apiUrl == null) {
                                  return OnboardCard(
                                    theme: theme,
                                    roleName: "Admin",
                                    fullname: "Admin",
                                    onPressed: () {
                                      AppRouter.go(
                                          context,
                                          LoginPageHarom(
                                              model: state,
                                              theme: theme,
                                              fromAdmin: true));
                                    },
                                  );
                                }
                                final employee = employees[
                                    state.apiUrl == null ? (index - 1) : index];
                                return OnboardCard(
                                  theme: theme,
                                  roleName: employee.roleName,
                                  fullname: employee.fullname,
                                  onPressed: () {
                                    ref
                                        .read(currentEmployeeProvider.notifier)
                                        .update((state) => employee);
                                    AppRouter.go(
                                      context,
                                      LoginPageHarom(
                                          model: state, theme: theme),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
      },
    );
  }
}

class QrAddressView extends ConsumerWidget {
  const QrAddressView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(ipProvider).when(
        data: (ip) {
          if (ip == null) return 0.h;

          log('server address: $ip:8080');
          return Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                QrImageView(
                  data: ip,
                  version: QrVersions.auto,
                  size: 400.0,
                ),
                16.h,
                SingleChildScrollView(
                  child: Text(
                    "IP: $ip",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        error: RefErrorScreen,
        loading: () => AppLoadingScreen());
  }
}
