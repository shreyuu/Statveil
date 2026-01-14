import 'package:flutter/material.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
