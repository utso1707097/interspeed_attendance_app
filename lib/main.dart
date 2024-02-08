import 'package:flutter/material.dart';
import 'package:interspeed_attendance_app/dashboard_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:interspeed_attendance_app/login_page.dart';

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
      loadSessionData();
    });
  }

  Future<void> loadSessionData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      print(prefs.getString('user_id'));
      sessionData = {
        'user_id': prefs.getString('user_id') ?? '',
        'user_name': prefs.getString('user_name') ?? '',
        'full_name': prefs.getString('full_name') ?? '',
        'user_type_id': prefs.getString('user_type_id') ?? '',
        'picture_name': prefs.getString('picture_name') ?? '',
        'user_type_name': prefs.getString('user_type_name') ?? '',
        'employee_id': prefs.getString('employee_id') ?? '',
        'designation_id': prefs.getString('designation_id') ?? '',
        'employee_position_id': prefs.getString('employee_position_id') ?? '',
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: !isFirstScreen ? LoginPage() : DashboardPage(sessionData: sessionData),
    );
  }
}
