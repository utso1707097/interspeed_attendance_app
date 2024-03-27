import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:interspeed_attendance_app/controller/leave_list_controller.dart';
import 'package:interspeed_attendance_app/drawer.dart';
import 'package:interspeed_attendance_app/leave_application_page.dart';
import 'package:interspeed_attendance_app/utils/layout_size.dart';
import 'package:shimmer/shimmer.dart';

class LeaveApplicationListPage extends StatelessWidget {
  final String userId;
  final String employeeId;
  final LeaveListController controller = Get.put(LeaveListController());

  LeaveApplicationListPage({required this.userId, required this.employeeId});

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
    print("Called Leave page");
    return Scaffold(
      drawer: MyDrawer(
        context: context,
      ),
      backgroundColor: const Color(0xff1a1a1a),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: controller.fetchLeaveApplications(context, userId, employeeId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Column(
              children: [
                SizedBox(
                  height: layout.getHeight(50),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        // Handle button press
                        await controller.fetchLeaveApplications(
                            context, userId, employeeId);
                        _showDialog(context, "Success",
                            "Successfully refreshed the page", 200);
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              8.0), // Adjust the radius as needed
                        ),
                        primary: const Color(0xff74c2c6), // Set to transparent to make it square
                      ),
                      child: const Text('Refresh',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Handle button press
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LeaveApplicationPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              8.0), // Adjust the radius as needed
                        ),
                        primary: const Color(0xfffed593),
                      ),
                      child: const Text('Apply',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                Expanded(
                  child: shimmerLoading(),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            final leaveApplications = controller.leaveApplications;

            return Column(
              children: [
                SizedBox(
                  height: layout.getHeight(50),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        // Handle button press
                        await controller.fetchLeaveApplications(
                            context, userId, employeeId);
                        _showDialog(context, "Success",
                            "Successfully refreshed the page", 200);
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              8.0), // Adjust the radius as needed
                        ),
                        primary: const Color(0xff74c2c6), // Set to transparent to make it square
                      ),
                      child: const Text('Refresh',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Handle button press
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LeaveApplicationPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              8.0), // Adjust the radius as needed
                        ),
                        primary: const Color(0xfffed593),
                      ),
                      child: const Text('Apply',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                Expanded(
                  child: Obx(() {
                    final leaveApplications = controller.leaveApplications;
                    return ListView.builder(
                      itemCount: leaveApplications.length,
                      itemBuilder: (context, index) {
                        final leave = leaveApplications[index];
                        final submitDate = leave['submit_date'];
                        final reasonOfLeave = leave['reason_of_leave'];
                        final leaveTypeName = leave['leave_type_name'];
                        final leave_days_count = leave['leave_days_count'];
                        final leave_status_name = leave['leave_status_name'];

                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xff333333),
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: ListTile(
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Submit Date: $submitDate',
                                              style: const TextStyle(
                                                  color: Colors.white)),
                                          Text(
                                            '$leave_status_name',
                                            style: TextStyle(
                                              color:
                                                  leave_status_name == 'Pending'
                                                      ? Colors.yellow
                                                      : (leave_status_name ==
                                                              'Accepted'
                                                          ? Colors.green
                                                          : Colors.red),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text('Reason: ${reasonOfLeave ?? ''}',
                                          style: const TextStyle(
                                              color: Colors.white)),
                                      Text('Leave Type: $leaveTypeName',
                                          style: const TextStyle(
                                              color: Colors.white)),
                                      Text('No of days: $leave_days_count',
                                          style: const TextStyle(
                                              color: Colors.white)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
