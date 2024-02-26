import 'package:flutter/material.dart';
import 'package:interspeed_attendance_app/drawer.dart';
import 'package:interspeed_attendance_app/utils/layout_size.dart';
import 'package:get/get.dart';
import 'controller/password_change_controller.dart';

class PasswordChangeForm extends StatelessWidget {
  final String userId;

  PasswordChangeForm({required this.userId});
  final PasswordChangeController controller = Get.put(PasswordChangeController());

  @override
  Widget build(BuildContext context) {
    controller.setUserId(userId);
    final layout = AppLayout(context: context);
    return Scaffold(
      drawer: MyDrawer(context: context),
      backgroundColor: Color(0xff1a1a1a),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            height: layout.getScreenHeight(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Update your password",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16,),
                buildPasswordField(context, layout, 'Old Password', controller.oldObscureText),
                const SizedBox(height: 8,),
                buildPasswordField(context, layout, 'New Password', controller.newObscureText),
                const SizedBox(height: 8,),
                buildPasswordField(context, layout, 'Confirm New Password', controller.confirmObscureText),
                const SizedBox(height: 8,),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () => controller.submitForm(context),
                  child: Image.asset(
                    'assets/images/Submit tickxxxhdpi.png',
                    width: 70,
                    height: 70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPasswordField(
      BuildContext context,
      AppLayout layout,
      String hintText,
      RxBool obscureText,
      ) {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: layout.getHeight(50),
        width: MediaQuery.of(context).size.width * 0.7,
        child: TextField(
          controller: getPasswordController(hintText),
          obscureText: obscureText.value,
          cursorColor: Colors.black,
          decoration: InputDecoration(
            suffixIcon: GestureDetector(
              onTap: () {
                obscureText.toggle();
              },
              child: const Icon(
                Icons.remove_red_eye,
                color: Color(0xff808080),
              ),
            ),
            filled: true,
            fillColor: Colors.white,
            hintText: hintText,
            hintStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xff808080),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6.0),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide.none,
            ),
            errorStyle: const TextStyle(height: 0.01),
          ),
          onTap: () {
            //_scrollToTextField(controller);
          },
        ),
      );
    });
  }

  TextEditingController getPasswordController(String hintText) {
    return hintText == 'Old Password'
        ? controller.oldPasswordController
        : hintText == 'New Password'
        ? controller.newPasswordController
        : controller.confirmNewPasswordController;
  }
}
