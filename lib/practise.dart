import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project_1/thingspeakmodel.dart';

class AppColors {
  static const Color primary = contentColorCyan;
  static const Color menuBackground = Color(0xFF090912);
  static const Color itemsBackground = Color(0xFF1B2339);
  static const Color pageBackground = Color(0xFF282E45);
  static const Color mainTextColor1 = Colors.white;
  static const Color mainTextColor2 = Colors.white70;
  static const Color mainTextColor3 = Colors.white38;
  static const Color mainGridLineColor = Colors.white10;
  static const Color borderColor = Colors.white54;
  static const Color gridLinesColor = Color(0x11FFFFFF);

  static const Color contentColorBlack = Colors.black;
  static const Color contentColorWhite = Colors.white;
  static const Color contentColorBlue = Color(0xFF2196F3);
  static const Color contentColorYellow = Color(0xFFFFC300);
  static const Color contentColorOrange = Color(0xFFFF683B);
  static const Color contentColorGreen = Color(0xFF3BFF49);
  static const Color contentColorPurple = Color(0xFF6E1BFF);
  static const Color contentColorPink = Color(0xFFFF3AF2);
  static const Color contentColorRed = Color(0xFFE80054);
  static const Color contentColorCyan = Color(0xFF50E4FF);
}

class Practisepage extends StatelessWidget {
  Practisepage({super.key});
  Future<ThinkSpeakModel> fetchAlbum() async {
    final response = await http.get(Uri.parse(
        'https://api.thingspeak.com/channels/2572653/feeds.json?api_key=USIJZMOCJ7E3HAWC'));

    if (response.statusCode == 200) {
      print(response.body);
      return thinkSpeakModelFromJson(response.body);
      // If the server did return a 200 OK response,
      // then parse the JSON.
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception();
    }
  }

  final List<Color> gradientColors = [
    AppColors.contentColorCyan,
    AppColors.contentColorBlue,
  ];

  LineChartData fiel1Graph(List<Feed> feed) {
    final List<FlSpot> spots = List.generate(
        feed.length,
        (index) => FlSpot(
            index.toDouble(), double.parse(feed[index].field1.toString())));
    print(feed.length);
    int mx = -(1 << 63);
    int mn = (1 << 63) - 1;
    for (var i in feed) {
      mx = max(mx, double.parse(i.field1.toString()).ceil());
      mn = min(mn, double.parse(i.field1.toString()).ceil());
    }

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: AppColors.mainGridLineColor,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: AppColors.mainGridLineColor,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: const FlTitlesData(
        show: true,
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        // bottomTitles: AxisTitles(
        //   sideTitles: SideTitles(
        //     showTitles: true,
        //     reservedSize: 30,
        //     interval: 1,
        //     getTitlesWidget: bottomTitleWidgets,
        //   ),
        // ),
        // leftTitles: AxisTitles(
        //   sideTitles: SideTitles(
        //     showTitles: true,
        //     interval: 1,
        //     getTitlesWidget: leftTitleWidgets,
        //     reservedSize: 42,
        //   ),
        // ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: feed.length + 0,
      minY: mn.toDouble(),
      maxY: mx.toDouble(),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          // isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 2,
          isStrokeCapRound: true,
          // dotData: const FlDotData(
          //   show: false,
          // ),
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

  LineChartData fiel2Graph(List<Feed> feed) {
    final List<FlSpot> spots = List.generate(
        feed.length,
        (index) => FlSpot(
            index.toDouble(), double.parse(feed[index].field2.toString())));

    int mx = -(1 << 63);
    int mn = (1 << 63) - 1;
    for (var i in feed) {
      mx = max(mx, double.parse(i.field2.toString()).ceil());
      mn = min(mn, double.parse(i.field2.toString()).ceil());
    }

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: AppColors.mainGridLineColor,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: AppColors.mainGridLineColor,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: const FlTitlesData(
        show: true,
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        // bottomTitles: AxisTitles(
        //   sideTitles: SideTitles(
        //     showTitles: true,
        //     reservedSize: 30,
        //     interval: 1,
        //     getTitlesWidget: bottomTitleWidgets,
        //   ),
        // ),
        // leftTitles: AxisTitles(
        //   sideTitles: SideTitles(
        //     showTitles: true,
        //     interval: 1,
        //     getTitlesWidget: leftTitleWidgets,
        //     reservedSize: 42,
        //   ),
        // ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: feed.length + 0,
      minY: mn.toDouble(),
      maxY: mx.toDouble(),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          // isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 2,
          isStrokeCapRound: true,
          // dotData: const FlDotData(
          //   show: false,
          // ),
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

  Map<DateTime, dynamic> dailydata = {};
  Map<DateTime, dynamic> dailydataField2 = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<ThinkSpeakModel>(
          future: fetchAlbum(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              for (var data in snapshot.data!.feeds!) {
                dailydata[DateTime(data.createdAt!.year, data.createdAt!.month,
                    data.createdAt!.day)] = data.field1;
              }
              for (var data in snapshot.data!.feeds!) {
                dailydataField2[DateTime(data.createdAt!.year,
                    data.createdAt!.month, data.createdAt!.day)] = data.field2;
              }
              return ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Column(
                          children: [
                            SizedBox(
                              height: 300,
                              width:
                                  MediaQuery.sizeOf(context).width * 0.5 - 16,
                              child:
                                  LineChart(fiel1Graph(snapshot.data!.feeds!)),
                            ),
                            Text("Flow rate"),
                          ],
                        ),
                        Column(
                          children: [
                            SizedBox(
                              height: 300,
                              width:
                                  MediaQuery.sizeOf(context).width * 0.5 - 16,
                              child:
                                  LineChart(fiel2Graph(snapshot.data!.feeds!)),
                            ),
                            Text("Cumilative volume of water used")
                          ],
                        ),
                      ],
                    ),
                  ),
                  ...dailydata.entries.map((entry) {
                    return ListTile(
                      title: Text(entry.value.toString()),
                      subtitle: Text(entry.key.toString()),
                    );
                  }),
                  ...dailydataField2.entries.map((entry) {
                    return ListTile(
                      title: Text(entry.value.toString()),
                      subtitle: Text(entry.key.toString()),
                    );
                  })
                ],
              );
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }
            return const CircularProgressIndicator();
          }),
    );
  }
}
