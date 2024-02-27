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
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
                  height: layout.getHeight(55),
                  decoration: BoxDecoration(
                    color: const Color(0xff333333),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        color: Colors.white,
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
                              color: Colors.white,
                              fontSize: 13,
                            ),
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
                          controller.clearSelectedDates();
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  color: const Color(0xff333333),
                  width: boxWidth,
                  height: layout.getHeight(55),
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
                      labelText: controller.selectedLeaveType.value.isEmpty
                          ? 'Select Leave Type'
                          : null,
                      labelStyle:
                          const TextStyle(color: Colors.white, fontSize: 13),
                      border: const OutlineInputBorder(),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    dropdownColor: const Color(0xFF333333),
                    icon:
                        const Icon(Icons.arrow_drop_down, color: Colors.white),
                    items: controller.leaveTypes.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13),
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
                        height: layout.getHeight(55),
                        color: const Color(0xff333333),
                        child: TextField(
                          controller: controller.remarkController.value,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          keyboardType: TextInputType.multiline,
                          decoration: const InputDecoration(
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

              const SizedBox(height: 16),

              GestureDetector(
                onTap: () async{
                  final SharedPreferences prefs = await SharedPreferences.getInstance();
                  final String userId = prefs.getString("user_id") ?? "";
                  final String employeeId = prefs.getString("employee_id") ?? "";
                  controller.submitLeaveApplication(userId, employeeId);
                },
                child: Image.asset(
                  'assets/images/Submit tickxxxhdpi.png',
                  width: 70,
                  height: 70,
                ),
              )
            ],
          ),
        ),
      );
    });
  }
}
