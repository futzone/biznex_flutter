import 'package:biznex/biznex.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class IngredientFoodScreen extends StatelessWidget {
  final List<ChartData> chartData;
  final String? measure;

  const IngredientFoodScreen(
      {super.key, this.measure, required this.chartData});

  @override
  Widget build(BuildContext context) {
    final theme = AppColors(isDark: false);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: theme.accentColor,
      ),
      child: Stack(
        children: [
          SfCircularChart(
            title: ChartTitle(
              text: AppLocales.ingredientFoodChartTitle.tr(),
              textStyle: TextStyle(fontFamily: boldFamily),
            ),
            tooltipBehavior: TooltipBehavior(
              enable: true,
              textStyle: TextStyle(fontFamily: mediumFamily),
            ),
            legend: Legend(
              toggleSeriesVisibility: true,
              title: LegendTitle(
                text: AppLocales.meals.tr(),
                textStyle: TextStyle(fontFamily: boldFamily, fontSize: 16),
              ),
              isVisible: true,
              position: LegendPosition.right,
              overflowMode: LegendItemOverflowMode.wrap,
              textStyle: TextStyle(
                fontFamily: mediumFamily,
                fontWeight: FontWeight.bold,
                color: theme.textColor,
              ),
            ),
            series: <CircularSeries>[
              // Render pie chart
              PieSeries<ChartData, String>(
                dataSource: chartData,
                pointColorMapper: (ChartData data, _) => data.color,
                xValueMapper: (ChartData data, _) => data.x,
                yValueMapper: (ChartData data, _) => data.y,
                dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  labelPosition: ChartDataLabelPosition.inside,
                  textStyle: TextStyle(
                    color: theme.textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                dataLabelMapper: (ChartData data, _) {
                  final percent = (data.y).toStringAsFixed(1);
                  return "${data.x}\n$percent ${measure ?? ''}";
                },
              )
            ],
          ),
          Positioned(
            bottom: 16,
            left: 16,
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

class ChartData {
  ChartData(this.x, this.y, [this.color]);

  final String x;
  final double y;
  final Color? color;
}
