import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_1/api/thinkspeak_api_service.dart';

class WaterUsageViewModel extends ChangeNotifier {
  final ThingSpeakService _apiService;

  // Current view state
  String _currentView = 'Daily';
  DateTime _selectedDate = DateTime.now();
  final double _usageGoal = 400; // Default goal in gallons

  // Data containers
  WaterUsageSummary? _usageSummary;
  List<HourlyWaterUsage>? _hourlyData;
  bool _isLoading = false;
  String? _errorMessage;

  WaterUsageViewModel({required ThingSpeakService apiService})
      : _apiService = apiService {
    // Initial data loading
    fetchData();
  }

  // Getters
  String get currentView => _currentView;
  DateTime get selectedDate => _selectedDate;
  double get usageGoal => _usageGoal;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  WaterUsageSummary? get usageSummary => _usageSummary;
  List<HourlyWaterUsage>? get hourlyData => _hourlyData;

  // Set current view (Daily, Weekly, Monthly)
  void setCurrentView(String view) {
    if (_currentView != view) {
      _currentView = view;
      // Reset selected date to today when switching views
      _selectedDate = DateTime.now();
      fetchData();
      notifyListeners();
    }
  }

  // Navigate to previous date/week/month
  void navigateToPreviousDate() {
    switch (_currentView) {
      case 'Daily':
        _selectedDate = _selectedDate.subtract(const Duration(days: 1));
        break;
      case 'Weekly':
        _selectedDate = _selectedDate.subtract(const Duration(days: 7));
        break;
      case 'Monthly':
        // Go to previous month
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month - 1,
          _selectedDate.day,
        );
        break;
    }
    fetchData();
    notifyListeners();
  }

  // Navigate to next date/week/month
  void navigateToNextDate() {
    final now = DateTime.now();
    DateTime nextDate;

    switch (_currentView) {
      case 'Daily':
        nextDate = _selectedDate.add(const Duration(days: 1));
        break;
      case 'Weekly':
        nextDate = _selectedDate.add(const Duration(days: 7));
        break;
      case 'Monthly':
        // Go to next month
        nextDate = DateTime(
          _selectedDate.year,
          _selectedDate.month + 1,
          _selectedDate.day,
        );
        break;
      default:
        nextDate = _selectedDate.add(const Duration(days: 1));
    }

    // Don't navigate to future dates
    if (nextDate.isAfter(now)) return;

    _selectedDate = nextDate;
    fetchData();
    notifyListeners();
  }

  // Fetch data based on current view
  Future<void> fetchData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Always fetch the usage summary
      _usageSummary = await _apiService.getWaterUsageSummary();

      // If daily view, also fetch hourly data
      if (_currentView == 'Daily') {
        _hourlyData = await _apiService.getHourlyWaterUsage(_selectedDate);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Returns the current usage value based on the selected view and date
  double getCurrentUsage() {
    if (_usageSummary == null) return 0;

    switch (_currentView) {
      case 'Daily':
        final dailyData = _usageSummary!.daily.firstWhere(
            (data) => _isSameDay(data.date, _selectedDate),
            orElse: () => WaterUsageData(
                date: _selectedDate, gallons: 0, startValue: 0, endValue: 0));
        return dailyData.gallons;

      case 'Weekly':
        final weeklyData = _usageSummary!.weekly.firstWhere(
            (data) => _isSameWeek(data.date, _selectedDate),
            orElse: () => WaterUsageData(
                date: _selectedDate, gallons: 0, startValue: 0, endValue: 0));
        return weeklyData.gallons;

      case 'Monthly':
        final monthlyData = _usageSummary!.monthly.firstWhere(
            (data) => _isSameMonth(data.date, _selectedDate),
            orElse: () => WaterUsageData(
                date: _selectedDate, gallons: 0, startValue: 0, endValue: 0));
        return monthlyData.gallons;

      default:
        return 0;
    }
  }

  bool _isSameMonth(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month;
  }

  bool _isSameWeek(DateTime date1, DateTime date2) {
    DateTime startOfWeek(DateTime date) {
      final dayOfWeek = date.weekday; // Monday = 1, Sunday = 7
      return DateTime(date.year, date.month, date.day - (dayOfWeek - 1));
    }

    final start1 = startOfWeek(date1);
    final start2 = startOfWeek(date2);

    return start1.year == start2.year &&
        start1.month == start2.month &&
        start1.day == start2.day;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Calculate the percentage under/over the usage goal
  double getPercentFromGoal() {
    final currentUsage = getCurrentUsage();
    return ((usageGoal - currentUsage) / usageGoal) * 100;
  }

  // Format the selected date according to the current view
  String getFormattedDate() {
    switch (_currentView) {
      case 'Daily':
        return DateFormat('MMM d').format(_selectedDate);

      case 'Weekly':
        final startOfWeek = _getStartOfWeek(_selectedDate);
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return '${DateFormat('MMM d').format(startOfWeek)} - ${DateFormat('MMM d').format(endOfWeek)}';

      case 'Monthly':
        return DateFormat('MMMM yyyy').format(_selectedDate);

      default:
        return DateFormat('MMM d').format(_selectedDate);
    }
  }

  DateTime _getStartOfWeek(DateTime date) {
    final dayOfWeek = date.weekday; // Monday = 1, Sunday = 7
    return DateTime(date.year, date.month, date.day - (dayOfWeek - 1));
  }

  // Get average hourly water usage
  double getAverageHourlyUsage() {
    if (_hourlyData == null || _hourlyData!.isEmpty) return 0;
    double sum = 0;
    for (final hourData in _hourlyData!) {
      sum += hourData.gallons;
    }
    return sum / _hourlyData!.length;
  }

  // Get average weekly water usage
  double getAverageWeeklyUsage() {
    if (_usageSummary?.weekly == null || _usageSummary!.weekly.isEmpty) {
      return 0;
    }
    double sum = 0;
    for (final weekData in _usageSummary!.weekly) {
      sum += weekData.gallons;
    }
    return sum / _usageSummary!.weekly.length;
  }

  // Get average monthly water usage
  double getAverageMonthlyUsage() {
    if (_usageSummary?.monthly == null || _usageSummary!.monthly.isEmpty) {
      return 0;
    }
    double sum = 0;
    for (final monthData in _usageSummary!.monthly) {
      sum += monthData.gallons;
    }
    return sum / _usageSummary!.monthly.length;
  }
}
