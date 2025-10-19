import 'package:biznex/src/core/config/router.dart';
import 'package:biznex/src/core/database/app_database/app_state_database.dart';
import 'package:biznex/src/providers/app_state_provider.dart';
import 'package:biznex/src/providers/employee_provider.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:biznex/src/ui/widgets/custom/app_toast.dart';
import 'package:biznex/src/ui/widgets/helpers/app_decorated_button.dart';
import 'package:biznex/src/ui/widgets/helpers/app_text_field.dart';

import '../../../../biznex.dart';

class ApiAddressScreen extends HookConsumerWidget {
  const ApiAddressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();
    return AppStateWrapper(builder: (theme, state) {
      return Column(
        spacing: 24,
        children: [
          AppTextField(
            prefixIcon: Icon(Icons.api_outlined),
            title: AppLocales.enterAddress.tr(),
            controller: controller,
            theme: theme,
          ),
          AppPrimaryButton(
            theme: theme,
            title: AppLocales.save.tr(),
            onPressed: () async {
              AppModel model = state;
              model.apiUrl = controller.text.trim();
              await AppStateDatabase().updateApp(model).then((_) {
                ref.invalidate(appStateProvider);
                if (context.mounted) {
                  AppRouter.close(context);
                  ShowToast.success(context, AppLocales.savedSuccessfully.tr());
                }

                ref.invalidate(employeeProvider);
                // AppRouter.open(context, OnB)
              });
            },
          ),
        ],
      );
    });
  }
}
