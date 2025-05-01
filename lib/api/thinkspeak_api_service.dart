import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:project_1/data/data.dart';
import 'package:project_1/thingspeakmodel.dart';

class ThingSpeakService {
  // API constants
  final String baseUrl = 'https://api.thingspeak.com/channels/';
  final String apiKey = "USIJZMOCJ7E3HAWC";

  ThingSpeakService();

  // Fetch data from ThingSpeak API
  Future<ThinkSpeakModel> fetchData(
      {int? results, String? startDate, String? endDate}) async {
    String url = '$baseUrl/2572653/feeds.json?api_key=$apiKey';

    // Add optional parameters if provided
    // if (results != null) {
    //   url += '&results=$results';
    // }
    if (startDate != null) {
      url += '&start=$startDate';
    }
    if (endDate != null) {
      url += '&end=$endDate';
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      log(response.body);
      return ThinkSpeakModel.fromJson(testdata);
      return thinkSpeakModelFromJson(response.body);
    } else {
      throw Exception(
          'Failed to load data from ThingSpeak: ${response.statusCode}');
    }
  }

  // Process the data into daily, weekly and monthly summaries
  Future<WaterUsageSummary> getWaterUsageSummary() async {
    // Fetch data for the past month to have enough data for all summaries
    final DateTime now = DateTime.now();
    final DateTime oneMonthAgo = now.subtract(const Duration(days: 30));

    final String formattedEndDate =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    final String formattedStartDate =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(oneMonthAgo);

    final ThinkSpeakModel data = await fetchData(
        startDate: formattedStartDate, endDate: formattedEndDate);

    return _processWaterUsageData(data);
  }

  // Calculate the water usage per time period
  WaterUsageSummary _processWaterUsageData(ThinkSpeakModel data) {
    if (data.feeds == null || data.feeds!.isEmpty) {
      return WaterUsageSummary(daily: [], weekly: [], monthly: []);
    }

    // Sort feeds by date (oldest first)
    final feeds = List<Feed>.from(data.feeds ?? []);
    feeds.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));

    // Calculate daily usage
    final dailyUsage = _calculateDailyUsage(feeds);

    // Calculate weekly usage (aggregate of daily)
    final weeklyUsage = _calculateWeeklyUsage(dailyUsage);

    // Calculate monthly usage (aggregate of daily)
    final monthlyUsage = _calculateMonthlyUsage(dailyUsage);

    return WaterUsageSummary(
        daily: dailyUsage, weekly: weeklyUsage, monthly: monthlyUsage);
  }

  // Calculate daily water usage from cumulative values
  List<WaterUsageData> _calculateDailyUsage(List<Feed> feeds) {
    final Map<String, WaterUsageData> dailyMap = {};

    // Initialize with first reading
    double? previousCumulative;
    DateTime? previousDate;

    for (final feed in feeds) {
      if (feed.createdAt == null || feed.field2 == null) continue;

      final currentCumulative = double.tryParse(feed.field2!);
      if (currentCumulative == null) continue;

      // Format the date as YYYY-MM-DD
      final dateStr = DateFormat('yyyy-MM-dd').format(feed.createdAt!);

      // If this is a new day, calculate the difference
      if (previousCumulative != null && previousDate != null) {
        final previousDateStr = DateFormat('yyyy-MM-dd').format(previousDate);

        // If it's the same day, update the current day's value
        if (dateStr == previousDateStr) {
          dailyMap[dateStr] = WaterUsageData(
              date: feed.createdAt!,
              gallons: currentCumulative -
                  (dailyMap[dateStr]?.startValue ?? previousCumulative),
              startValue: dailyMap[dateStr]?.startValue ?? previousCumulative,
              endValue: currentCumulative);
        } else {
          // It's a new day, add the previous day's final calculation if not already added
          if (!dailyMap.containsKey(previousDateStr)) {
            dailyMap[previousDateStr] = WaterUsageData(
                date: previousDate,
                gallons: 0,
                startValue: previousCumulative,
                endValue: previousCumulative);
          }

          // Start tracking the new day
          dailyMap[dateStr] = WaterUsageData(
              date: feed.createdAt!,
              gallons: currentCumulative - previousCumulative,
              startValue: previousCumulative,
              endValue: currentCumulative);
        }
      } else {
        // First entry
        dailyMap[dateStr] = WaterUsageData(
            date: feed.createdAt!,
            gallons: 0,
            startValue: currentCumulative,
            endValue: currentCumulative);
      }

      previousCumulative = currentCumulative;
      previousDate = feed.createdAt;
    }

    // Convert map to list
    final List<WaterUsageData> result = dailyMap.values.toList();

    // Sort by date (newest first for display)
    result.sort((a, b) => b.date.compareTo(a.date));

    return result;
  }

  // Calculate weekly water usage from daily data
  List<WaterUsageData> _calculateWeeklyUsage(List<WaterUsageData> dailyData) {
    final Map<int, WaterUsageData> weeklyMap = {};

    for (final daily in dailyData) {
      // Get the week number for this date
      final int weekNumber = _getWeekNumber(daily.date);
      final int year = daily.date.year;
      final int weekYearKey =
          year * 100 + weekNumber; // Unique key for year-week

      if (weeklyMap.containsKey(weekYearKey)) {
        // Update existing week's data
        final existing = weeklyMap[weekYearKey]!;
        weeklyMap[weekYearKey] = WaterUsageData(
            date: existing.date, // Keep the first date of the week
            gallons: existing.gallons + daily.gallons,
            startValue: min(existing.startValue, daily.startValue),
            endValue: max(existing.endValue, daily.endValue));
      } else {
        // Start a new week
        weeklyMap[weekYearKey] = WaterUsageData(
            date: _getStartOfWeek(daily.date),
            gallons: daily.gallons,
            startValue: daily.startValue,
            endValue: daily.endValue);
      }
    }

    // Convert map to list
    final List<WaterUsageData> result = weeklyMap.values.toList();

    // Sort by date (newest first for display)
    result.sort((a, b) => b.date.compareTo(a.date));

    return result;
  }

  // Calculate monthly water usage from daily data
  List<WaterUsageData> _calculateMonthlyUsage(List<WaterUsageData> dailyData) {
    final Map<String, WaterUsageData> monthlyMap = {};

    for (final daily in dailyData) {
      // Get month and year as a unique key
      final String monthYearKey =
          '${daily.date.year}-${daily.date.month.toString().padLeft(2, '0')}';

      if (monthlyMap.containsKey(monthYearKey)) {
        // Update existing month's data
        final existing = monthlyMap[monthYearKey]!;
        monthlyMap[monthYearKey] = WaterUsageData(
            date: existing.date,
            gallons: existing.gallons + daily.gallons,
            startValue: min(existing.startValue, daily.startValue),
            endValue: max(existing.endValue, daily.endValue));
      } else {
        // Start a new month
        monthlyMap[monthYearKey] = WaterUsageData(
            date: DateTime(daily.date.year, daily.date.month, 1),
            gallons: daily.gallons,
            startValue: daily.startValue,
            endValue: daily.endValue);
      }
    }

    // Convert map to list
    final List<WaterUsageData> result = monthlyMap.values.toList();

    // Sort by date (newest first for display)
    result.sort((a, b) => b.date.compareTo(a.date));

    return result;
  }

  // Helper method to get the ISO week number
  int _getWeekNumber(DateTime date) {
    // The ISO week starts on Monday
    final dayOfYear = int.parse(DateFormat('D').format(date));
    final weekDay = date.weekday;
    return ((dayOfYear - weekDay + 10) / 7).floor();
  }

  // Helper method to get the start of a week for a given date
  DateTime _getStartOfWeek(DateTime date) {
    final diff = date.weekday - 1; // Monday is the first day of the week in ISO
    return DateTime(date.year, date.month, date.day - diff);
  }

  // Helper method to find minimum value
  double min(double a, double b) => a < b ? a : b;

  // Helper method to find maximum value
  double max(double a, double b) => a > b ? a : b;

  // Get hourly water usage data for a specific day
  Future<List<HourlyWaterUsage>> getHourlyWaterUsage(DateTime date) async {
    final String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final String startDate = '$formattedDate 00:00:00';
    final String endDate = '$formattedDate 23:59:59';

    final ThinkSpeakModel data =
        await fetchData(startDate: startDate, endDate: endDate);

    return _processHourlyData(data, date);
  }

  // Process hourly water usage data
  List<HourlyWaterUsage> _processHourlyData(
      ThinkSpeakModel data, DateTime selectedDate) {
    if (data.feeds == null || data.feeds!.isEmpty) {
      return [];
    }

    // Initialize with 24 hours of the day
    final Map<int, HourlyWaterUsage> hourlyMap = {};
    for (int hour = 0; hour < 24; hour++) {
      hourlyMap[hour] = HourlyWaterUsage(hour: hour, gallons: 0);
    }

    // Sort feeds by date (oldest first)
    final feeds = List<Feed>.from(data.feeds ?? []);
    feeds.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));

    // Process feeds to calculate hourly usage
    double? previousCumulative;
    DateTime? previousTime;

    for (final feed in feeds) {
      if (feed.createdAt == null || feed.field2 == null) continue;

      final currentCumulative = double.tryParse(feed.field2!);
      if (currentCumulative == null) continue;

      if (previousCumulative != null && previousTime != null) {
        final int hour = feed.createdAt!.hour;
        final double usage = currentCumulative - previousCumulative;

        if (usage > 0) {
          hourlyMap[hour] = HourlyWaterUsage(
              hour: hour, gallons: hourlyMap[hour]!.gallons + usage);
        }
      }

      previousCumulative = currentCumulative;
      previousTime = feed.createdAt;
    }

    // Convert map to list
    return hourlyMap.values.toList()..sort((a, b) => a.hour.compareTo(b.hour));
  }
}

// Data models for water usage summaries
class WaterUsageSummary {
  final List<WaterUsageData> daily;
  final List<WaterUsageData> weekly;
  final List<WaterUsageData> monthly;

  WaterUsageSummary(
      {required this.daily, required this.weekly, required this.monthly});
}

class WaterUsageData {
  final DateTime date;
  final double gallons;
  final double startValue;
  final double endValue;

  WaterUsageData(
      {required this.date,
      required this.gallons,
      required this.startValue,
      required this.endValue});
}

class HourlyWaterUsage {
  final int hour;
  final double gallons;

  HourlyWaterUsage({required this.hour, required this.gallons});
}
