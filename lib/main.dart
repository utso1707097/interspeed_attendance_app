import 'package:flutter/material.dart';
import 'package:interspeed_attendance_app/dashboard_page.dart';
import 'package:interspeed_attendance_app/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
    );
  }
}
