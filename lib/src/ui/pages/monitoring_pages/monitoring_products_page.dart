import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/core/model/order_models/order_filter_model.dart';
import 'package:biznex/src/core/model/product_models/product_model.dart';
import 'package:biznex/src/providers/products_provider.dart';
import 'package:biznex/src/providers/app_state_provider.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:biznex/src/ui/widgets/helpers/app_loading_screen.dart';
import 'package:biznex/src/ui/widgets/custom/app_error_screen.dart';
import '../../widgets/helpers/app_back_button.dart';

class MonitoringProductsPage extends HookConsumerWidget {
  MonitoringProductsPage({super.key});

  final OrderFilterModel orderFilterModel = OrderFilterModel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startDate = useState(
      DateTime.now().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0),
    );
    final endDate = useState(
      DateTime.now().copyWith(hour: 23, minute: 59, second: 59),
    );

    return AppStateWrapper(builder: (theme, state) {
      return Column(
        children: [
          Row(
            children: [
              AppBackButton(),
              16.w,
              Text(
                AppLocales.products.tr(),
                style: TextStyle(
                    fontSize: context.s(24),
                    fontFamily: mediumFamily,
                    fontWeight: FontWeight.bold),
              ),
              Spacer(),
              16.w,
              SimpleButton(
                onPressed: () {
                  showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2025),
                    lastDate: DateTime.now(),
                  ).then((timeRange) {
                    if (timeRange == null) return;
                    startDate.value = timeRange.start;
                    endDate.value = timeRange.end;
                  });
                },
                child: Container(
                  padding: Dis.only(lr: context.w(16), tb: context.h(13)),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: theme.accentColor),
                  child: Row(
                    children: [
                      Text(
                        AppLocales.dateRange.tr(),
                        style:
                            TextStyle(fontFamily: mediumFamily, fontSize: 16),
                      ),
                      8.w,
                      Icon(Ionicons.calendar_outline, size: 20)
                    ],
                  ),
                ),
              ),
              16.w,
              SimpleButton(
                onLongPress: () {
                  final service = ProductMonitoringService(
                    startTime: startDate.value,
                    endTime: endDate.value,
                  );
                  service.printToCheck(ref);
                },
                onPressed: () {
                  final service = ProductMonitoringService(
                    startTime: startDate.value,
                    endTime: endDate.value,
                  );
                  service.saveToExcel();
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
              provider: productsProvider,
              builder: (products) {
                products as List<Product>;
                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return MonitoringProductCard(
                      product: products[index],
                      startDate: startDate.value,
                      endDate: endDate.value,
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

class MonitoringProductCard extends HookConsumerWidget {
  final Product product;
  final DateTime startDate;
  final DateTime endDate;

  const MonitoringProductCard({
    super.key,
    required this.product,
    required this.startDate,
    required this.endDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appModel = ref.watch(appStateProvider).value;
    final theme = AppColors(isDark: appModel?.isDark ?? false);
    final filter = useMemoized(
      () => ProductOrdersFilter(
        end: endDate,
        start: startDate,
        id: product.id,
      ),
      [endDate, startDate, product.id],
    );
    final providerListener = ref.watch(productOrdersProvider(filter));

    return providerListener.when(
      error: RefErrorScreen,
      loading: RefLoadingScreen,
      data: (productOrderData) {
        final ordersCount = productOrderData['count'];
        final totalAmount = productOrderData['amount'];
        return Container(
          margin: 16.bottom,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: theme.accentColor,
          ),
          padding: 18.all,
          child: Row(
            children: [
              Expanded(
                child: Row(
                  spacing: 8,
                  children: [
                    Icon(Iconsax.reserve, color: theme.mainColor),
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: boldFamily,
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 8,
                  children: [
                    Icon(Iconsax.coin_1, color: theme.mainColor),
                    Text(
                      product.price.priceUZS,
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 8,
                  children: [
                    Icon(Iconsax.bag, color: theme.mainColor),
                    Text(
                      "${AppLocales.orders.tr()}: $ordersCount",
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
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: 8,
                  children: [
                    Icon(Iconsax.wallet, color: theme.mainColor),
                    Text(
                      ((totalAmount ?? 0) * product.price).priceUZS,
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
        );
      },
    );
  }
}
