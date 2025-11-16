import 'package:biznex/src/core/database/isar_database/isar.dart';
import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/core/model/order_models/order.dart';
import 'package:biznex/src/core/utils/date_utils.dart';
import 'package:biznex/src/ui/widgets/custom/app_error_screen.dart';
import 'package:biznex/src/ui/widgets/helpers/app_loading_screen.dart';
import 'package:isar/isar.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../../biznex.dart';

final _weeklyDataProvider = FutureProvider((ref) async {
  final Isar isar = IsarDatabase.instance.isar;
  final days = AppDateUtils().last7Days();
  final Map<String, dynamic> data = {};
  for (final day in days) {
    final prefix = day.toIso8601String().split('T').first;
    final summ = await isar.orderIsars
        .where()
        .filter()
        .createdDateStartsWith(prefix)
        .priceProperty()
        .sum();

    data[prefix] = summ;
  }

  return data;
});

class WeeklyChartItem {
  final String day;
  final double value;

  WeeklyChartItem(this.day, this.value);
}

class MonitoringChartScreen extends ConsumerWidget {
  const MonitoringChartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(_weeklyDataProvider);

    return asyncData.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Xatolik: $e')),
      data: (map) {
        final List<WeeklyChartItem> chartData = map.entries.map((e) {
          return WeeklyChartItem(
            e.key,
            (e.value ?? 0.0) * 1.0,
          );
        }).toList();

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          margin: Dis.only(lr: context.w(24), bottom: 24),
          padding: context.s(24).all,
          child: SfCartesianChart(
            primaryXAxis: CategoryAxis(
              labelStyle:
                  TextStyle(color: Colors.black, fontFamily: boldFamily),
            ),
            title: ChartTitle(
              text: AppLocales.ordersStats.tr(),
              alignment: ChartAlignment.center,

            ),
            primaryYAxis: NumericAxis(
              title: AxisTitle(text: AppLocales.totalOrderSumm.tr()),
              numberFormat: NumberFormat.currency(
                locale:
                    'uz_UZ',
                symbol: 'UZS',
                decimalDigits: 0,
              ),

              labelStyle: TextStyle(color: Colors.black, fontFamily: boldFamily),
            ),
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <CartesianSeries>[
              SplineAreaSeries<WeeklyChartItem, String>(
                dataSource: chartData,
                xValueMapper: (item, _) =>
                    DateFormat("dd-MMMM", context.locale.languageCode)
                        .format(DateTime.parse(item.day)),
                yValueMapper: (item, _) => item.value,
                opacity: 0.5,
              ),
            ],
          ),
        );
      },
    );
  }
}
