import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

final formatter = NumberFormat('#,##,000');

class CustomLineChart extends StatefulWidget {
  const CustomLineChart({super.key, required this.lineChartData});

  final Map<double, double> lineChartData;

  @override
  State<CustomLineChart> createState() => _CustomLineChartState();
}

class _CustomLineChartState extends State<CustomLineChart> {
  List<Color> gradientColors = [
    const Color.fromARGB(255, 163, 244, 199),
    const Color.fromARGB(255, 33, 243, 93)
    // const Color(0xFF50E4FF),
    // const Color(0xFF2196F3)
  ];

  int getTotalExpense(Map<double, double> expenses) {
    return expenses.values
        .toList()
        .reduce((value, element) => value + element)
        .ceil();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'EXPENSES THIS MONTH',
          style: TextStyle(color: Colors.black38),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          '₹${formatter.format(getTotalExpense(widget.lineChartData))}',
          style: Theme.of(context).textTheme.displaySmall!.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              letterSpacing: 2),
        ),
        const SizedBox(
          height: 10,
        ),
        Stack(
          children: <Widget>[
            SizedBox(
              height: 600,
              child: Card(
                elevation: 2,
                color: Colors.black87,
                child: AspectRatio(
                  aspectRatio: 1.70,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      right: 18,
                      left: 12,
                      top: 24,
                      bottom: 12,
                    ),
                    child: LineChart(
                      mainData(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    TextStyle style = Theme.of(context).textTheme.labelLarge!.copyWith(
        fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white);
    Widget text;

    if (value == 0.0) {
      text = Text('', style: style);
    } else {
      text = Text('${value.toInt()}', style: style);
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    TextStyle style = Theme.of(context).textTheme.labelLarge!.copyWith(
        fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white);

    if (value == 0.0) return Container();
    return Text('${value.toInt()}', style: style, textAlign: TextAlign.left);
  }

  LineChartData mainData() {
    final List<FlSpot> chartPoints = [];
    List<int> monthDays = List.generate(30, (index) => index + 1);
    final keys = widget.lineChartData.keys.toList();
    keys.sort();
    for (var i in monthDays) {
      if (keys.contains(i)) {
        chartPoints.add(FlSpot(i / 1, widget.lineChartData[i]! / 1));
      } else if (i < DateTime.now().day) {
        chartPoints.add(FlSpot(i / 1, 0));
      }
    }

    return LineChartData(
      gridData: FlGridData(
        show: false,
        drawVerticalLine: false,
        // horizontalInterval: 3,
        // verticalInterval: maxTransactionValue / 10,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Colors.white10,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Colors.white10,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          axisNameWidget: const Text(
            'Days',
            style: TextStyle(color: Colors.white),
          ),
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            // interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          axisNameWidget: const Text(
            'Amount',
            style: TextStyle(color: Colors.white),
          ),
          sideTitles: SideTitles(
            showTitles: false,
            // interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
        // border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 30,
      // minY: 0,
      // maxY: 10,
      lineBarsData: [
        LineChartBarData(
          spots: chartPoints,
          isCurved: true,
          preventCurveOverShooting: true,
          preventCurveOvershootingThreshold: 0.35,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}
