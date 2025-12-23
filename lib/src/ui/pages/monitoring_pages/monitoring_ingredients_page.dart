import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/config/router.dart';
import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/core/model/excel_models/orders_excel_model.dart';
import 'package:biznex/src/core/model/ingredient_models/ingredient_model.dart';
import 'package:biznex/src/core/model/product_models/ingredient_model.dart';
import 'package:biznex/src/core/services/warehouse_printer_services.dart';
import 'package:biznex/src/core/utils/date_utils.dart';
import 'package:biznex/src/providers/recipe_providers.dart';
import 'package:biznex/src/ui/widgets/custom/app_custom_popup_menu.dart';
import 'package:biznex/src/ui/widgets/custom/app_error_screen.dart';
import 'package:biznex/src/ui/widgets/custom/app_loading.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:biznex/src/ui/widgets/dialogs/app_custom_dialog.dart';
import 'package:biznex/src/ui/widgets/helpers/app_loading_screen.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../screens/warehouse_charts/ingredient_charts_screen.dart';
import '../../widgets/helpers/app_back_button.dart';

class MonitoringIngredientsPage extends HookConsumerWidget {
  const MonitoringIngredientsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startDate = useState(
      DateTime.now().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0),
    );

    final endDate = useState(
      DateTime.now().copyWith(hour: 23, minute: 59, second: 59),
    );

    final ingredientService = useMemoized(
      () => IngredientTransactionsService(
        startDate.value,
        endDate.value,
      ),
      [startDate.value, endDate.value],
    );

    return AppStateWrapper(builder: (theme, state) {
      return Column(
        children: [
          Row(
            children: [
              AppBackButton(),
              16.w,
              Text(
                AppLocales.ingredients.tr(),
                style: TextStyle(
                  fontSize: context.s(24),
                  fontFamily: mediumFamily,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              SimpleButton(
                onPressed: () async {
                  await ingredientService.printToCheck(ref);
                },
                child: Container(
                  padding: Dis.only(lr: context.w(16), tb: context.h(13)),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: theme.accentColor,
                  ),
                  child: Row(
                    children: [
                      Text(
                        AppLocales.print.tr(),
                        style: TextStyle(
                          fontFamily: mediumFamily,
                          fontSize: 16,
                        ),
                      ),
                      8.w,
                      Icon(Iconsax.printer_copy, size: 20)
                    ],
                  ),
                ),
              ),
              16.w,
              SimpleButton(
                onPressed: () {
                  showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2025),
                    lastDate: DateTime.now(),
                  ).then((value) {
                    if (value == null) return;
                    startDate.value = value.start;
                    endDate.value = value.end;
                  });
                },
                child: Container(
                  padding: Dis.only(lr: context.w(16), tb: context.h(13)),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: theme.accentColor),
                  child: Row(
                    children: [
                      Icon(Iconsax.calendar_1_copy, size: 20),
                      8.w,
                      Text(AppLocales.dateRange.tr()),
                    ],
                  ),
                ),
              ),
              16.w,
              SimpleButton(
                onPressed: () async {
                  showAppLoadingDialog(context);
                  ingredientService.saveToExcel().then((_) {
                    AppRouter.close(context);
                  });
                },
                child: Container(
                  padding: Dis.only(lr: context.w(16), tb: context.h(13)),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: theme.mainColor),
                  child: Row(
                    children: [
                      Text(
                        AppLocales.export.tr(),
                        style: TextStyle(
                            fontFamily: mediumFamily,
                            fontSize: 16,
                            color: Colors.white),
                      ),
                      8.w,
                      Icon(Iconsax.document_download,
                          size: 20, color: Colors.white)
                    ],
                  ),
                ),
              ),
            ],
          ),
          16.h,
          Expanded(
            child: state.whenProviderData(
              provider: ingredientsProvider,
              builder: (orders) {
                orders as List<Ingredient>;

                return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final ingredient = orders[index];
                    return ref
                        .watch(ingredientService.provider(ingredient.id))
                        .when(
                          error: RefErrorScreen,
                          loading: RefLoadingScreen,
                          data: (data) {
                            final amounts = data['amount'] as double;

                            final totalPrice =
                                amounts * (ingredient.unitPrice ?? 0.0);

                            final transactions =
                                data['data'] as List<IngredientTransaction>;

                            return SimpleButton(
                              onPressed: () {
                                showDesktopModal(
                                  context: context,
                                  body: IngredientChartsScreen(
                                    transactions: transactions,
                                    ingredient: ingredient,
                                  ),
                                );
                              },
                              child: Container(
                                margin: 16.bottom,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: theme.accentColor,
                                ),
                                padding: 16.all,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        spacing: 8,
                                        children: [
                                          Icon(
                                            Icons.set_meal,
                                            color: theme.mainColor,
                                          ),
                                          Text(
                                            ingredient.name,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontFamily: boldFamily,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        spacing: 8,
                                        children: [
                                          Icon(Iconsax.bag,
                                              color: theme.mainColor),
                                          Text(
                                            "${AppLocales.usage.tr()}: ${amounts.toMeasure} ${ingredient.measure ?? ''}",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontFamily: boldFamily,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        spacing: 8,
                                        children: [
                                          Icon(
                                            Iconsax.wallet_1,
                                            color: theme.mainColor,
                                          ),
                                          Text(
                                            "${AppLocales.unitPrice.tr()}: ",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontFamily: regularFamily,
                                            ),
                                          ),
                                          Text(
                                            (ingredient.unitPrice ?? 0.0)
                                                .priceUZS,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontFamily: boldFamily,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        spacing: 8,
                                        children: [
                                          Icon(Iconsax.wallet,
                                              color: theme.mainColor),
                                          Text(
                                            "${AppLocales.total.tr()}: ",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontFamily: regularFamily,
                                            ),
                                          ),
                                          Text(
                                            totalPrice.priceUZS,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontFamily: boldFamily,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                  },
                );
              },
            ),
          ),
        ],
      );
    });
  }
}
