import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProjectListController extends GetxController {
  RxList<Map<String, dynamic>> projects = <Map<String, dynamic>>[].obs;

  void setProjects(List<Map<String, dynamic>> applications) {
    projects.assignAll(applications);
  }

  Future<List<Map<String, dynamic>>> fetchProjects(BuildContext context,String userId, String employeeId) async {
    try {
      // Your API endpoint for projects
      final String projectsUrl =
          'https://br-isgalleon.com/api/project_member/get_project_member.php';
      final Uri uri = Uri.parse(projectsUrl);

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
          // Sort the resultList by the 'submit_date' field
          // resultList.sort((a, b) => DateTime.parse(b['submit_date']).compareTo(DateTime.parse(a['submit_date'])));
          setProjects(resultList);
          return resultList;
        } else {
          // Handle API response indicating failure
          //_showDialog(context, "Error", "Failed to load projects.",0);
          return [];
        }
      } else {
        // Handle non-200 status code
        _showDialog(
            context,
            "Error",
            "Failed to load projects. Status code: ${response.statusCode}",0
        );
        return [];
      }
    } catch (error) {
      // Handle other errors
      _showDialog(context, "Error", "Error loading projects: $error",0);
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
}