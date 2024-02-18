import 'package:flutter/material.dart';
import 'package:interspeed_attendance_app/dashboard_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:interspeed_attendance_app/login_page.dart';
import 'package:get/get.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Map<String, dynamic> sessionData;
  bool isFirstScreen = false;

  @override
  void initState() {
    super.initState();
    checkFirstScreen();
  }

  Future<void> checkFirstScreen() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    // If the 'seen' value is null or false, set isFirstScreen to false
    bool seen = pref.getBool('seen') ?? false;
    setState(() {
      isFirstScreen = seen;
      //loadSessionData();
    });
  }


  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: !isFirstScreen ? LoginPage() : DashboardPage(),
    );
  }
}