import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:collection';

import 'package:project_1/thingspeakmodel.dart';
import 'package:project_1/water_conservation.dart';

class WaterUsageDashboard extends StatefulWidget {
  const WaterUsageDashboard({Key? key}) : super(key: key);

  @override
  _WaterUsageDashboardState createState() => _WaterUsageDashboardState();
}

class _WaterUsageDashboardState extends State<WaterUsageDashboard> {
  late Future<ThinkSpeakModel> _futureData;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _futureData = fetchWaterData();
  }

  Future<ThinkSpeakModel> fetchWaterData() async {
    final response = await http.get(Uri.parse(
        'https://api.thingspeak.com/channels/2572653/feeds.json?api_key=USIJZMOCJ7E3HAWC'));

    if (response.statusCode == 200) {
      return thinkSpeakModelFromJson(response.body);
    } else {
      throw Exception('Failed to load water usage data');
    }
  }

  // Calculate daily and monthly cumulative volumes
  Map<String, double> calculateDailyVolumes(List<Feed> feeds) {
    SplayTreeMap<String, double> dailyVolumes = SplayTreeMap();

    for (var feed in feeds) {
      String date = DateFormat('yyyy-MM-dd').format(feed.createdAt!);
      double volume = double.parse(feed.field2.toString());

      dailyVolumes[date] = volume;
    }

    return dailyVolumes;
  }

  Map<String, double> calculateMonthlyVolumes(List<Feed> feeds) {
    SplayTreeMap<String, double> monthlyVolumes = SplayTreeMap();

    for (var feed in feeds) {
      String month = DateFormat('yyyy-MM').format(feed.createdAt!);
      double volume = double.parse(feed.field2.toString());

      monthlyVolumes[month] = (monthlyVolumes[month] ?? 0) + volume;
    }

    return monthlyVolumes;
  }

  List<LineChartBarData> _buildLineChartData(
      List<Feed> feeds, bool isFlowRate) {
    final List<FlSpot> spots = List.generate(
      feeds.length,
      (index) => FlSpot(
        index.toDouble(),
        double.parse(isFlowRate
            ? feeds[index].field1.toString()
            : feeds[index].field2.toString()),
      ),
    );

    return [
      LineChartBarData(
        spots: spots,
        gradient: LinearGradient(
          colors: [
            isFlowRate ? Colors.blue.shade400 : Colors.green.shade400,
            isFlowRate ? Colors.blue.shade700 : Colors.green.shade700,
          ],
        ),
        barWidth: 3,
        isStrokeCapRound: true,
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: [
              isFlowRate ? Colors.blue.shade200 : Colors.green.shade200,
              isFlowRate ? Colors.blue.shade50 : Colors.green.shade50,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    ];
  }

  Widget _buildLineChart(List<Feed> feeds, bool isFlowRate) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isFlowRate ? 'Water Flow Rate' : 'Cumulative Water Volume',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              Expanded(
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      horizontalInterval: 1,
                      verticalInterval: 1,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: Colors.grey.shade300,
                        strokeWidth: 1,
                      ),
                      getDrawingVerticalLine: (_) => FlLine(
                        color: Colors.grey.shade300,
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) =>
                              Text(value.toInt().toString()),
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    lineBarsData: _buildLineChartData(feeds, isFlowRate),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  isFlowRate
                      ? 'Measures water flow in real-time'
                      : 'Tracks total water consumption over time',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Usage Dashboard'),
        backgroundColor: Colors.blue.shade600,
        actions: [
          TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const WaterConservationPage()));
              },
              child: const Text('Water Conservation Techniques'))
        ],
      ),
      body: FutureBuilder<ThinkSpeakModel>(
        future: _futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          }

          final feeds = snapshot.data!.feeds!;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 0, label: Text('Flow Rate')),
                    ButtonSegment(value: 1, label: Text('Volume')),
                    ButtonSegment(value: 2, label: Text('Data Table')),
                  ],
                  selected: {_selectedIndex},
                  onSelectionChanged: (newSelection) {
                    setState(() {
                      _selectedIndex = newSelection.first;
                    });
                  },
                ),
              ),
              Expanded(
                child: _selectedIndex == 0
                    ? _buildLineChart(feeds, true)
                    : _selectedIndex == 1
                        ? _buildLineChart(feeds, false)
                        : _buildDetailedDataTable(feeds),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDetailedDataTable(List<Feed> feeds) {
    final dailyVolumes = calculateDailyVolumes(feeds);
    final monthlyVolumes = calculateMonthlyVolumes(feeds);

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Raw Data'),
              Tab(text: 'Daily Volume'),
              Tab(text: 'Monthly Volume'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Raw Data Table
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(
                          label: Text('Date',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Flow Rate',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Cumulative Volume',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: feeds.map((feed) {
                      return DataRow(cells: [
                        DataCell(Text(DateFormat('yyyy-MM-dd HH:mm')
                            .format(feed.createdAt!))),
                        DataCell(Text(feed.field1.toString())),
                        DataCell(Text(feed.field2.toString())),
                      ]);
                    }).toList(),
                  ),
                ),

                // Daily Volume Table
                SingleChildScrollView(
                  child: DataTable(
                    columns: const [
                      DataColumn(
                          label: Text('Date',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Volume (L)',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: dailyVolumes.entries.map((entry) {
                      return DataRow(cells: [
                        DataCell(Text(entry.key)),
                        DataCell(Text(entry.value.toStringAsFixed(2))),
                      ]);
                    }).toList(),
                  ),
                ),

                // Monthly Volume Table
                SingleChildScrollView(
                  child: DataTable(
                    columns: const [
                      DataColumn(
                          label: Text('Month',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Volume (L)',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: monthlyVolumes.entries.map((entry) {
                      return DataRow(cells: [
                        DataCell(Text(entry.key)),
                        DataCell(Text(entry.value.toStringAsFixed(2))),
                      ]);
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
