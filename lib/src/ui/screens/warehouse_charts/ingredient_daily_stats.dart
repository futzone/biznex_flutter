import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../biznex.dart';

class IngredientDailyStats extends StatelessWidget {
  const IngredientDailyStats({super.key});

  @override
  Widget build(BuildContext context) {
    final List<SalesData> salesData = [
      SalesData(DateTime(2025, 9, 10), 30),
      SalesData(DateTime(2025, 9, 11), 42),
      SalesData(DateTime(2025, 9, 12), 55),
      SalesData(DateTime(2025, 9, 13), 28),
      SalesData(DateTime(2025, 9, 14), 70),
      SalesData(DateTime(2025, 9, 15), 90),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Mahsulot kunlik sotuvi")),
      body: Center(
        child: SfCartesianChart(
          primaryXAxis: DateTimeAxis(
            intervalType: DateTimeIntervalType.days,
            dateFormat: DateFormat.Md(),
            title: AxisTitle(text: "Kunlar"),
          ),
          primaryYAxis: NumericAxis(
            title: AxisTitle(text: "Sotuvlar soni"),
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
              name: "Sotuvlar",
            ),
          ],
        ),
      ),
    );
  }
}

class SalesData {
  SalesData(this.date, this.sales);

  final DateTime date;
  final double sales;
}
