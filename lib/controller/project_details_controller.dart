import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProjectDetailsController extends GetxController {
  RxList<Map<String, dynamic>> projectMembers = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> allUserList = <Map<String,dynamic>>[].obs;
  // This RxBool will be used to trigger a refresh
  RxBool isRefreshing = false.obs;
  Rx<DateTime?> selectedDate = Rx<DateTime?>(DateTime.now());
  // Rx variable to hold the selected user
  Rx<Map<String, dynamic>?> selectedUser = Rx<Map<String, dynamic>?>(null);
  Rx<Map<String, dynamic>?> selectedRole = Rx<Map<String, dynamic>?>(null);
  // Method to set the selected user
  void setSelectedUser(Map<String, dynamic>? user) {
    selectedUser.value = user;
  }

  // Method to set the selected role
  void setSelectedRole(Map<String, dynamic>? role) {
    selectedRole.value = role;
  }
  // Function to toggle the refresh state
  void toggleRefresh() {
    isRefreshing.toggle();
  }

  void setSelectedDate(DateTime? date) {
    selectedDate.value = date;
  }

  void setprojectMembers(List<Map<String, dynamic>> applications) {
    projectMembers.assignAll(applications);
  }

  void setAllUserList(List<Map<String, dynamic>> users) {
    allUserList.assignAll(users);
  }

  Future<List<Map<String, dynamic>>>fetchContributeScale(String userId, BuildContext context) async {
    try{
      final String userUrl =
          'https://br-isgalleon.com/api/contribution_scale/get_contribution_scale.php';
      final Uri uri = Uri.parse(userUrl);
      final map = <String, dynamic>{};
      map['UserId'] = userId;
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
          print("Executing this success true");
          List<Map<String, dynamic>> resultList =
          (responseData['resultList'] as List<dynamic>)
              .map((item) => {
            'id': item['id'],
            'name': item['name'],
          })
              .toList();
          // Sort the resultList by the 'submit_date' field
          // resultList.sort((a, b) => DateTime.parse(b['submit_date']).compareTo(DateTime.parse(a['submit_date'])));
          // setAllUserList(resultList);
          print("this is scale list: $resultList");
          return resultList;
        } else {
          // Handle API response indicating failure
          //_showDialog(context, "Error", "Failed to load projectMembers.",0);
          return [];
        }
      } else {
        // Handle non-200 status code
        _showDialog(
            context,
            "Error",
            "Failed to load projectMembers. Status code: ${response.statusCode}",0
        );
        return [];
      }
    } catch (error) {
      print("Catch Executing");
      // Handle other errors
      _showDialog(context, "Error", "Error loading projectMembers: $error",0);
      return [];
    }
  }

  Future<List<Map<String, dynamic>>>fetchUserList(String userId, BuildContext context) async {
    try{
      final String userUrl =
          'https://br-isgalleon.com/api/employee/get_employee.php';
      final Uri uri = Uri.parse(userUrl);
      final map = <String, dynamic>{};
      map['UserId'] = userId;
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
              .map((item) => {
            'id': item['id'],
            'name': item['name'],
            'sbu' : item['sbu_name'],
          })
              .toList();
          // Sort the resultList by the 'submit_date' field
          // resultList.sort((a, b) => DateTime.parse(b['submit_date']).compareTo(DateTime.parse(a['submit_date'])));
          setAllUserList(resultList);
          return resultList;
        } else {
          // Handle API response indicating failure
          //_showDialog(context, "Error", "Failed to load projectMembers.",0);
          return [];
        }
      } else {
        // Handle non-200 status code
        _showDialog(
            context,
            "Error",
            "Failed to load projectMembers. Status code: ${response.statusCode}",0
        );
        return [];
      }
    } catch (error) {
      // Handle other errors
      _showDialog(context, "Error", "Error loading projectMembers: $error",0);
      return [];
    }
  }

  Future<List<Map<String, dynamic>>>fetchRoleList(String userId, BuildContext context) async {
    try{
      final String userUrl =
          'https://br-isgalleon.com/api/project_role/get_project_role.php';
      final Uri uri = Uri.parse(userUrl);
      final map = <String, dynamic>{};
      map['UserId'] = userId;
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
              .map((item) => {
            'id': item['id'],
            'role': item['name'],
          })
              .toList();
          // Sort the resultList by the 'submit_date' field
          // resultList.sort((a, b) => DateTime.parse(b['submit_date']).compareTo(DateTime.parse(a['submit_date'])));
          resultList.removeWhere((item) => item['id'] == 1 && item['role'] == 'Manager');
          setAllUserList(resultList);
          return resultList;
        } else {
          // Handle API response indicating failure
          //_showDialog(context, "Error", "Failed to load projectMembers.",0);
          return [];
        }
      } else {
        // Handle non-200 status code
        _showDialog(
            context,
            "Error",
            "Failed to load projectMembers. Status code: ${response.statusCode}",0
        );
        return [];
      }
    } catch (error) {
      // Handle other errors
      _showDialog(context, "Error", "Error loading projectMembers: $error",0);
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchProjectMembers(BuildContext context,String userId, String projectId) async {
    try {
      // Your API endpoint for projects
      final String projectsUrl =
          'https://br-isgalleon.com/api/project_member/get_project_member.php';
      final Uri uri = Uri.parse(projectsUrl);

      final map = <String, dynamic>{};
      // Assuming you have SharedPreferences initialized
      map['UserId'] = userId;
      map['ProjectId'] = projectId;

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
          setprojectMembers(resultList);

          return resultList;
        } else {
          // Handle API response indicating failure
          //_showDialog(context, "Error", "Failed to load projectMembers.",0);
          return [];
        }
      } else {
        // Handle non-200 status code
        _showDialog(
            context,
            "Error",
            "Failed to load projectMembers. Status code: ${response.statusCode}",0
        );
        return [];
      }
    } catch (error) {
      // Handle other errors
      _showDialog(context, "Error", "Error loading projectMembers: $error",0);
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