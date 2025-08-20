import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/config/router.dart';
import 'package:biznex/src/core/database/url_database/url_database.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:biznex/src/ui/widgets/helpers/app_decorated_button.dart';
import 'package:biznex/src/ui/widgets/helpers/app_text_field.dart';

class EnterUrlScreen extends HookConsumerWidget {
  const EnterUrlScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();
    return AppStateWrapper(
      builder: (theme, state) => SingleChildScrollView(
        child: Column(
          children: [
            AppTextField(
              title: AppLocales.enterAddress.tr(),
              controller: controller,
              theme: theme,
            ),
            16.h,
            ConfirmCancelButton(
              confirmText: AppLocales.save.tr(),
              cancelText: AppLocales.close.tr(),
              onConfirm: () async {
                if (controller.text.trim().isNotEmpty) {
                  UrlDatabase urlDatabase = UrlDatabase();
                  await urlDatabase.set(data: controller.text.trim());
                }

                AppRouter.close(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
