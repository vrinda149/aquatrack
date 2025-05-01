import 'package:flutter/material.dart';
import 'package:project_1/api/thinkspeak_api_service.dart';
import 'package:project_1/api/water_summary.dart';
import 'package:project_1/aquatrack_page.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => WaterUsageViewModel(
            apiService: ThingSpeakService(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Water Usage dashboard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const WaterUsageTracker(),
    );
  }
}
