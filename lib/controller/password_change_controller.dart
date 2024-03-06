import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../utils/custom_loading_indicator.dart';

class PasswordChangeController extends GetxController {
  final RxString userId = ''.obs;
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmNewPasswordController =
  TextEditingController();
  final RxBool oldObscureText = true.obs;
  final RxBool newObscureText = true.obs;
  final RxBool confirmObscureText = true.obs;

  final GlobalKey<FormState> passwordFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
  }

  void setUserId(String id) {
    userId.value = id;
  }

  void toggleOldObscureText() {
    oldObscureText.value = !oldObscureText.value;
  }

  void toggleNewObscureText() {
    newObscureText.value = !newObscureText.value;
  }

  void toggleConfirmObscureText() {
    confirmObscureText.value = !confirmObscureText.value;
  }

  bool validateFields(BuildContext context) {
    if (oldPasswordController.text.isEmpty || newPasswordController.text.isEmpty || confirmNewPasswordController.text.isEmpty) {
      Navigator.pop(context);
      _showAttendanceDialog(context, "Error", "Please enter required fields", 0);
      return false;
    }

    if (newPasswordController.text != confirmNewPasswordController.text) {
      Navigator.pop(context);
      _showAttendanceDialog(context, "Error", "New Password and Confirm New Password do not match", 0);
      return false;
    }

    return true;
  }


  Future<void> submitForm(BuildContext context) async {

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomLoadingIndicator();
      },
    );
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userPassword = prefs.getString("user_password") ?? "";

    if (validateFields(context)){
      print("true");
      if(userPassword != oldPasswordController.text){
        Navigator.pop(context);
        _showAttendanceDialog(
            context, "Failure", "Enter correct password. If you forget the password, please contact with administration for recovery.", 0);
        return ;
      }
        // Access values using controllers
        String userIdValue = userId.value;
        String oldPasswordValue = oldPasswordController.text;
        String newPasswordValue = newPasswordController.text;

        // Create a multipart request
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('https://br-isgalleon.com/api/login/new_pass.php'),
        );

        // Add fields to the request
        request.fields['UserId'] = userIdValue;
        request.fields['OldPassword'] = oldPasswordValue;
        request.fields['NewPassword'] = newPasswordValue;

        try {
          final response =
          await http.Response.fromStream(await request.send());
          if (response.statusCode == 200) {
            // Parse the JSON response
            Map<String, dynamic> jsonResponse = json.decode(response.body);
            bool success = jsonResponse['success'];

            if (success) {
              Navigator.pop(context);
              prefs.setString("user_password", newPasswordController.text);
              print(newPasswordController.text);
              clearFields();
              _showAttendanceDialog(
                  context, "Success", "Password changed successfully", 200);
            } else {
              Navigator.pop(context);
              String message = jsonResponse['message'];
              _showAttendanceDialog(context, "Failed", message, 0);
            }
          } else {
            Navigator.pop(context);
            _showAttendanceDialog(
                context, "Failed", "Error: ${response.statusCode}", 0);
          }
        } catch (error) {
          Navigator.pop(context);
          _showAttendanceDialog(
              context, "Error", "Network or other error occurred", 0);
        }
      }
  }

  void clearFields() {
    oldPasswordController.clear();
    newPasswordController.clear();
    confirmNewPasswordController.clear();
  }

  @override
  void dispose() {
    clearFields();
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
    super.dispose();
  }

  void _showAttendanceDialog(
      BuildContext context, String title, String message, int statusCode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
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
                Navigator.pop(context);
              },
              child: const Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        );
      },
    );
  }
}
