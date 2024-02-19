import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:interspeed_attendance_app/drawer.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:http/http.dart' as http;

class LeaveApplicationPage extends StatefulWidget {
  final String userId;
  final String employeeId;
  LeaveApplicationPage({
    required this.userId,
    required this.employeeId,
  });
  @override
  _LeaveApplicationPageState createState() => _LeaveApplicationPageState();
}

class _LeaveApplicationPageState extends State<LeaveApplicationPage> {
  List<DateTime> selectedDates = [];
  bool showRemark = false;
  TextEditingController textEditingController = TextEditingController();
  String? _selectedLeaveType;

  final List<String> _leaveTypes = [
    'Casual Leave',
    'Half Day Leave',
    'On Meeting',
    'On Training',
    'Sick Leave',
  ];

  Future<void> _selectDate(BuildContext context) async {
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
                  //color: const Color(0xff333333),
                  //color: const Color(0xff333333),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: SfDateRangePicker(
                  // showActionButtons: true,
                  view: DateRangePickerView.month,
                  // monthViewSettings: const DateRangePickerMonthViewSettings(firstDayOfWeek: 1),
                  monthViewSettings:DateRangePickerMonthViewSettings(blackoutDates:[DateTime(2020, 03, 26)],
                      weekendDays: [5],
                      //specialDates:[DateTime(2020, 03, 20),DateTime(2020, 03, 16),DateTime(2020,03,17)],
                      // showTrailingAndLeadingDates: true,
                      firstDayOfWeek: 1
                  ),
                  monthCellStyle: DateRangePickerMonthCellStyle(
                    textStyle:const TextStyle(color: Colors.white),
                    blackoutDatesDecoration: BoxDecoration(
                        color: Colors.red,
                        border: Border.all(color: const Color(0xFFF44436), width: 1),
                        shape: BoxShape.circle),
                    weekendDatesDecoration: BoxDecoration(
                        color: Colors.red,
                        border: Border.all(color: const Color(0xFFB6B6B6), width: 1),
                        shape: BoxShape.circle),
                    specialDatesDecoration: BoxDecoration(
                        color: Colors.green,
                        border: Border.all(color: const Color(0xFF2B732F), width: 1),
                        shape: BoxShape.circle),
                    blackoutDateTextStyle: const TextStyle(color: Colors.white, decoration: TextDecoration.lineThrough),
                    specialDatesTextStyle: const TextStyle(color: Colors.white),
                    todayCellDecoration: BoxDecoration(
                        color: const Color(0xFFDFDFDF),
                        border: Border.all(color: const Color(0xFFB6B6B6), width: 1),
                        shape: BoxShape.circle),
                    todayTextStyle: const TextStyle(color: Colors.white),
                  ),

                  selectionMode: DateRangePickerSelectionMode.multiple,
                  onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                    setState(() {
                      selectedDates = args.value.cast<DateTime>();
                      textEditingController.text = _getFormattedDates(selectedDates);
                      print(selectedDates);
                    });
                  },
                  headerStyle: const DateRangePickerHeaderStyle(
                    textAlign: TextAlign.center,
                    textStyle: TextStyle(color: Colors.white),
                  ),
                  showActionButtons: true,
                  todayHighlightColor: Colors.purple, // Color of today's date
                  selectionColor: Colors.green, // Color of selected dates
                  rangeSelectionColor: Colors.white.withOpacity(0.3), // Color of the range selection
                  onCancel: () {
                    setState(() {
                      selectedDates = []; // Clear the selected dates
                      print(selectedDates);
                    });
                    Navigator.of(context).pop();
                  },
                  onSubmit: (dynamic value) {
                    setState(() {
                      // Handle selected dates here if needed
                      textEditingController.text = _getFormattedDates(selectedDates);
                      print(selectedDates);
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
          ),
        );
      },
    );

  }


  String _getFormattedDates(List<DateTime> dates) {
    return dates.map((date) => date.toLocal().toString().split(' ')[0]).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final double boxHeight = MediaQuery.of(context).size.height * 0.08;
    final double boxWidth = MediaQuery.of(context).size.width * 0.7;
    return Scaffold(
      backgroundColor: const Color(0xff1a1a1a),
      drawer: MyDrawer(context: context),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 48,
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "Leave Application Form",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                width: boxWidth,
                height: boxHeight,
                decoration: BoxDecoration(
                  color: const Color(0xff333333),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      color: Colors.white,
                      onPressed: () => _selectDate(context),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectDate(context),
                        child: TextField(
                          controller: textEditingController,
                          enabled: false,
                          maxLines: 1,
                          style: const TextStyle(color: Colors.white,fontSize: 13,),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Select dates',
                            hintStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear),
                      color: Colors.white,
                      onPressed: () {
                        setState(() {
                          selectedDates = []; // Clear the selected dates
                          textEditingController.text = ''; // Clear the text field
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                width: boxWidth,
                height: boxHeight,
                padding: const EdgeInsets.all(0),
                child: DropdownButtonFormField<String>(
                  value: _selectedLeaveType,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedLeaveType = newValue;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: _selectedLeaveType == null ? 'Select Leave Type' : null,
                    labelStyle: const TextStyle(color: Colors.white, fontSize: 13),
                    border: const OutlineInputBorder(),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  dropdownColor: const Color(0xFF333333),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  items: _leaveTypes.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(color: Colors.white,fontSize: 13),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    value: showRemark,
                    onChanged: (value) {
                      setState(() {
                        showRemark = value ?? false;
                      });
                    },
                  ),
                  const Text(
                    "Write remarks",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),
            if(showRemark)Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                width: boxWidth,
                height: boxHeight,
                color: const Color(0xff333333),
                child: const TextField(
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Remark...',
                    hintStyle: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: (){
                _submitLeaveApplication();
              },
              child: Image.asset(
                'assets/images/Submit tickxxxhdpi.png',
                width: 70, // Adjust the width as needed
                height: 70, // Adjust the height as needed
              ),
            )
          ],
        ),
      ),
    );
  }

  void _submitLeaveApplication() {
    if (selectedDates.isEmpty) {
      _showAlertDialog(context,'Error', 'Please select dates.',0);
    } else if (_selectedLeaveType == null) {
      _showAlertDialog(context,'Error', 'Please select leave type.',0);
    } else {
      // Add your logic for submitting the leave application here
      // ...
      // For demonstration purposes, let's print the selected data
      print('User ID: ${widget.userId}');
      print('Employee ID: ${widget.employeeId}');
      print('Selected Dates: $selectedDates');
      print('Selected Leave Type: $_selectedLeaveType');

      submitLeaveRequest(
        userId: widget.userId,
        leaveDates: selectedDates,
        employeeId: widget.employeeId,
        leaveType: _selectedLeaveType!,
        remark: textEditingController.text,
      );

      //_showAlertDialog(context,'Success', 'Leave application submitted successfully.',200);
    }
  }

  void _showAlertDialog(BuildContext context,String title, String message, int statusCode) {
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

  Future<void> submitLeaveRequest({
    required String userId,
    required List<DateTime> leaveDates,
    required String employeeId,
    required String leaveType,
    required String remark,
  }) async {
    final String apiUrl = 'https://br-isgalleon.com/api/leave/leave_submit.php';

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      // Add form fields
      request.fields['UserId'] = userId;
      request.fields['EmployeeId'] = employeeId;
      request.fields['LeaveType'] = leaveType;
      request.fields['Remark'] = remark;

      print("$userId + $employeeId + $leaveType + $remark");

      // Add leaveDates as a list of strings
      request.fields['LeaveDates'] = leaveDates.map((date) => date.toLocal().toString().split(' ')[0]).join(',');

      // Make the request
      final http.Response response = await http.Response.fromStream(await request.send());
      if (response.statusCode == 200) {
        // Successfully submitted
        Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success'] == true){
          print(response.body);
          _showAlertDialog(context,'Success' ,responseData['message'],200);
        }
        else{
          _showAlertDialog(context,'Failure' ,responseData['message'],0);
        }

      } else {
        // Handle other status codes
        _showAlertDialog(context, 'Failed','Failed to submit leave request. Status code: ${response.statusCode}',response.statusCode);
      }
    } catch (error) {
      // Handle exceptions
      _showAlertDialog(context,'Failed', 'Error submitting leave request: $error',0);
    }
  }

}
