import 'dart:developer';

import 'package:biznex/src/controllers/cache_controller.dart';
import 'package:biznex/src/core/config/router.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:biznex/src/ui/widgets/custom/app_text_widgets.dart';
import 'package:biznex/src/ui/widgets/helpers/app_decorated_button.dart';

import '../../../../biznex.dart';

class CacheSettingsScreen extends HookConsumerWidget {
  const CacheSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final databasesList = [
      "all",
      "orders",
      "transactions",
      "shopping",
      "ingredientTransactions",
      "products",
      "ingredients",
      "recipe",
      "employees",
      "places",
      "categories"
    ];
    final databases = useState(<String>[]);
    return AppStateWrapper(builder: (theme, state) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            spacing: 12,
            children: [
              SimpleButton(
                child: Icon(Icons.close),
                onPressed: () => AppRouter.close(context),
              ),
              AppText.$18Bold(AppLocales.clearCache.tr()),
            ],
          ),
          12.h,
          Text(
            AppLocales.clearCacheWarningText.tr(),
            style: TextStyle(
              color: theme.secondaryTextColor,
              fontFamily: regularFamily,
            ),
          ),
          16.h,
          AppText.$16Bold(AppLocales.selectDatabase.tr()),
          16.h,
          Wrap(
            runSpacing: 16,
            spacing: 16,
            children: [
              for (final item in databasesList)
                ChoiceChip(
                  checkmarkColor: theme.white,
                  backgroundColor: theme.accentColor,
                  selectedColor: theme.mainColor,
                  onSelected: (val) {
                    if (val && item == 'all') {
                      databases.value = [...databasesList];
                      return;
                    }

                    if (!val && item == 'all') {
                      databases.value = [];
                      return;
                    }

                    if (val) {
                      databases.value.remove(item);
                      databases.value = [...databases.value, item];
                    } else {
                      databases.value.remove(item);
                      databases.value = [...databases.value];
                    }

                    log("${databases.value}");
                  },
                  label: Text(
                    item.tr(),
                    style: TextStyle(
                      color: databases.value.contains(item)
                          ? theme.white
                          : theme.textColor,
                    ),
                  ),
                  selected: databases.value.contains(item),
                ),
            ],
          ),
          32.h,
          if (databases.value.isNotEmpty)
            ConfirmCancelButton(
              onConfirm: () {
                final CacheController cacheC = CacheController(context, ref);
                cacheC.onClearCollections(databases.value);
              },
              confirmIcon: Icons.cleaning_services_rounded,
              confirmText: AppLocales.clear.tr(),
            ),
        ],
      );
    });
  }
}
