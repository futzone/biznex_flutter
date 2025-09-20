import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/config/router.dart';
import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/core/model/excel_models/orders_excel_model.dart';
import 'package:biznex/src/core/model/product_models/ingredient_model.dart';
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
    final selectedMonth = useState<int>(DateTime.now().month);
    final filterType = useState<int>(DateTime.now().year);

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
              CustomPopupMenu(
                theme: theme,
                children: [
                  for (final item in [
                    DateTime.now().year - 1,
                    DateTime.now().year,
                    DateTime.now().year + 1
                  ])
                    CustomPopupItem(
                      title: item.toString(),
                      onPressed: () {
                        filterType.value = item;
                      },
                    ),
                ],
                child: Container(
                  padding: Dis.only(lr: context.w(16), tb: context.h(13)),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: theme.accentColor),
                  child: Row(
                    children: [
                      Text(
                        filterType.value.toString(),
                        style: TextStyle(
                          fontFamily: mediumFamily,
                          fontSize: 16,
                        ),
                      ),
                      8.w,
                      Icon(Iconsax.arrow_down_1_copy, size: 20)
                    ],
                  ),
                ),
              ),
              16.w,
              CustomPopupMenu(
                theme: theme,
                children: [
                  for (int i = 1; i < 13; i++)
                    CustomPopupItem(
                      title: AppDateUtils.getMonth(i),
                      onPressed: () {
                        selectedMonth.value = i;
                      },
                    ),
                ],
                child: Container(
                  padding: Dis.only(lr: context.w(16), tb: context.h(13)),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: theme.accentColor),
                  child: Row(
                    children: [
                      Text(
                        AppDateUtils.getMonth(selectedMonth.value),
                        style:
                            TextStyle(fontFamily: mediumFamily, fontSize: 16),
                      ),
                      8.w,
                      Icon(Iconsax.arrow_down_1_copy, size: 20)
                    ],
                  ),
                ),
              ),
              16.w,
              SimpleButton(
                onPressed: () {
                  showAppLoadingDialog(context);
                  final orders = ref.watch(ingredientsProvider).value ?? [];
                  final List<OrdersExcelModel> list = [];
                  for (final day in AppDateUtils.getAllDaysInMonth(
                      filterType.value, selectedMonth.value)) {
                    final double ordersSumm =
                        orders.fold(0.0, (value, element) {
                      final createdDate = element.createdAt;

                      if (createdDate.year == day.year &&
                          createdDate.month == day.month &&
                          createdDate.day == day.day) {
                        return value += element.unitPrice ?? 0.0;
                      }
                      return value;
                    });

                    final int ordersCount = orders.fold(0, (value, element) {
                      final createdDate = element.createdAt;

                      if (createdDate.year == day.year &&
                          createdDate.month == day.month &&
                          createdDate.day == day.day) {
                        return value += 1;
                      }
                      return value;
                    });

                    OrdersExcelModel excel = OrdersExcelModel(
                      ordersCount: ordersCount,
                      ordersSumm: ordersSumm,
                      dateTime: DateFormat(
                              'd-MMMM, yyyy', context.locale.languageCode)
                          .format(day),
                      day: DateFormat('EEEE', context.locale.languageCode)
                          .format(day),
                    );

                    list.add(excel);
                  }
                  AppRouter.close(context);

                  OrdersExcelModel.saveFileDialog(list);
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
                        .watch(ingredientTransactionsProvider(ingredient.id))
                        .when(
                          error: RefErrorScreen,
                          loading: RefLoadingScreen,
                          data: (transactions) {
                            final amounts = transactions.fold(0.0, (a, b) {
                              final created = DateTime.parse(b.createdDate);
                              if (created.month == selectedMonth.value &&
                                  created.year == filterType.value) {
                                return a += b.amount;
                              }

                              return a;
                            });

                            final totalPrice =
                                amounts * (ingredient.unitPrice ?? 0.0);

                            return Container(
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
                                          MainAxisAlignment.center,
                                      spacing: 8,
                                      children: [
                                        Icon(Iconsax.wallet,
                                            color: theme.mainColor),
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
                                  SimpleButton(
                                    onPressed: () {
                                      showDesktopModal(
                                        context: context,
                                        body: IngredientChartsScreen(
                                          transactions: transactions,
                                          ingredient: ingredient,
                                        ),
                                      );
                                    },
                                    child: Row(
                                      spacing: 8,
                                      children: [
                                        Icon(
                                          Ionicons.bar_chart_outline,
                                          color: theme.mainColor,
                                        ),
                                        Icon(
                                          Ionicons.arrow_forward,
                                          size: 20,
                                          color: theme.secondaryTextColor,
                                        )
                                      ],
                                    ),
                                  ),
                                ],
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
