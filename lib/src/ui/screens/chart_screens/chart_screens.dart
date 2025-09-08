import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartScreen1 extends StatefulWidget {
  const ChartScreen1({super.key});

  @override
  State<ChartScreen1> createState() => _ChartScreen1State();
}

class _ChartScreen1State extends State<ChartScreen1> {
  List<_ChartData>? _chartData;
  TooltipBehavior? _tooltipBehavior;

  @override
  void initState() {
    _chartData = <_ChartData>[
      _ChartData(21, 21, 28),
      _ChartData(22, 24, 44),
      _ChartData(23, 36, 48),
      _ChartData(24, 38, 50),
      _ChartData(25, 54, 66),
      _ChartData(26, 57, 78),
      _ChartData(27, 70, 84),
    ];
    _tooltipBehavior = TooltipBehavior(enable: true);
    super.initState();
  }

  @override
  void dispose() {
    _chartData!.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildCartesianChart();
  }

  SfCartesianChart _buildCartesianChart() {
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      title: ChartTitle(text: 'Kunlik Sotuvlar'),
      primaryXAxis: const NumericAxis(
        edgeLabelPlacement: EdgeLabelPlacement.shift,
        interval: 2,
        majorGridLines: MajorGridLines(width: 0),
      ),
      primaryYAxis: const NumericAxis(
        labelFormat: '{value}%',
        axisLine: AxisLine(width: 0),
        majorTickLines: MajorTickLines(color: Colors.transparent),
      ),
      series: _buildLineSeries(),
      legend: Legend(
        isVisible: true,
        overflowMode: LegendItemOverflowMode.wrap,
      ),
      tooltipBehavior: _tooltipBehavior,
    );
  }

  /// Returns the list of Cartesian Line series.
  List<LineSeries<_ChartData, num>> _buildLineSeries() {
    return <LineSeries<_ChartData, num>>[
      LineSeries<_ChartData, num>(
        dataSource: _chartData,
        xValueMapper: (_ChartData sales, int index) => sales.x,
        yValueMapper: (_ChartData sales, int index) => sales.y,
        name: 'Online',
        markerSettings: const MarkerSettings(isVisible: true),
      ),
      LineSeries<_ChartData, num>(
        dataSource: _chartData,
        name: 'Offline',
        xValueMapper: (_ChartData sales, int index) => sales.x,
        yValueMapper: (_ChartData sales, int index) => sales.y2,
        markerSettings: const MarkerSettings(isVisible: true),
      ),
    ];
  }
}

class _ChartData {
  _ChartData(this.x, this.y, this.y2);

  final double x;
  final double y;
  final double y2;
}
