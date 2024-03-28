import 'package:flutter/material.dart';
import 'package:interspeed_attendance_app/drawer.dart';
import 'package:interspeed_attendance_app/utils/custom_container.dart';
import 'package:shimmer/shimmer.dart';

import 'utils/layout_size.dart';

class ActivityPage extends StatelessWidget {
  final String userId;
  final String employeeId;

  // final LeaveListController controller = Get.put(LeaveListController());
  const ActivityPage(
      {required this.userId, required this.employeeId, super.key});

  Widget shimmerLoading() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF333333),
      highlightColor: const Color(0xFF1a1a1a),
      child: Container(
        width: double.infinity,
        height: 150, // Adjust the height as needed
        decoration: const BoxDecoration(
          color: Color(0xff333333),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showDialog(
      BuildContext context, String title, String message, int statusCode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF333333),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white),
              ),
              Icon(
                statusCode == 200 ? Icons.check : Icons.error,
                color: statusCode == 200 ? Colors.green : Colors.red,
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    AppLayout layout = AppLayout(context: context);
    return SafeArea(
      child: Scaffold(
        drawer: MyDrawer(context: context),
        backgroundColor: const Color(0xff1a1a1a),
        body: const Column(
          children: [
            CustomContainer(
              title: "Today's Activity",
              titleColor: Color(0xff00a0b0),
              items: [
                {"label": "In Time", "value": "08:00 AM"},
                {"label": "Exit Time", "value": "06:00 PM"},
                // Add more items as needed
              ],
            ),
            SizedBox(height: 20,),
            CustomContainer(
              title: "This Month Activity",
              titleColor: Colors.blueAccent,
              items: [
                {"label": "Present", "value": "21 days"},
                {"label": "Late", "value": "3 days"},
                // Add more items as needed
              ],
            ),
            SizedBox(height: 20,),
            CustomContainer(
              title: "This Year Activity",
              titleColor: Color(0xfffec34f),
              items: [
                {"label": "Absent", "value": "18 days"},
                {"label": "Medical Leave", "value": "9 taken 6 left"},
                {"label": "Casual Leave", "value": "7 taken 5 left"},
                {"label": "Other Leave", "value": "2 taken 3 left"},
                // Add more items as needed
              ],
            ),
            SizedBox(height: 20,),
            CustomContainer(
              title: "Participated Project",
              titleColor: Colors.deepOrangeAccent,
              items: [
                {"label": "Total", "value": "5 projects"},
                {"label": "Minor", "value": "2"},
                {"label": "Major", "value": "3"},
                // Add more items as needed
              ],
            ),
          ],
        ),
      ),
    );
  }
}
