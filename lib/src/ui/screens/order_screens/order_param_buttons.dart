import 'package:biznex/biznex.dart';
import 'package:biznex/src/ui/widgets/custom/app_text_widgets.dart';
import 'package:biznex/src/ui/widgets/helpers/app_decorated_button.dart';

class OrderParamButtons extends ConsumerWidget {
  final AppColors theme;
  final AppModel state;
  final ValueNotifier<DateTime?> scheduleNotifier;
  final void Function()? onClearAll;
  final void Function() onScheduleOrder;
  final void Function() onOpenSettings;

  const OrderParamButtons({
    super.key,
    required this.theme,
    required this.scheduleNotifier,
    required this.state,
    this.onClearAll,
    required this.onScheduleOrder,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        16.h,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          spacing: 16,
          children: [
            Expanded(
              child: AppPrimaryButton(
                color: theme.mainColor.withOpacity(0.2),
                theme: theme,
                onPressed: onScheduleOrder,
                padding: Dis.only(lr: 16, tb: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 8,
                  children: [
                    Icon(Icons.schedule),
                    if (scheduleNotifier.value == null)
                      Expanded(
                        child: Text(
                          AppLocales.scheduleOrder.tr(),
                          style: TextStyle(fontFamily: boldFamily),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      )
                    else
                      AppText.$14Bold(
                        DateFormat('d-MMMM, HH:mm', context.locale.languageCode).format(scheduleNotifier.value!),
                      ),
                    if (scheduleNotifier.value != null) Spacer(),
                    if (scheduleNotifier.value != null)
                      IconButton(
                        onPressed: () => scheduleNotifier.value = null,
                        icon: Icon(Ionicons.close_circle_outline, color: Colors.red),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: AppPrimaryButton(
                color: theme.mainColor.withOpacity(0.2),
                theme: theme,
                onPressed: onOpenSettings,
                padding: Dis.only(lr: 16, tb: 12),
                child: Row(
                  spacing: 8,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Ionicons.settings_outline),
                    AppText.$14Bold(AppLocales.settings.tr()),
                  ],
                ),
              ),
            ),
          ],
        ),
        16.h,
        if (onClearAll != null)
          AppPrimaryButton(
            color: theme.red.withOpacity(0.1),
            theme: theme,
            onPressed: onClearAll!,
            padding: Dis.only(lr: 16, tb: 12),
            child: Row(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delete_outline, color: Colors.red),
                AppText.$14Bold(AppLocales.clearAll.tr(), style: TextStyle(fontFamily: boldFamily, color: Colors.red)),
              ],
            ),
          ),
      ],
    );
  }
}
