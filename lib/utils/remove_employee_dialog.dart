import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:interspeed_attendance_app/utils/custom_loading_indicator.dart';

class RemoveEmployeeDialog extends StatelessWidget {
  final String userId;
  final String employeeId;
  final String projectId;
  final String projectMemberId;
  final String projectRoleId;
  final String employeeName;

  const RemoveEmployeeDialog({
    Key? key,
    required this.userId,
    required this.employeeId,
    required this.projectId,
    required this.projectMemberId,
    required this.projectRoleId,
    required this.employeeName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Color(0xff1a1a1a),
      title: Text(
        'Remove $employeeName from this project?',
        style: TextStyle(color: Colors.white),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text(
            'Cancel',
            style: TextStyle(color: Colors.white),
          ),
        ),
        TextButton(
          onPressed: () async {
            // Close the dialog
            await deleteProjectMember(context, userId, employeeId, projectId,
                projectMemberId, projectRoleId);
          },
          child: Text(
            'Delete',
            style: TextStyle(color: Colors.red), // You can customize the color
          ),
        ),
      ],
    );
  }

  Future<void> deleteProjectMember(
      BuildContext context,
      String userId,
      String employeeId,
      String projectId,
      String projectMemberId,
      String projectRoleId) async {
    try {
      // Set up the URL for delete request
      final String url =
          'https://br-isgalleon.com/api/project_member/delete_project_member.php';

      // Create the multipart request
      final http.MultipartRequest request =
          http.MultipartRequest('POST', Uri.parse(url));

      // Add parameters to the request
      request.fields['UserId'] = userId;
      request.fields['EmployeeId'] = employeeId;
      request.fields['ProjectMemberId'] = projectMemberId;
      request.fields['ProjectId'] = projectId;
      request.fields['ProjeectRoleId'] = projectRoleId;

      print(
          "user id: $userId, \n"
              "Employee Id: $employeeId, \n"
              "project member Id: $projectMemberId, \n"
              "project Id: $projectId \n"
              "ProjectRoleId: $projectRoleId \n");
      // Send the request
      final http.Response response =
          await http.Response.fromStream(await request.send());

      if (response.statusCode == 200) {
        // Request was successful
        Map<String, dynamic> responseData = jsonDecode(response.body);
        print("Delete Response body: $responseData");

        // Check if deletion was successful
        if (responseData['success']) {
          showAttendanceDialog(
            context,
            'Delete Success',
            'Employee removed from project successfully.',
            response.statusCode,
          );
        } else {
          // Show failure dialog
          showAttendanceDialog(
            context,
            'Delete Failed',
            'Failed to remove employee from project.',
            response.statusCode,
          );
        }
      } else {
        // Show failure dialog due to server error
        showAttendanceDialog(
          context,
          'Delete Failed',
          'Failed to remove employee from project. Server error.',
          response.statusCode,
        );
      }
    } catch (error) {
      // Handle errors
      print('Error deleting project member: $error');
      showAttendanceDialog(
        context,
        'Error',
        'An error occurred while deleting project member.',
        500, // Assuming 500 is for internal server error
      );
    }
  }

  void showAttendanceDialog(
      BuildContext context, String title, String message, int statusCode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF333333),
          // Body color
          title: Container(
            // color: const Color(0xFF1a1a1a), // Header area color
            child: Row(
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
          ),
          content: Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(15.0), // Adjust the radius as needed
          ),
        );
      },
    );
  }
}
