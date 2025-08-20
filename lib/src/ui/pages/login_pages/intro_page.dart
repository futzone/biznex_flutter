import 'package:biznex/biznex.dart';
import 'package:biznex/src/helper/pages/login_page.dart';
import 'package:biznex/src/ui/screens/sleep_screen/activity_wrapper.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:biznex/src/ui/widgets/helpers/app_decorated_button.dart';

import '../../../providers/license_status_provider.dart';

class IntroPage extends AppStatelessWidget {
  const IntroPage({super.key});

  @override
  Widget builder(BuildContext context, AppColors theme, WidgetRef ref, AppModel state) {
    if (state.baseUrl.isEmpty) return _IntroPage();
    if (state.isServerApp) return ActivityWrapper(ref: ref, child: LicenseStatusWrapper());
    return HelperLoginPage();
  }
}

class _IntroPage extends HookConsumerWidget {
  const _IntroPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppStateWrapper(builder: (theme, state) {
      return Scaffold(
        body: Center(
          child: Column(
            spacing: 24,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppPrimaryButton(theme: theme, onPressed: () {}),
              AppPrimaryButton(theme: theme, onPressed: () {}),
            ],
          ),
        ),
      );
    });
  }
}
