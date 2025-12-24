import 'dart:developer';
import 'dart:io';
import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/config/router.dart';
import 'package:biznex/src/core/database/app_database/app_state_database.dart';
import 'package:biznex/src/core/database/changes_database/changes_database.dart';
import 'package:biznex/src/core/extensions/device_type.dart';
import 'package:biznex/src/core/model/app_changes_model.dart';
import 'package:biznex/src/core/model/employee_models/employee_model.dart';
import 'package:biznex/src/core/utils/cashier_utils.dart';
import 'package:biznex/src/providers/app_state_provider.dart';
import 'package:biznex/src/providers/employee_provider.dart';
import 'package:biznex/src/ui/pages/login_pages/login_half_page.dart';
import 'package:biznex/src/ui/pages/main_pages/main_page.dart';
import 'package:biznex/src/ui/pages/waiter_pages/waiter_page.dart';
import 'package:biznex/src/ui/widgets/custom/app_text_widgets.dart';
import 'package:biznex/src/ui/widgets/custom/app_toast.dart';
import 'package:biznex/src/ui/widgets/helpers/app_decorated_button.dart';
import 'package:flutter/services.dart';
import 'package:pin_keyboard/pin_keyboard.dart';
import '../../widgets/dialogs/app_custom_dialog.dart';
import 'api_address_screen.dart';

class LoginPageHarom extends ConsumerStatefulWidget {
  final AppModel model;
  final AppColors theme;
  final void Function()? onSuccessEnter;
  final bool fromAdmin;

  const LoginPageHarom({
    super.key,
    this.onSuccessEnter,
    required this.model,
    required this.theme,
    this.fromAdmin = false,
  });

  @override
  ConsumerState<LoginPageHarom> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPageHarom> {
  String _pincode = '';
  final FocusNode _focusNode = FocusNode();

  AppModel get model => widget.model;

  AppColors get theme => widget.theme;

  ChangesDatabase get changesDatabase => ChangesDatabase();

  void onNextPressed(String pincode, Employee employee) async {
    await Future.delayed(Duration(milliseconds: 100));
    if (_pincode.length == 4) {
      final enteredPin = _pincode;

      if (model.pincode.isEmpty && employee.roleName.toLowerCase() == 'admin') {
        final app = model..pincode = enteredPin;
        await AppStateDatabase().updateApp(app);
        model.ref!.invalidate(appStateProvider);
        ref.read(currentEmployeeProvider.notifier).update((e) {
          return Employee(fullname: 'Admin', roleId: '-1', roleName: 'admin');
        });

        changesDatabase.set(
          data: Change(
            database: 'app',
            method: 'login',
            itemId: 'admin',
            data: enteredPin,
          ),
        );
        return AppRouter.open(context, MainPage());
      }

      if (widget.fromAdmin && model.pincode == enteredPin) {
        ref.read(currentEmployeeProvider.notifier).update((e) {
          return Employee(fullname: 'Admin', roleId: '-1', roleName: 'admin');
        });

        changesDatabase.set(
          data: Change(
            database: 'app',
            method: 'login',
            itemId: 'admin',
            data: enteredPin,
          ),
        );
        return AppRouter.open(context, MainPage());
      }

      if (!widget.fromAdmin) {
        if (pincode != enteredPin) {
          log("$pincode!= $enteredPin");
          ShowToast.error(context, AppLocales.incorrectPincode.tr());
          _pincode = '';
          return setState(() {});
        }

        changesDatabase.set(
          data: Change(
            database: 'app',
            method: 'login',
            itemId: employee.id,
          ),
        );

        final isCashierValue = await isCashier(employee);
        if (isCashierValue) {
          return AppRouter.open(context, MainPage());
        }
        return AppRouter.open(context, WaiterPage());
      }

      if (model.pincode == enteredPin && widget.onSuccessEnter != null) {
        widget.onSuccessEnter!();
        return AppRouter.close(context);
      }

      if (employee.roleName.toLowerCase() == 'admin' && pincode == enteredPin) {
        ref.read(currentEmployeeProvider.notifier).update((e) {
          return Employee(fullname: 'Admin', roleId: '-1', roleName: 'admin');
        });
        changesDatabase.set(
          data: Change(
            database: 'app',
            method: 'login',
            itemId: 'admin',
            data: enteredPin,
          ),
        );
        return AppRouter.open(context, MainPage());
      }

      ShowToast.error(context, AppLocales.incorrectPincode.tr());
      _pincode = '';
      return setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentEmployee = ref.watch(currentEmployeeProvider);
    return RawKeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKey: (RawKeyEvent keyEvent) {
        if (keyEvent is RawKeyDownEvent) {
          final key = keyEvent.logicalKey.keyLabel;

          if (int.tryParse(key) != null && _pincode.length < 4) {
            setState(() {
              _pincode += key;
              if (_pincode.length == 4) {
                Future.microtask(() {
                  onNextPressed(currentEmployee.pincode, currentEmployee);
                });
              }
            });
          }
        }
      },
      child: Scaffold(
        body: Row(
          children: [
            if (getDeviceType(context) != DeviceType.mobile)
              LoginHalfPage(model),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  spacing: 24,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/Vector 614.png', width: 160),
                    Text(
                      !Platform.isWindows
                          ? AppLocales.enterPincode.tr()
                          : (model.pincode.isEmpty
                              ? AppLocales.enterNewPincode.tr()
                              : AppLocales.enterPincode.tr()),
                      style: TextStyle(
                        fontSize: 28,
                        fontFamily: mediumFamily,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 16,
                      children: List.generate(4, (index) {
                        return Container(
                          height: 68,
                          width: 68,
                          decoration: BoxDecoration(
                            color: theme.accentColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: !(index < _pincode.length)
                              ? null
                              : Icon(
                                  Icons.circle,
                                  color: theme.mainColor,
                                ),
                        );
                      }),
                    ),
                    PinKeyboard(
                      maxWidth: getDeviceType(context) != DeviceType.mobile
                          ? MediaQuery.of(context).size.width * 0.3
                          : double.infinity,
                      space: MediaQuery.of(context).size.height * 0.1,
                      textColor: widget.theme.textColor,
                      length: 4,
                      enableBiometric: false,
                      iconBackspaceColor: widget.theme.textColor,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      onChange: (pin) {
                        setState(() {
                          _pincode = pin;
                        });
                      },
                      onConfirm: (pin) {
                        Future.microtask(() {
                          onNextPressed(
                            currentEmployee.pincode,
                            currentEmployee,
                          );
                        });
                      },
                      // onBiometric: () {},
                    ),
                    0.h,
                    Row(
                      spacing: 16,
                      children: [
                        if (model.pincode.isEmpty && Platform.isWindows)
                          Expanded(
                            child: AppPrimaryButton(
                              color: Colors.white,
                              border: Border.all(color: Colors.white),
                              theme: theme,
                              onPressed: () {
                                showDesktopModal(
                                  context: context,
                                  body: ApiAddressScreen(),
                                  width: 480,
                                );
                              },
                              child: Row(
                                spacing: 8,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    AppLocales.enterAddress.tr(),
                                    style: TextStyle(
                                      fontFamily: mediumFamily,
                                      fontSize: 18,
                                      color: theme.textColor,
                                    ),
                                  ),
                                  Icon(
                                    Icons.language_outlined,
                                    size: 20,
                                    color: theme.textColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        Expanded(
                          child: AppPrimaryButton(
                            theme: theme,
                            onPressed: () {
                              onNextPressed(
                                  currentEmployee.pincode, currentEmployee);
                            },
                            child: Row(
                              spacing: 8,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  AppLocales.login.tr(),
                                  style: TextStyle(
                                    fontFamily: mediumFamily,
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                                Icon(Icons.arrow_forward,
                                    size: 20, color: Colors.white),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildNumberButton({
    required void Function() onPressed,
    required String number,
    IconData? icon,
    bool primary = false,
  }) {
    return SimpleButton(
      onPressed: onPressed,
      child: Container(
        width: 160,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: number.isEmpty
              ? null
              : primary
                  ? theme.mainColor
                  : theme.accentColor,
        ),
        child: Center(
          child: icon == null
              ? AppText.$24Bold(number)
              : Icon(
                  icon,
                  color: primary ? Colors.white : null,
                ),
        ),
      ),
    );
  }
}
