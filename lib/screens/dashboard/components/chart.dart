import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class Chart extends StatelessWidget {
  final int numOfMembers;
  final int numOfLeaders;

  const Chart({
    Key? key,
    required this.numOfMembers,
    required this.numOfLeaders,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int total = numOfMembers + numOfLeaders;
    if (total == 0) total = 1; // Prevent division by zero

    List<PieChartSectionData> pieChartSections = [
      PieChartSectionData(
        color: const Color(0xFF1DE9B6),
        value: (numOfMembers / total) * 100,
        title: "${((numOfMembers / total) * 100).toStringAsFixed(1)}%",
        titleStyle: const TextStyle(
          color: const Color(0xFFD50000),
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
        radius: 30,
      ),
      PieChartSectionData(
        color: const Color(0xFF76FF03),
        value: (numOfLeaders / total) * 100,
        title: "${((numOfLeaders / total) * 100).toStringAsFixed(1)}%",
        titleStyle: const TextStyle(
          color: const Color(0xFFD50000),
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
        radius: 30,
      ),
    ];

    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 75,
              startDegreeOffset: -90,
              sections: pieChartSections,
            ),
          ),
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "$total People",
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const Text(
                  "Leaders & Members",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
