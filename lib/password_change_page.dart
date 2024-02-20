import 'package:flutter/material.dart';
import 'package:interspeed_attendance_app/drawer.dart';
import 'package:interspeed_attendance_app/utils/layout_size.dart';

class PasswordChangeForm extends StatefulWidget {
  @override
  final String userId;
  PasswordChangeForm({required this.userId});
  _PasswordChangeFormState createState() => _PasswordChangeFormState();
}

class _PasswordChangeFormState extends State<PasswordChangeForm> {
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmNewPasswordController = TextEditingController();
  bool _obscureText = true;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final layout = AppLayout(context: context);
    return Scaffold(
      drawer: MyDrawer(context: context,),
      backgroundColor: Color(0xff1a1a1a),
      body: Center(
        child: SingleChildScrollView(
          //controller: scrollController,
          child: Container(
            height: layout.getScreenHeight(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Update your password",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w400,color: Colors.white),),
                const SizedBox(height: 16,),
                buildPasswordField(layout,oldPasswordController, 'Old Password'),
                const SizedBox(height: 8,),
                buildPasswordField(layout,newPasswordController, 'New Password'),
                const SizedBox(height: 8,),
                buildPasswordField(layout,confirmNewPasswordController, 'Confirm New Password'),
                const SizedBox(height: 8,),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    if (validateFields()) {
                      // Perform the password change logic here
                      // Access values using controllers: oldPasswordController.text, newPasswordController.text, confirmNewPasswordController.text
                      print('Password change logic');
                    }
                  },
                  child: Image.asset('assets/images/Submit tickxxxhdpi.png',width: 70,height: 70,), // Replace with your image asset
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPasswordField(AppLayout layout,TextEditingController controller, String hintText) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: layout.getHeight(50),
      width: MediaQuery.of(context).size.width *0.7,
      child: TextField(
        controller: controller,
        obscureText: _obscureText,
        cursorColor: Colors.black,
        // focusNode: focusNode,
        decoration: InputDecoration(
          suffixIcon: GestureDetector(
            onTap: () {
              setState(() {
                _obscureText = !_obscureText;
              });
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
            borderRadius: BorderRadius.circular(
                6.0), // Adjust the radius as needed
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
  }

  // void _scrollToTextField(TextEditingController controller) {
  //   // Calculate the scroll offset to the focused TextField
  //   double offset = scrollController.position.maxScrollExtent +
  //       controller.selection.extentOffset * 20.0; // Adjust the multiplier as needed
  //
  //   // Scroll to the calculated offset with animation
  //   scrollController.animateTo(
  //     offset,
  //     duration: Duration(milliseconds: 500),
  //     curve: Curves.easeInOut,
  //   );
  // }

  bool validateFields() {
    // Implement your validation logic here
    // For example, you can check if newPassword and confirmNewPassword match
    if (newPasswordController.text.isEmpty || confirmNewPasswordController.text.isEmpty) {
      // Show an error message or handle the validation failure
      print('Please fill in all fields');
      return false;
    }

    if (newPasswordController.text != confirmNewPasswordController.text) {
      // Show an error message or handle the validation failure
      print('New password and confirm password do not match');
      return false;
    }

    // Additional validation logic can be added as needed

    return true; // All validations passed
  }
}
