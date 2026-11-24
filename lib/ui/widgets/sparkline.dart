import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../domain/telemetry.dart';

class Sparkline extends StatelessWidget {
  const Sparkline({
    super.key,
    required this.readings,
    required this.color,
    this.showAxis = false,
  });

  final List<SensorReading> readings;
  final Color color;
  final bool showAxis;

  @override
  Widget build(BuildContext context) {
    if (readings.length < 2) return const SizedBox.shrink();
    final spots = [
      for (var i = 0; i < readings.length; i++)
        FlSpot(i.toDouble(), readings[i].value),
    ];
    final limit = readings.first.metric.alertAbove;
    return LineChart(
      duration: Duration.zero, // live data: skip implicit animations
      LineChartData(
        minX: 0,
        maxX: spots.length - 1,
        lineTouchData: LineTouchData(enabled: showAxis),
        gridData: FlGridData(show: showAxis, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          show: showAxis,
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          bottomTitles: const AxisTitles(),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
        ),
        extraLinesData: showAxis
            ? ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: limit,
                    color: Colors.red.withValues(alpha: 0.6),
                    dashArray: [6, 4],
                    strokeWidth: 1,
                  ),
                ],
              )
            : null,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            preventCurveOverShooting: true,
            barWidth: 2,
            color: color,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: color.withValues(alpha: 0.15),
            ),
          ),
        ],
      ),
    );
  }
}
