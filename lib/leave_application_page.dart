import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'controller/leave_application_controller.dart';
import 'drawer.dart';
import 'utils/layout_size.dart';

class LeaveApplicationPage extends StatelessWidget {
  final LeaveApplicationController controller =
      Get.put(LeaveApplicationController());


  @override
  Widget build(BuildContext context) {
    print("Called Application page");
    final layout = AppLayout(context: context);
    final double boxWidth = MediaQuery.of(context).size.width * 0.7;

    return Obx(() {
      //print("Rebuilding");
      return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xff1a1a1a),
        drawer: MyDrawer(context: context),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              const Spacer(),
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

              Container(
                width: boxWidth,
                // height: layout.getHeight(55),
                decoration: BoxDecoration(
                  color: const Color(0xffffffff),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      color: Colors.blueAccent,
                      onPressed: () => controller.selectDate(context),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => controller.selectDate(context),
                        child: TextField(
                          controller: controller.textEditingController.value,
                          enabled: false,
                          maxLines: 1,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.all(8),
                            border: OutlineInputBorder(),
                            hintText: 'Select dates',
                            hintStyle: TextStyle(
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear),
                      color: Colors.redAccent,
                      onPressed: () {
                        controller.clearSelectedDates();
                      },
                    ),
                  ],
                ),
              ),


              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  color: const Color(0xffffffff),
                  borderRadius: BorderRadius.circular(8),
                ),
                width: boxWidth,
                padding: const EdgeInsets.all(0),
                child: DropdownButtonFormField<String>(
                  onChanged: (String? newValue) {
                    controller.selectLeaveType(newValue ?? '');
                  },
                  style: const TextStyle(fontSize: 13),
                  value: controller.selectedLeaveType.value.isNotEmpty
                      ? controller.selectedLeaveType.value
                      : null,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(8),
                    labelText: controller.selectedLeaveType.value.isEmpty
                        ? 'Select Leave Type'
                        : null,
                    labelStyle:
                        const TextStyle(color: Colors.black, fontSize: 13),
                    border: const OutlineInputBorder(),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                  dropdownColor: const Color(0xFFffffff),
                  icon:
                      const Icon(Icons.arrow_drop_down, color: Colors.black),
                  items: controller.leaveTypes.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(
                            color: Colors.black, fontSize: 13),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: controller.showRemark.value,
                      onChanged: (value) {
                        controller.toggleShowRemark(value ?? false);
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

              (controller.showRemark.value)
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        width: boxWidth,
                        //height: layout.getHeight(55),
                        decoration: BoxDecoration(
                          color: const Color(0xffffffff),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: controller.remarkController.value,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          keyboardType: TextInputType.multiline,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.all(8),
                            hintStyle: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Color(0xff808080),
                            ),
                            border: OutlineInputBorder(),
                            hintText: 'Remark...',
                          ),
                        ),
                      ),
                    )
                  : const SizedBox(),
              // Return an empty widget if showRemark is false,
              const Spacer(),

              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(layout.getwidth(70) / 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                clipBehavior: Clip.hardEdge,
                child: GestureDetector(
                  onTap: () async{
                    final SharedPreferences prefs = await SharedPreferences.getInstance();
                    final String userId = prefs.getString("user_id") ?? "";
                    final String employeeId = prefs.getString("employee_id") ?? "";
                    controller.submitLeaveApplication(userId, employeeId,context);
                  },
                  child: Image.asset(
                    'assets/images/Submit tickxxxhdpi.png',
                    width: 70,
                    height: 70,
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      );
    });
  }
}
