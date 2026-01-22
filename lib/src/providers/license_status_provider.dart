import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/services/license_services.dart';
import 'package:biznex/src/ui/pages/login_pages/onboard_page.dart';

final licenseStatusProvider = FutureProvider.family((ref, String key) async {
  LicenseServices licenseServices = LicenseServices();

  return await licenseServices.verifyLicense(key);
});

Future<bool> verifyLicense(String key) async {
  LicenseServices licenseServices = LicenseServices();

  return await licenseServices.verifyLicense(key);
}

class LicenseStatusWrapper extends ConsumerWidget {
  const LicenseStatusWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OnboardPage();
  }
}