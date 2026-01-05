import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/cloud/cloud_services.dart';
import 'package:biznex/src/core/database/app_database/app_state_database.dart';
import 'package:biznex/src/core/services/license_services.dart';
import 'package:biznex/src/ui/pages/login_pages/login_page.dart';
import 'package:biznex/src/ui/pages/login_pages/onboard_page.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import '../ui/screens/activation_screens/activation_code_screen.dart';

final licenseStatusProvider = FutureProvider((ref) async {
  // final AppStateDatabase stateDatabase = AppStateDatabase();
  // final state = await stateDatabase.getApp();

  final BiznexCloudServices cloudServices = BiznexCloudServices();
  final token = await cloudServices.getTokenData();
  return token != null;

  // return await verifyLicense(state.licenseKey);
});

Future<bool> verifyLicense(String key) async {
  final BiznexCloudServices cloudServices = BiznexCloudServices();
  final token = await cloudServices.getTokenData();
  return token != null;
}

class LicenseStatusWrapper extends ConsumerWidget {
  const LicenseStatusWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppStateWrapper(builder: (theme, state) {
      return state.whenProviderData(
        provider: licenseStatusProvider,
        builder: (status) {
          status as bool;

          if (status) {
            if (state.alwaysWaiter) {
              return OnboardPage();
            }

            return state.pincode.isEmpty
                ? LoginPageHarom(model: state, theme: theme, fromAdmin: true)
                : OnboardPage();
          }

          return ActivationCodeScreen(ref: ref, state: state);
        },
      );
    });
  }
}
