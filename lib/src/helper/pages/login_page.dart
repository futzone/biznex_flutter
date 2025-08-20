import 'dart:convert';
import 'dart:developer';

import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/config/router.dart';
import 'package:biznex/src/core/model/employee_models/employee_model.dart';
import 'package:biznex/src/helper/pages/waiter_helper_page.dart';
import 'package:biznex/src/helper/services/api_services.dart';
import 'package:biznex/src/providers/employee_provider.dart';
import 'package:biznex/src/ui/pages/login_pages/intro_page.dart';
import 'package:biznex/src/ui/pages/waiter_pages/waiter_page.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:biznex/src/ui/widgets/custom/app_text_widgets.dart';
import 'package:biznex/src/ui/widgets/custom/app_toast.dart';
import 'package:biznex/src/ui/widgets/dialogs/app_custom_dialog.dart';

import '../screens/enter_url_screen.dart';

class HelperLoginPage extends ConsumerStatefulWidget {
  const HelperLoginPage({super.key});

  @override
  ConsumerState<HelperLoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<HelperLoginPage> {
  List<String> pincodeChars = ['', '', '', ''];

  void onPressedNumber(String number) async {
    for (int i = 0; i < pincodeChars.length; i++) {
      if (pincodeChars[i].isEmpty) {
        pincodeChars[i] = number;
        setState(() {});
        break;
      }
    }
  }

  void onNextPressed() async {
    if (pincodeChars.every((e) => e.isNotEmpty)) {
      final enteredPin = pincodeChars.join('');

      HelperApiServices helperApiServices = HelperApiServices();
      final response = await helperApiServices.getMe(enteredPin);
      if (response.isSuccess) {
        ref.read(currentEmployeeProvider.notifier).update((state) {
          return Employee.fromJson(jsonDecode(response.data));
        });
        AppRouter.open(context, WaiterHelperPage());
        return;
      }

      ShowToast.error(context, AppLocales.incorrectPincode.tr());
      pincodeChars = ['', '', '', ''];
      return setState(() {});
    }
  }

  void onDeletePressed() {
    for (int i = 0; i < pincodeChars.length; i++) {
      if (pincodeChars[pincodeChars.length - 1 - i].isNotEmpty) {
        pincodeChars[pincodeChars.length - 1 - i] = '';
        setState(() {});
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppStateWrapper(builder: (theme, state) {
      return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                showDesktopModal(context: context, body: IntroPage());
              },
            ),
            IconButton(
              icon: Icon(Icons.language_outlined),
              onPressed: () {
                showDesktopModal(context: context, body: EnterUrlScreen());
              },
            ),
            8.w,
          ],
        ),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppLocales.enterNewPincode.tr(),
                style: TextStyle(
                  fontFamily: boldFamily,
                  fontSize: 20,
                ),
              ),
              16.h,
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 16,
                children: List.generate(pincodeChars.length, (index) {
                  return Container(
                    height: 64,
                    width: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: pincodeChars[index].isEmpty ? theme.secondaryTextColor : theme.mainColor,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: AppText.$24Bold(pincodeChars[index]),
                    ),
                  );
                }),
              ),
              24.h,
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 16,
                children: [
                  buildNumberButton(onPressed: () => onPressedNumber("1"), number: "1", theme: theme),
                  buildNumberButton(onPressed: () => onPressedNumber("2"), number: "2", theme: theme),
                  buildNumberButton(onPressed: () => onPressedNumber("3"), number: "3", theme: theme),
                ],
              ),
              16.h,
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 16,
                children: [
                  buildNumberButton(onPressed: () => onPressedNumber("4"), number: "4", theme: theme),
                  buildNumberButton(onPressed: () => onPressedNumber("5"), number: "5", theme: theme),
                  buildNumberButton(onPressed: () => onPressedNumber("6"), number: "6", theme: theme),
                ],
              ),
              16.h,
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 16,
                children: [
                  buildNumberButton(onPressed: () => onPressedNumber("7"), number: "7", theme: theme),
                  buildNumberButton(onPressed: () => onPressedNumber("8"), number: "8", theme: theme),
                  buildNumberButton(onPressed: () => onPressedNumber("9"), number: "9", theme: theme),
                ],
              ),
              16.h,
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 16,
                children: [
                  buildNumberButton(onPressed: onDeletePressed, number: "9", icon: Icons.backspace_outlined, theme: theme),
                  buildNumberButton(onPressed: () => onPressedNumber("0"), number: "0", theme: theme),
                  buildNumberButton(
                    onPressed: () => onNextPressed(),
                    number: "Go",
                    icon: Icons.arrow_forward_ios_outlined,
                    primary: true,
                    theme: theme,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget buildNumberButton({
    required void Function() onPressed,
    required String number,
    IconData? icon,
    bool primary = false,
    required theme,
  }) =>
      SimpleButton(
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
