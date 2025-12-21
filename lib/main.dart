import 'package:flutter/material.dart';
import 'features/dashboard/dashboard_screen.dart';

void main() {
  runApp(const StatveilApp());
}

class StatveilApp extends StatelessWidget {
  const StatveilApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Statveil',
      theme: ThemeData.dark(useMaterial3: true),
      home: const DashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
