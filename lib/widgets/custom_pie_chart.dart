import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class PieChartSample3 extends StatefulWidget {
  const PieChartSample3({super.key, required this.pieChartData});

  final List<Map<String, dynamic>> pieChartData;

  @override
  State<StatefulWidget> createState() => PieChartSample3State();
}

class PieChartSample3State extends State<PieChartSample3> {
  int touchedIndex = 0;
  final appColors = [
    const Color.fromARGB(50, 150, 200, 90),
    const Color.fromARGB(149, 93, 222, 114),
    const Color.fromARGB(30, 160, 220, 80),
    const Color.fromARGB(200, 20, 180, 85),
    const Color.fromARGB(80, 50, 240, 90),
    const Color.fromARGB(150, 20, 220, 80),
    const Color.fromARGB(50, 150, 250, 80),
  ];

  double getTotalExpense(List<Map<String, dynamic>> pieChartData) {
    print(pieChartData.toString());
    double totalAmount = 0.0;
    for (var element in pieChartData) {
      print(element['categoryTotal']);
      totalAmount += element['categoryTotal'];
    }
    print(totalAmount);
    return totalAmount;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: AspectRatio(
        aspectRatio: 1,
        child: PieChart(
          PieChartData(
            pieTouchData: PieTouchData(
              touchCallback: (FlTouchEvent event, pieTouchResponse) {
                setState(() {
                  if (!event.isInterestedForInteractions ||
                      pieTouchResponse == null ||
                      pieTouchResponse.touchedSection == null) {
                    touchedIndex = -1;
                    return;
                  }
                  touchedIndex =
                      pieTouchResponse.touchedSection!.touchedSectionIndex;
                });
              },
            ),
            borderData: FlBorderData(
              show: false,
            ),
            sectionsSpace: 0,
            centerSpaceRadius: 0,
            sections: showingSections(),
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    final totalAmount = getTotalExpense(widget.pieChartData);
    print(totalAmount);
    return widget.pieChartData
        .asMap()
        .entries
        .map<PieChartSectionData>((entry) {
      int i = entry.key;
      Map<String, dynamic> data = entry.value;
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 20.0 : 16.0;
      final radius = isTouched ? 130.0 : 120.0;
      final widgetSize = isTouched ? 55.0 : 40.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
      return PieChartSectionData(
        color: appColors[i],
        value: data['categoryTotal'] / totalAmount,
        title: '${((data['categoryTotal'] / totalAmount) * 100).round()}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          // fontWeight: FontWeight.bold,
          color: Colors.black,
          // shadows: shadows,
        ),
        badgeWidget: _Badge(
          'assets/lottie/${data['categoryIcon']}.json',
          size: widgetSize,
          borderColor: Colors.black,
        ),
        badgePositionPercentageOffset: .98,
      );
    }).toList();
  }
}

class _Badge extends StatelessWidget {
  const _Badge(
    this.svgAsset, {
    required this.size,
    required this.borderColor,
  });
  final String svgAsset;
  final double size;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(.5),
            offset: const Offset(3, 3),
            blurRadius: 3,
          ),
        ],
      ),
      padding: EdgeInsets.all(size * .15),
      child: Center(
          child: ClipOval(
        clipBehavior: Clip.antiAlias,
        child: Lottie.asset(svgAsset, // Replace with your Lottie animation file
            width: 60, // Adjust the size as needed
            height: 100,
            fit: BoxFit.cover // Adjust the size as needed
            ),
      )),
    );
  }
}
