import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../controller/project_details_controller.dart';
import 'custom_loading_indicator.dart';
import 'layout_size.dart';

class AddUserDialog extends StatelessWidget {
  final List<Map<String, dynamic>> userList;
  final List<Map<String,dynamic>> projectMembers;
  final List<Map<String, dynamic>> roleList;
  final String userId;
  final String title;
  final String url;
  final Map<String, dynamic> projectDetails;
  final ProjectDetailsController controller;

  const AddUserDialog({
    Key? key,
    required this.controller,
    required this.url,
    required this.userList,
    required this.projectMembers,
    required this.roleList,
    required this.userId,
    required this.title,
    required this.projectDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    userList.removeWhere((user) =>
        projectMembers.any((member) => member['employee_id'] == user['id']));

    print("This is role list: $roleList");
    print("This is user list: $userList");
    print("This is member list: $projectMembers");
    AppLayout layout = AppLayout(context: context);
    Map<String, dynamic>? _selectedUser;
    Map<String, dynamic>? _selectedRole;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7.0),
        //color: const Color(0xff333333),
      ),
      child: AlertDialog(
        backgroundColor: const Color(0xff1a1a1a),
        title: Center(
          child: Text(
            "Add Employee",
            style: const TextStyle(color: Colors.white),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown to select user
            Visibility(
              visible: userList.isNotEmpty, // Show only if userList is not empty
              child: userList.isEmpty
                  ? Text(
                'No users left to add',
                style: const TextStyle(color: Colors.white),
              )
                  : userList.length == 1
                  ? TextFormField(
                readOnly: true,
                initialValue: userList.first['name'], // Set initial value if there is only one item
                style: const TextStyle(color: Colors.white),
              )
                  : DropdownButtonFormField<Map<String, dynamic>>(
                hint: Text(
                  'Select an employee',
                  style: const TextStyle(color: Colors.white),
                ),
                dropdownColor: const Color(0xff1a1a1a),
                value: _selectedUser,
                items: userList.map((user) {
                  return DropdownMenuItem<Map<String, dynamic>>(
                    value: user,
                    child: Text(
                      user['name'] ?? '',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  _selectedUser = value;
                  controller.setSelectedUser(value);
                },
              ),
            ),
            SizedBox(height: 20),

            Text("Select Start Date",style: TextStyle(color: Colors.white,fontSize: 16),),
            SizedBox(height: 10),
            // Date picker
            InkWell(
              onTap: () {
                _selectDate(context);
              },
              child: AbsorbPointer(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: const Color(0xff1a1a1a),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          _selectDate(context);
                        },
                        icon: Icon(
                          Icons.calendar_today,
                          color: Colors.white,
                        ),
                      ),
                      Expanded(
                        child: Obx(() => TextFormField(
                              readOnly: true,
                              style: TextStyle(
                                color: Colors.white,
                              ),
                              controller: TextEditingController(
                                text: controller.selectedDate.value != null
                                    ? DateFormat('yyyy-MM-dd')
                                        .format(controller.selectedDate.value!)
                                    : 'Select Start Date',
                              ),
                            )),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 8,),
            Visibility(
              visible: roleList.isNotEmpty, // Show only if roleList is not empty
              child: roleList.isEmpty
                  ? Text(
                'No roles left to add',
                style: const TextStyle(color: Colors.white),
              )
                  : roleList.length == 1
                  ? TextFormField(
                readOnly: true,
                initialValue: roleList.first['role'], // Set initial value if there is only one item
                style: const TextStyle(color: Colors.white),
              )
                  : DropdownButtonFormField<Map<String, dynamic>>(
                hint: Text(
                  'Select a role',
                  style: const TextStyle(color: Colors.white),
                ),
                dropdownColor: const Color(0xff1a1a1a),
                value: _selectedRole,
                items: roleList.map((role) {
                  return DropdownMenuItem<Map<String, dynamic>>(
                    value: role,
                    child: Text(
                      role['role'] ?? '',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  _selectedRole = value;
                  controller.setSelectedRole(value);
                },
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.red),
            ),
          ),
          TextButton(
            onPressed: () {
              if(userList.length == 1)controller.setSelectedUser(userList.first);
              if(roleList.length == 1)controller.setSelectedRole(roleList.first);
              if(controller.selectedDate.value == null)controller.setSelectedDate(DateTime.now());
              // Perform add operation with _selectedUser and _selectedDate
              if (controller.selectedUser.value != null &&
                  controller.selectedDate.value != null && controller.selectedRole.value != null) {
                // Add your logic to handle the selected user and date
                sendUserData(url, userId, context);
              } else {
                // Handle case when user or date is not selected
                print('User or Date not selected');
              }
            },
            child: const Text(
              'Add',
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      controller.setSelectedDate(pickedDate);
    }
  }


  // Function to send point data
  void sendUserData(
    String url,
    String userId,
    BuildContext context,
  ) async {
    print('Selected Url: $url');
    print('Sender User Id: $userId');
    String formattedStringDate = formatDate(controller.selectedDate.value.toString());
    print('Selected User: ${controller.selectedUser.value}');
    print('Selected Date: $formattedStringDate');
    print('Selected role: ${controller.selectedRole.value}');
    print('Proect Details: $projectDetails');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomLoadingIndicator();
      },
    );
    try {
      final String apiUrl = url;
      var request =
      http.MultipartRequest('POST', Uri.parse(apiUrl));

      // Add form fields
      request.fields['UserId'] = userId.toString();
      request.fields['ProjectId'] = projectDetails['project_id'].toString()?? '';
      request.fields['EmployeeId'] = controller.selectedUser.value?['id'].toString() ?? '';
      request.fields['ProjeectRoleId'] = controller.selectedRole.value?['id'].toString() ?? '';
      request.fields['DateStart'] = formattedStringDate;
      print(request.fields.toString());

      // Make the request
      final http.Response response =
      await http.Response.fromStream(await request.send());
      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          Navigator.pop(context);
          Navigator.pop(context);
          _showAlertDialog(context,'Success', responseData['message'], 200);
        } else {
          Navigator.pop(context);
          _showAlertDialog(context,'Failure', responseData['message'], 0);
        }
      } else {
        Navigator.pop(context);
        _showAlertDialog(context,'Failed',
            'Failed to submit leave request. Status code: ${response.statusCode}',
            response.statusCode);
      }
    } catch (error) {
      Navigator.pop(context);
      _showAlertDialog(context,'Failed', 'Error submitting leave request: $error', 0);
    }
  }

  void _showAlertDialog(BuildContext context,String title, String message, int statusCode) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF333333),
        title: Container(
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
              controller.isRefreshing.value = true;
              Get.back();
            },
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
      ),
    );
  }

  String formatDate(String dateString) {
    // Split the date string by space
    List<String> parts = dateString.split(' ');

    // Take the first part containing the date
    String datePart = parts[0];

    return datePart;
  }
}
