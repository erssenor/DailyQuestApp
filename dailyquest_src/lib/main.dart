import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'colors.dart';
import 'login_screen.dart';
import 'dart:async';
import 'temp_db.dart';

// Primary Driver for the app.
Future<void> main() async {
  if(Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  WidgetsFlutterBinding.ensureInitialized();
  // Schedule daily reset of current completions at local midnight
  _scheduleMidnightReset();
  runApp(const MyApp());
}

/// Calculate the Duration until the next local midnight.
Duration _timeUntilNextMidnight() {
  final now = DateTime.now();
  final tomorrow = DateTime(now.year, now.month, now.day + 1);
  return tomorrow.difference(now);
}

/// Schedule clearing of current completions at the next midnight and every 24 hours thereafter.
void _scheduleMidnightReset() {
  final Duration untilMidnight = _timeUntilNextMidnight();
  Timer(untilMidnight, () {
    TempDatabase.clearCurrentCompletions();
    // After first run, schedule a periodic timer every 24 hours.
    Timer.periodic(const Duration(days: 1), (_) {
      TempDatabase.clearCurrentCompletions();
    });
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DailyQuest',

      theme: ThemeData(
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          backgroundColor: secColor_black,
          foregroundColor: primColor_dGreen,
        ),
      ),

      home: const LoginScreen(),
    );
  }
}

