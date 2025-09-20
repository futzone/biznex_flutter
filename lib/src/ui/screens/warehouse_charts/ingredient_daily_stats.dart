import 'package:biznex/src/core/model/ingredient_models/ingredient_model.dart';
import 'package:biznex/src/core/model/product_models/ingredient_model.dart';
import 'package:biznex/src/core/services/warehouse_printer_services.dart';
import 'package:biznex/src/core/utils/date_utils.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../biznex.dart';
import 'ingredient_food_screen.dart';

class IngredientDailyStats extends StatelessWidget {
  final Ingredient ingredient;
  final List<SalesData> salesData;
  final bool shopping;

  const IngredientDailyStats({
    super.key,
    required this.ingredient,
    required this.salesData,
    this.shopping = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppColors(isDark: false);

    return Container(
      padding: Dis.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: theme.accentColor,
      ),
      child: Stack(
        children: [
          SfCartesianChart(
            primaryXAxis: DateTimeAxis(
              labelAlignment: LabelAlignment.start,
              intervalType: DateTimeIntervalType.days,
              dateFormat: DateFormat('dd-MMMM', context.locale.languageCode),
              title: AxisTitle(text: AppLocales.days.tr()),
              // tickPosition: TickPosition.inside,
            ),
            primaryYAxis: NumericAxis(
              title: AxisTitle(
                text:
                    shopping ? AppLocales.shopping.tr() : AppLocales.usage.tr(),
              ),
            ),
            tooltipBehavior: TooltipBehavior(enable: true),
            series: [
              LineSeries<SalesData, DateTime>(
                dataSource: salesData,
                xValueMapper: (SalesData data, _) => data.date,
                yValueMapper: (SalesData data, _) => data.sales,
                markerSettings: const MarkerSettings(
                  isVisible: true,
                ),
                dataLabelSettings: const DataLabelSettings(isVisible: true),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: ElevatedButton.icon(
              onPressed: () {
                WarehousePrinterServices.ingredientUsagePrint(
                  ingredient: ingredient,
                  data: [
                    for (final item in salesData)
                      ChartData(
                        DateFormat("yyyy, dd-MMMM", context.locale.languageCode)
                            .format(item.date),
                        item.sales,
                      ),
                  ],
                  shopping: shopping,
                );
              },
              icon: Icon(Ionicons.print_outline),
              label: Text(AppLocales.print.tr()),
              // child: Text("print"),
            ),
          ),
        ],
      ),
    );
  }
}

class SalesData {
  SalesData(this.date, this.sales);

  final DateTime date;
  final double sales;
}
