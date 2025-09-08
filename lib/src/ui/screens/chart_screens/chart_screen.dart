import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/model/other_models/chart_sample_data.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartScreen2 extends StatefulWidget {
  const ChartScreen2({super.key});

  @override
  State<ChartScreen2> createState() => _ChartScreen2State();
}

class _ChartScreen2State extends State<ChartScreen2> {
  List<ChartSampleData>? _chartData;
  late double _columnWidth;
  late double _columnSpacing;
  TooltipBehavior? _tooltipBehavior;

  @override
  void initState() {
    _chartData = <ChartSampleData>[
      ChartSampleData(
        x: 'Product A',
        y: 16,
        secondSeriesYValue: 8,
        thirdSeriesYValue: 13,
      ),
      ChartSampleData(
        x: 'Product B',
        y: 8,
        secondSeriesYValue: 10,
        thirdSeriesYValue: 7,
      ),
      ChartSampleData(
        x: 'Product C',
        y: 12,
        secondSeriesYValue: 10,
        thirdSeriesYValue: 5,
      ),
      ChartSampleData(
        x: 'Product D',
        y: 4,
        secondSeriesYValue: 8,
        thirdSeriesYValue: 14,
      ),
      ChartSampleData(
        x: 'Product E',
        y: 8,
        secondSeriesYValue: 5,
        thirdSeriesYValue: 4,
      ),
    ];
    _columnWidth = 0.8;
    _columnSpacing = 0.2;
    _tooltipBehavior = TooltipBehavior(enable: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildCartesianChart();
  }

  /// Return the Cartesian Chart with Column series.
  SfCartesianChart _buildCartesianChart() {
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      title: ChartTitle(text: "Eng ko'p sotilayotgan mahsulotlar"),
      primaryXAxis: const CategoryAxis(
        majorGridLines: MajorGridLines(width: 0),
      ),
      primaryYAxis: const NumericAxis(
        maximum: 20,
        minimum: 0,
        interval: 4,
        axisLine: AxisLine(width: 0),
        majorTickLines: MajorTickLines(size: 0),
      ),
      series: _buildColumnSeries(),
      legend: Legend(isVisible: true),
      tooltipBehavior: _tooltipBehavior,
    );
  }

  /// Returns the list of Cartesian Column series.
  List<ColumnSeries<ChartSampleData, String>> _buildColumnSeries() {
    return <ColumnSeries<ChartSampleData, String>>[
      ColumnSeries<ChartSampleData, String>(
        dataSource: _chartData,
        xValueMapper: (ChartSampleData sales, int index) => sales.x,
        yValueMapper: (ChartSampleData sales, int index) => sales.y,
        width: _columnWidth,
        spacing: _columnSpacing,
        color: const Color.fromRGBO(251, 193, 55, 1),
        name: 'Gold',
      ),
      ColumnSeries<ChartSampleData, String>(
        dataSource: _chartData,
        xValueMapper: (ChartSampleData sales, int index) => sales.x,
        yValueMapper: (ChartSampleData sales, int index) => sales.secondSeriesYValue,
        width: _columnWidth,
        spacing: _columnSpacing,
        color: const Color.fromRGBO(177, 183, 188, 1),
        name: 'Silver',
      ),
      ColumnSeries<ChartSampleData, String>(
        dataSource: _chartData,
        xValueMapper: (ChartSampleData sales, int index) => sales.x,
        yValueMapper: (ChartSampleData sales, int index) => sales.thirdSeriesYValue,
        width: _columnWidth,
        spacing: _columnSpacing,
        color: const Color.fromRGBO(140, 92, 69, 1),
        name: 'Bronze',
      ),
    ];
  }

  @override
  void dispose() {
    _chartData!.clear();
    super.dispose();
  }
}
