import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/config/router.dart';
import 'package:biznex/src/core/database/app_database/app_state_database.dart';
import 'package:biznex/src/core/extensions/for_string.dart';
import 'package:biznex/src/helper/screens/enter_url_screen.dart';
import 'package:biznex/src/providers/app_state_provider.dart';
import 'package:biznex/src/providers/employee_provider.dart';
import 'package:biznex/src/ui/pages/order_pages/employee_orders_page.dart';
import 'package:biznex/src/ui/screens/settings_screen/language_settings_screen.dart';
import 'package:biznex/src/ui/widgets/custom/app_file_image.dart';
import 'package:biznex/src/ui/widgets/dialogs/app_custom_dialog.dart';

import '../login_pages/onboard_page.dart';

class MobileDrawer extends HookConsumerWidget {
  final AppColors theme;

  const MobileDrawer(this.theme, {super.key});

  @override
  Widget build(BuildContext context, ref) {
    final employee = ref.watch(currentEmployeeProvider);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: theme.mainColor,
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                employee.fullname.initials,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: theme.mainColor,
                ),
              ),
            ),
            accountName: Text(
              employee.fullname,
              style: TextStyle(
                fontSize: 16,
                fontFamily: boldFamily,
                color: Colors.white,
              ),
            ),
            accountEmail: Text(
              employee.roleName,
              style: TextStyle(
                fontSize: 14,
                fontFamily: regularFamily,
                color: Colors.white,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: Text(AppLocales.orders.tr()),
            onTap: () {
              AppRouter.go(
                context,
                Scaffold(
                  body: EmployeeOrdersMobilePage(theme: theme),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(AppLocales.changeLanguage.tr()),
            onTap: () {
              showDesktopModal(
                context: context,
                body: AppLanguageBar(),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(AppLocales.logout.tr()),
            onTap: () {
              final state = ref.watch(appStateProvider).value!;
              state.apiUrl = null;
              AppStateDatabase().updateApp(state).then((_) {
                Future.delayed(Duration(seconds: 1));
                ref.refresh(appStateProvider);
                ref.invalidate(appStateProvider);
                ref.invalidate(employeeProvider);
                // ref.invalidate(appStateProvider);
              });
              // ref.read(currentEmployeeProvider.notifier).state = null;
              AppRouter.open(context, OnboardPage());
            },
          ),
        ],
      ),
    );
  }
}
