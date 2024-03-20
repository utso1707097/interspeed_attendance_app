import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interspeed_attendance_app/single_project_details.dart';
import 'package:interspeed_attendance_app/utils/layout_size.dart';
import 'package:http/http.dart' as http;
import '../controller/project_details_controller.dart';
import 'custom_loading_indicator.dart';

class AddPointDialog extends StatelessWidget {
  final List<Map<String, dynamic>> resultList;
  final String userId;
  final String? projectMemberId;
  final String title;
  final String url;
  final Map<String, dynamic> projectDetails;
  final ProjectDetailsController controller;
  const AddPointDialog({Key? key, required this.controller,required this.url,required this.resultList, required this.userId, required this.title, this.projectMemberId,required this.projectDetails}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppLayout layout = AppLayout(context: context);
    Map<String, dynamic>? _selectedItem;

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
        content: DropdownButtonFormField<Map<String, dynamic>>(
          hint: Text(title,style: const TextStyle(color: Colors.white),),
          dropdownColor: const Color(0xff1a1a1a),
          items: resultList.map((item) {
            return DropdownMenuItem<Map<String, dynamic>>(
              value: item,
              child: SizedBox(
                width: layout.getHeight(200),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    item['name'] ?? '',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            _selectedItem = value;
          },
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
              // Perform add operation with _selectedItem
              if (_selectedItem != null) {
                // Add your logic to handle the selected item
                sendPointData(url,userId,projectMemberId,_selectedItem,context);
                print("Adding item: $_selectedItem");
              }
              // Navigator.of(context).pop();
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

  void sendPointData(String url,String userId, String? projectMemberId,Map<String, dynamic>? selectedItem,BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomLoadingIndicator();
      },
    );
    if (selectedItem == null) {
      Navigator.pop(context);
      _showAlertDialog(context,'Error', 'Please select dates.', 0);
    }  else {
      try {
        final String apiUrl = url;
        var request =
        http.MultipartRequest('POST', Uri.parse(apiUrl));

        // Add form fields
        request.fields['UserId'] = userId.toString();
        request.fields['ProjectMemberId'] = projectMemberId.toString()?? '';
        request.fields['ContributionScaleId'] = selectedItem['id'].toString() ?? '';
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
}
