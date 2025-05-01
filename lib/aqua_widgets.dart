import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:project_1/api/thinkspeak_api_service.dart';

// Hourly Line Chart for Daily View
class HourlyWaterUsageChart extends StatelessWidget {
  final List<HourlyWaterUsage> hourlyData;
  final double averageUsage;

  const HourlyWaterUsageChart({
    super.key,
    required this.hourlyData,
    required this.averageUsage,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: FlTitlesData(
              leftTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    String text = '';
                    if (value == 0) {
                      text = '12AM';
                    } else if (value == 6) {
                      text = '6AM';
                    } else if (value == 12) {
                      text = '12PM';
                    } else if (value == 18) {
                      text = '6PM';
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(text, style: const TextStyle(fontSize: 12)),
                    );
                  },
                  reservedSize: 30,
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: const Border(
                bottom: BorderSide(color: Colors.black, width: 1),
                left: BorderSide(color: Colors.transparent),
                right: BorderSide(color: Colors.transparent),
                top: BorderSide(color: Colors.transparent),
              ),
            ),
            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                // tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
                getTooltipItems: (List<LineBarSpot> touchedSpots) {
                  return touchedSpots.map((spot) {
                    final hourStr = spot.x.toInt() == 0
                        ? '12 AM'
                        : (spot.x.toInt() < 12
                            ? '${spot.x.toInt()} AM'
                            : (spot.x.toInt() == 12
                                ? '12 PM'
                                : '${spot.x.toInt() - 12} PM'));
                    return LineTooltipItem(
                      '$hourStr: ${spot.y.toStringAsFixed(1)} gallons',
                      const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    );
                  }).toList();
                },
              ),
            ),
            minX: 0,
            maxX: 23,
            minY: 0,
            maxY: _getMaxY(),
            lineBarsData: [
              LineChartBarData(
                spots: _generateSpots(),
                isCurved: true,
                color: Colors.cyan,
                barWidth: 3,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: false,
                ),
              ),
            ],
            extraLinesData: ExtraLinesData(
              horizontalLines: [
                HorizontalLine(
                  y: averageUsage,
                  color: Colors.black,
                  strokeWidth: 1,
                  dashArray: [5, 5],
                  label: HorizontalLineLabel(
                    show: true,
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.only(right: 5, bottom: 5),
                    style: const TextStyle(color: Colors.black, fontSize: 10),
                    labelResolver: (line) => 'your average',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Generate FlSpots from hourly data
  List<FlSpot> _generateSpots() {
    return hourlyData.map((hourData) {
      return FlSpot(hourData.hour.toDouble(), hourData.gallons);
    }).toList();
  }

  // Get the maximum Y value for the chart
  double _getMaxY() {
    if (hourlyData.isEmpty) return 40;
    double maxValue = 0;
    for (final hourData in hourlyData) {
      if (hourData.gallons > maxValue) {
        maxValue = hourData.gallons;
      }
    }
    // Return max value with some padding, or default if too small
    return maxValue < 10 ? 40 : maxValue * 1.2;
  }
}

// Weekly Bar Chart for Weekly View
class WeeklyWaterUsageChart extends StatelessWidget {
  final List<WaterUsageData> weeklyData;
  final double averageUsage;

  const WeeklyWaterUsageChart({
    super.key,
    required this.weeklyData,
    required this.averageUsage,
  });

  @override
  Widget build(BuildContext context) {
    // Use at most the last 4 weeks for the chart
    final displayData =
        weeklyData.length > 4 ? weeklyData.sublist(0, 4) : weeklyData;

    return SizedBox(
      height: 200,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.center,
            maxY: _getMaxY(),
            minY: 0,
            groupsSpace: 12,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                // tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  if (groupIndex >= displayData.length) return null;
                  final weekData = displayData[groupIndex];
                  return BarTooltipItem(
                    '${_getWeekLabel(weekData.date)}\n${rod.toY.toStringAsFixed(1)} gallons',
                    const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    if (value.toInt() >= displayData.length) {
                      return const Text('');
                    }
                    final weekData = displayData[value.toInt()];
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _getShortWeekLabel(weekData.date),
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: const Border(
                bottom: BorderSide(color: Colors.black, width: 1),
                left: BorderSide(color: Colors.transparent),
                right: BorderSide(color: Colors.transparent),
                top: BorderSide(color: Colors.transparent),
              ),
            ),
            gridData: const FlGridData(show: false),
            barGroups: _getBarGroups(displayData),
            extraLinesData: ExtraLinesData(
              horizontalLines: [
                HorizontalLine(
                  y: averageUsage,
                  color: Colors.black,
                  strokeWidth: 1,
                  dashArray: [5, 5],
                  label: HorizontalLineLabel(
                    show: true,
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.only(right: 5, bottom: 5),
                    style: const TextStyle(color: Colors.black, fontSize: 10),
                    labelResolver: (line) => 'your average',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Generate bar groups for each week
  List<BarChartGroupData> _getBarGroups(List<WaterUsageData> data) {
    return List.generate(data.length, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data[index].gallons,
            width: 20,
            color: Colors.cyan,
            borderRadius: BorderRadius.circular(4),
          )
        ],
      );
    });
  }

  // Get the maximum Y value for the chart
  double _getMaxY() {
    if (weeklyData.isEmpty) return 1000;
    double maxValue = 0;
    for (final weekData in weeklyData) {
      if (weekData.gallons > maxValue) {
        maxValue = weekData.gallons;
      }
    }
    // Return max value with some padding, or default if too small
    return maxValue < 100 ? 1000 : maxValue * 1.2;
  }

  // Get a week label in format "Week of Mon, DD"
  String _getWeekLabel(DateTime date) {
    final startOfWeek = _getStartOfWeek(date);
    return 'Week of ${DateFormat('MMM d').format(startOfWeek)}';
  }

  // Get a shorter week label format "MM/DD"
  String _getShortWeekLabel(DateTime date) {
    final startOfWeek = _getStartOfWeek(date);
    return DateFormat('MM/dd').format(startOfWeek);
  }

  // Helper method to get the start of a week
  DateTime _getStartOfWeek(DateTime date) {
    final diff = date.weekday - 1; // Monday as first day
    return DateTime(date.year, date.month, date.day - diff);
  }
}

// Monthly Bar Chart for Monthly View
class MonthlyWaterUsageChart extends StatelessWidget {
  final List<WaterUsageData> monthlyData;
  final double averageUsage;

  const MonthlyWaterUsageChart({
    super.key,
    required this.monthlyData,
    required this.averageUsage,
  });

  @override
  Widget build(BuildContext context) {
    // Use at most the last 6 months for the chart
    final displayData =
        monthlyData.length > 6 ? monthlyData.sublist(0, 6) : monthlyData;

    return SizedBox(
      height: 200,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.center,
            maxY: _getMaxY(),
            minY: 0,
            groupsSpace: 12,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                // tool: Colors.blueGrey.withOpacity(0.8),
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  if (groupIndex >= displayData.length) return null;
                  final monthData = displayData[groupIndex];
                  return BarTooltipItem(
                    '${DateFormat('MMMM yyyy').format(monthData.date)}\n${rod.toY.toStringAsFixed(1)} gallons',
                    const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    if (value.toInt() >= displayData.length) {
                      return const Text('');
                    }
                    final monthData = displayData[value.toInt()];
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        DateFormat('MMM').format(monthData.date),
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: const Border(
                bottom: BorderSide(color: Colors.black, width: 1),
                left: BorderSide(color: Colors.transparent),
                right: BorderSide(color: Colors.transparent),
                top: BorderSide(color: Colors.transparent),
              ),
            ),
            gridData: const FlGridData(show: false),
            barGroups: _getBarGroups(displayData),
            extraLinesData: ExtraLinesData(
              horizontalLines: [
                HorizontalLine(
                  y: averageUsage,
                  color: Colors.black,
                  strokeWidth: 1,
                  dashArray: [5, 5],
                  label: HorizontalLineLabel(
                    show: true,
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.only(right: 5, bottom: 5),
                    style: const TextStyle(color: Colors.black, fontSize: 10),
                    labelResolver: (line) => 'your average',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Generate bar groups for each month
  List<BarChartGroupData> _getBarGroups(List<WaterUsageData> data) {
    return List.generate(data.length, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data[index].gallons,
            width: 20,
            color: Colors.cyan,
            borderRadius: BorderRadius.circular(4),
          )
        ],
      );
    });
  }

  // Get the maximum Y value for the chart
  double _getMaxY() {
    if (monthlyData.isEmpty) return 5000;
    double maxValue = 0;
    for (final monthData in monthlyData) {
      if (monthData.gallons > maxValue) {
        maxValue = monthData.gallons;
      }
    }
    // Return max value with some padding, or default if too small
    return maxValue < 1000 ? 5000 : maxValue * 1.2;
  }
}
