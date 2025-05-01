import 'package:flutter/material.dart';
import 'package:project_1/api/water_summary.dart';
import 'package:project_1/aqua_widgets.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class WaterUsageTracker extends StatelessWidget {
  const WaterUsageTracker({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Consumer<WaterUsageViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.errorMessage != null) {
              return Center(child: Text('Error: ${viewModel.errorMessage}'));
            }

            return Center(
              child: Container(
                width: 350,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 20, left: 20, right: 20),
                      child: Text(
                        'My Water Usage',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Toggle buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildToggleButton(context, 'Monthly',
                                viewModel.currentView == 'Monthly'),
                          ),
                          Expanded(
                            child: _buildToggleButton(context, 'Weekly',
                                viewModel.currentView == 'Weekly'),
                          ),
                          Expanded(
                            child: _buildToggleButton(context, 'Daily',
                                viewModel.currentView == 'Daily'),
                          ),
                        ],
                      ),
                    ),

                    // Usage amount
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Text(
                        '${viewModel.getCurrentUsage().toInt()} gallons',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Date navigation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () => viewModel.navigateToPreviousDate(),
                        ),
                        Text(
                          'Used ${viewModel.getFormattedDate()}',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: () => viewModel.navigateToNextDate(),
                        ),
                      ],
                    ),

                    // Usage goal status
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        '${viewModel.getPercentFromGoal().toStringAsFixed(1)}% ${viewModel.getPercentFromGoal() > 0 ? 'under' : 'over'} usage goal',
                        style: TextStyle(
                          fontSize: 16,
                          color: viewModel.getPercentFromGoal() > 0
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ),

                    // Chart based on selected view
                    _buildChartForView(viewModel),

                    // Usage goal
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Usage goal: ${viewModel.usageGoal.toInt()} gallons',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildToggleButton(
      BuildContext context, String title, bool isSelected) {
    return GestureDetector(
      onTap: () {
        Provider.of<WaterUsageViewModel>(context, listen: false)
            .setCurrentView(title);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.cyan : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(5),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildChartForView(WaterUsageViewModel viewModel) {
    switch (viewModel.currentView) {
      case 'Daily':
        return HourlyWaterUsageChart(
          hourlyData: viewModel.hourlyData ?? [],
          averageUsage: viewModel.getAverageHourlyUsage(),
        );
      case 'Weekly':
        return WeeklyWaterUsageChart(
          weeklyData: viewModel.usageSummary?.weekly ?? [],
          averageUsage: viewModel.getAverageWeeklyUsage(),
        );
      case 'Monthly':
        return MonthlyWaterUsageChart(
          monthlyData: viewModel.usageSummary?.monthly ?? [],
          averageUsage: viewModel.getAverageMonthlyUsage(),
        );
      default:
        return const SizedBox(height: 200);
    }
  }
}
