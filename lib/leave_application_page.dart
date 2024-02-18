import 'package:flutter/material.dart';
import 'package:interspeed_attendance_app/drawer.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class LeaveApplicationPage extends StatefulWidget {
  @override
  _LeaveApplicationPageState createState() => _LeaveApplicationPageState();
}

class _LeaveApplicationPageState extends State<LeaveApplicationPage> {
  String _selectedDate = '';


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(context: context,),
      body: Container(
        color: const Color(0xff1a1a1a),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(padding: EdgeInsets.all(8),
                child: Center(
                  child: Text(
                   "Pick Dates",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16
                  ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xff333333),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Theme(
                    data: ThemeData(
                      brightness: Brightness.dark, // Use dark theme
                      primaryColor: Colors.white, // Set the color of month and year text
                      dialogBackgroundColor: const Color(0xff333333), // Set the color of date picker dialog
                    ),
                    child: SfDateRangePicker(
                      view: DateRangePickerView.month,
                      monthViewSettings: const DateRangePickerMonthViewSettings(firstDayOfWeek: 1),
                      selectionMode: DateRangePickerSelectionMode.range,
                      // showActionButtons: true,
                    ),
                  ),
                ),
              ),


              const SizedBox(height: 16), // Add some spacing between the date picker and the text field
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  color: Color(0xff333333),
                  child: const TextField(
                    maxLines: 6, // Allow multiple lines
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Write your leave application here...',
                      hintStyle: TextStyle(
                        color: Colors.white,
                      )
                      // You can customize the appearance of the text field
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

