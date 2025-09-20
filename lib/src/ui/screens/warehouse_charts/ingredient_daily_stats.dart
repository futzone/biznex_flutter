import 'package:biznex/src/core/model/ingredient_models/ingredient_model.dart';
import 'package:biznex/src/core/model/product_models/ingredient_model.dart';
import 'package:biznex/src/core/utils/date_utils.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../biznex.dart';

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
              intervalType: DateTimeIntervalType.days,
              dateFormat: DateFormat('dd-MMMM', context.locale.languageCode),
              title: AxisTitle(text: AppLocales.days.tr()),
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
              onPressed: () {},
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
