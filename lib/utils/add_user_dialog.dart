import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/project_details_controller.dart';
import 'layout_size.dart';

class AddUserDialog extends StatelessWidget {
  final List<Map<String, dynamic>> userList;
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
    required this.roleList,
    required this.userId,
    required this.title,
    required this.projectDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("This is role list: $roleList");
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
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
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
                },
              ),
            ),
            SizedBox(height: 20),
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
                                    : 'Select Date',
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
              // Perform add operation with _selectedUser and _selectedDate
              if (_selectedUser != null &&
                  controller.selectedDate.value != null && _selectedRole != null) {
                // Add your logic to handle the selected user and date
                sendUserData(url, userId, _selectedUser,_selectedRole,
                    controller.selectedDate.value, context);
                print('Selected User: $_selectedUser');
                print('Selected Date: ${controller.selectedDate.value}');
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
    Map<String, dynamic>? selectedUser,
      Map<String, dynamic>? selectedRole,
    DateTime? selectedDate,
    BuildContext context,
  ) async {
    // Your implementation here
  }
}
