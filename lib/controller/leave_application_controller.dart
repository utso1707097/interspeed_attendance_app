import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class LeaveApplicationController extends GetxController {
  RxList<DateTime> selectedDates = <DateTime>[].obs;
  RxBool showRemark = false.obs;
  RxString selectedLeaveType = ''.obs;
  Rx<TextEditingController> textEditingController =
      TextEditingController().obs;
  Rx<TextEditingController> remarkController = TextEditingController().obs;

  final List<String> leaveTypes = [
    'Casual Leave',
    'Sick Leave',
  ];
  String _getFormattedDates(List<DateTime> dates) {
    return dates
        .map((date) => date.toLocal().toString().split(' ')[0])
        .join(', ');
  }

  Future<void> selectDate(BuildContext context) async {
    final double dialogHeight = MediaQuery.of(context).size.height * 0.5;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: AlertDialog(
            backgroundColor: const Color(0xFF333333),
            content: Padding(
              padding: const EdgeInsets.all(0),
              child: Container(
                padding: const EdgeInsets.all(0),
                height: dialogHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Colors.red,
                      onPrimary: Colors.black,
                      onSurface: Colors.white,
                    ),
                    textButtonTheme: TextButtonThemeData(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.green,
                      ),
                    ),
                  ),
                  child: SfDateRangePicker(
                    view: DateRangePickerView.month,
                    monthViewSettings: DateRangePickerMonthViewSettings(
                      blackoutDates: [DateTime(2020, 03, 26)],
                      weekendDays: [5],
                      firstDayOfWeek: 1,
                    ),
                    monthCellStyle: DateRangePickerMonthCellStyle(
                      textStyle: const TextStyle(color: Colors.white),
                      blackoutDatesDecoration: BoxDecoration(
                        color: Colors.red,
                        border: Border.all(color: const Color(0xFFF44436), width: 1),
                        shape: BoxShape.circle,
                      ),
                      weekendDatesDecoration: BoxDecoration(
                        color: Colors.red,
                        border: Border.all(color: const Color(0xFFB6B6B6), width: 1),
                        shape: BoxShape.circle,
                      ),
                      specialDatesDecoration: BoxDecoration(
                        color: Colors.green,
                        border: Border.all(color: const Color(0xFF2B732F), width: 1),
                        shape: BoxShape.circle,
                      ),
                      blackoutDateTextStyle: const TextStyle(color: Colors.white, decoration: TextDecoration.lineThrough),
                      specialDatesTextStyle: const TextStyle(color: Colors.white),
                      todayCellDecoration: BoxDecoration(
                        color: const Color(0xFFDFDFDF),
                        border: Border.all(color: const Color(0xFFB6B6B6), width: 1),
                        shape: BoxShape.circle,
                      ),
                      todayTextStyle: const TextStyle(color: Colors.black),
                    ),
                    selectionMode: DateRangePickerSelectionMode.multiple,
                    onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                      selectedDates.value = args.value.cast<DateTime>();
                      textEditingController.value.text = _getFormattedDates(selectedDates.value);
                      print(selectedDates.value);
                    },
                    headerStyle: const DateRangePickerHeaderStyle(
                      textAlign: TextAlign.center,
                      textStyle: TextStyle(color: Colors.white),
                    ),
                    showActionButtons: true,
                    selectionColor: Colors.green,
                    rangeSelectionColor: Colors.white.withOpacity(0.3),
                    onCancel: () {
                      selectedDates.value = [];
                      textEditingController.value.text = '';
                      //print(selectedDates.value);
                      Navigator.of(context).pop();
                    },
                    onSubmit: (dynamic value) {
                      textEditingController.value.text = _getFormattedDates(selectedDates.value);
                      //print(selectedDates.value);
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }



  void toggleShowRemark(bool value) {
    showRemark.value = value;
  }

  void selectLeaveType(String value) {
    selectedLeaveType.value = value;
    print(selectedLeaveType);
  }

  void clearSelectedDates() {
    selectedDates.value = [];
    textEditingController.value.clear();
  }

  void clearSelectedLeaveType() {
    selectedLeaveType.value = '';
  }

  void clearRemark() {
    remarkController.value.clear();
  }

  void submitLeaveApplication(String userId, String employeeId) async {
    if (selectedDates.isEmpty) {
      _showAlertDialog('Error', 'Please select dates.', 0);
    } else if (selectedLeaveType.value.isEmpty) {
      _showAlertDialog('Error', 'Please select leave type.', 0);
    } else {
      try {
        final String apiUrl =
            'https://br-isgalleon.com/api/leave/insert_leave_submit.php';
        var request =
        http.MultipartRequest('POST', Uri.parse(apiUrl));

        // Add form fields
        request.fields['UserId'] = userId;
        request.fields['EmployeeId'] = employeeId;
        request.fields['LeaveType'] = selectedLeaveType.value;
        request.fields['Remark'] = remarkController.value.text;

        // Add leaveDates as a list of strings
        List<Map<String, String>> formattedDates =
        getFormattedDates(selectedDates);
        request.fields['LeaveDates'] = jsonEncode(formattedDates);
        print(request.fields.toString());

        // Make the request
        final http.Response response =
        await http.Response.fromStream(await request.send());
        if (response.statusCode == 200) {
          Map<String, dynamic> responseData = jsonDecode(response.body);
          if (responseData['success'] == true) {
            _showAlertDialog('Success', responseData['message'], 200);
            clearSelectedDates();
            selectedLeaveType.value = '';
            remarkController.value.clear();
            textEditingController.value.clear();
          } else {
            _showAlertDialog('Failure', responseData['message'], 0);
          }
        } else {
          _showAlertDialog('Failed',
              'Failed to submit leave request. Status code: ${response.statusCode}',
              response.statusCode);
        }
      } catch (error) {
        _showAlertDialog('Failed', 'Error submitting leave request: $error', 0);
      }
    }
  }

  void _showAlertDialog(String title, String message, int statusCode) {
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


  List<Map<String, String>> getFormattedDates(List<DateTime> dates) {
    return dates.map((date) {
      return {'LeaveDate': date.toLocal().toString().split(' ')[0]};
    }).toList();
  }
}
