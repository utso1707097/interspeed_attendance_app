import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class PasswordChangeController extends GetxController {
  final RxString userId = ''.obs;
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmNewPasswordController = TextEditingController();
  final RxBool oldObscureText = true.obs;
  final RxBool newObscureText = true.obs;
  final RxBool confirmObscureText = true.obs;

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
    if (newPasswordController.text.isEmpty || confirmNewPasswordController.text.isEmpty) {
      print('Please fill in all fields');
      _showAttendacneDialog(context,"Failed","Please fill in all fields",0);
      return false;
    }

    if (newPasswordController.text != confirmNewPasswordController.text) {
      print('New password and confirm password do not match');
      _showAttendacneDialog(context,"Failed","New password and confirm password do not match",0);
      return false;
    }

    return true;
  }

  void submitForm(BuildContext context) async {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }

    if (validateFields(context)) {
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

      // Send the request
      try {
        var response = await request.send();
        if (response.statusCode == 200) {
          // Handle successful response
          clearFields();
          _showAttendacneDialog(context, "Success", "Password changed successfully", 200);
          // print('Password change logic for user ID: $userIdValue');
        } else {
          // Handle error response
          _showAttendacneDialog(context, "Failed", "Error: ${response.statusCode}", 0);
          // print('Error: ${response.statusCode}');
        }
      } catch (error) {
        // Handle network or other errors
        _showAttendacneDialog(context, "Error", "Network or other error occurred", 0);
        //print('Error: $error');
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
    // Dispose of controllers to avoid memory leaks
    clearFields();
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
    super.dispose();
  }

  void _showAttendacneDialog(BuildContext context,String title, String message, int statusCode) {
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
}
