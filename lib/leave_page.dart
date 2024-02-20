import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:interspeed_attendance_app/drawer.dart';
import 'package:interspeed_attendance_app/leave_application_page.dart';
import 'package:interspeed_attendance_app/utils/layout_size.dart';
import 'package:shimmer/shimmer.dart';

class LeaveApplicationListPage extends StatelessWidget {
  final String userId;
  final String employeeId;

  LeaveApplicationListPage({required this.userId, required this.employeeId});

  Widget shimmerLoading(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF333333),
      highlightColor: const Color(0xFF1a1a1a),
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.25,
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

  Future<List<Map<String, dynamic>>> fetchLeaveApplications(BuildContext context,String userId, String employeeId) async {
    try {
      // Your API endpoint for leave applications
      final String leaveApplicationsUrl =
          'https://br-isgalleon.com/api/leave/get_leave_submit.php';
      final Uri uri = Uri.parse(leaveApplicationsUrl);

      final map = <String, dynamic>{};
      // Assuming you have SharedPreferences initialized
      map['UserId'] = userId;
      map['EmployeeId'] = employeeId;

      final http.Response response = await http.post(
        uri,
        body: map,
      );

      print("Request data: $map");
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print('Response data: $responseData');

        if (responseData['success'] == true) {
          List<Map<String, dynamic>> resultList =
          (responseData['resultList'] as List<dynamic>)
              .map((item) => Map<String, dynamic>.from(item))
              .toList();

          return resultList;
        } else {
          // Handle API response indicating failure
          _showDialog(context, "Error", "Failed to load leave applications.",0);
          return [];
        }
      } else {
        // Handle non-200 status code
        _showDialog(
          context,
          "Error",
          "Failed to load leave applications. Status code: ${response.statusCode}",0
        );
        return [];
      }
    } catch (error) {
      // Handle other errors
      _showDialog(context, "Error", "Error loading leave applications: $error",0);
      return [];
    }
  }

  void _showDialog(BuildContext context, String title, String message,int statusCode) {
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
    return Scaffold(
      drawer: MyDrawer(context: context,),
      backgroundColor: const Color(0xff1a1a1a),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchLeaveApplications(context,userId,employeeId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            final leaveApplications = snapshot.data ?? [];

            return Column(
              children: [
                SizedBox(
                  height: layout.getHeight(50),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Handle button press
                        fetchLeaveApplications(context, userId, employeeId);
                        _showDialog(context, "Success", "Successfully refreshed the page",200);
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red,
                      ),
                      child: const Text('Refresh',style: TextStyle(color: Colors.white),),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Handle button press
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LeaveApplicationPage(userId: userId, employeeId: employeeId),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red,
                      ),
                      child:  const Text('Apply',style: TextStyle(color: Colors.white),),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
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
                            padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 16),
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xff333333), // Move tileColor to BoxDecoration
                                borderRadius: BorderRadius.circular(15.0), // Adjust the radius as needed
                              ),
                              child: ListTile(
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Submit Date: $submitDate', style: const TextStyle(color: Colors.white)),
                                        Text(
                                          '$leave_status_name',
                                          style: TextStyle(
                                            color: leave_status_name == 'Pending'
                                                ? Colors.yellow
                                                : (leave_status_name == 'Accepted' ? Colors.green : Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text('Reason: $reasonOfLeave', style: const TextStyle(color: Colors.white)),
                                    Text('Leave Type: $leaveTypeName', style: const TextStyle(color: Colors.white)),
                                    Text('No of days: $leave_days_count',style: const TextStyle(color: Colors.white)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
