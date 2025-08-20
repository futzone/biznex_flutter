import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/services/license_services.dart';
import 'package:biznex/src/ui/pages/login_pages/login_page.dart';
import 'package:biznex/src/ui/pages/login_pages/onboard_page.dart';
import 'package:biznex/src/ui/screens/activation_screens/activation_screen.dart';
import 'package:biznex/src/ui/screens/sleep_screen/activity_wrapper.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';

final licenseStatusProvider = FutureProvider.family((ref, String key) async {
  LicenseServices licenseServices = LicenseServices();

  return await licenseServices.verifyLicense(key);
});

class LicenseStatusWrapper extends ConsumerWidget {
  const LicenseStatusWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppStateWrapper(builder: (theme, state) {
      return state.whenProviderData(
        provider: licenseStatusProvider(state.licenseKey),
        builder: (status) {
          status as bool;
          if (status) {
            return state.pincode.isEmpty ? LoginPageHarom(model: state, theme: theme, fromAdmin: true) : OnboardPage();
          }

          return ActivationScreen(state: state, theme: theme);
        },
      );
    });
  }
}
