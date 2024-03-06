import 'dart:convert';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:interspeed_attendance_app/dashboard_page.dart';
import 'package:interspeed_attendance_app/utils/layout_size.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'controller/login_controller.dart';
import 'utils/custom_loading_indicator.dart';

class LoginPage extends StatelessWidget {
  final LoginController loginController = Get.put(LoginController());
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final layout = AppLayout(context: context);
    return Obx(() {
      return Scaffold(
        backgroundColor: const Color(0xff1a1a1a),
        resizeToAvoidBottomInset: true,
        body: DoubleBackToCloseApp(
          snackBar: const SnackBar(
            content: Text('Tap again to exit'),
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: layout.getHeight(250),
                decoration: BoxDecoration(
                  color: const Color(0xff333333),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(layout.getHeight(120)),
                  ),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/logo.jpg',
                    width: layout.getwidth(70),
                    height: layout.getHeight(70),
                  ),
                ),
              ),
              // Image.asset('assets/interspeed/logo_white.jpg'),
              SizedBox(
                height: layout.getHeight(8),
              ),

              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SingleChildScrollView(
                    child: AnimatedPadding(
                      padding: MediaQuery.of(context).viewInsets,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.decelerate,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 0),
                              width: MediaQuery.of(context).size.width *
                                  0.7, // Adjust the percentage as needed
                              //height: layout.getHeight(50),
                              child: TextFormField(
                                  controller: usernameController,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(vertical: 16,horizontal: 8),
                                    filled: true,
                                    fillColor: Colors.white,
                                    hintText: "your id",
                                    hintStyle: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xff808080),
                                    ),
                                    focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                    ),
                                    suffixIcon: Obx(() {
                                      return loginController.validatedUsername.value
                                          ? const SizedBox()
                                          : const Icon(
                                        Icons.error,
                                        color: Colors.red,
                                      );
                                    }),
                                    errorStyle: const TextStyle(height: 0.01),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          6.0), // Adjust the radius as needed
                                    ),
                                  ),
                              ),

                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width *
                                  0.7, // Adjust the percentage as needed
                              //height: layout.getHeight(50),
                              child: TextFormField(
                                  controller: passwordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(vertical: 16,horizontal: 8),
                                    filled: true,
                                    fillColor: Colors.white,
                                    hintText: "password",
                                    hintStyle: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xff808080)),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          6.0), // Adjust the radius as needed
                                    ),
                                    focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                    ),
                                    errorStyle: const TextStyle(height: 0.01),
                                    suffixIcon: Obx(() {
                                      return loginController.validatedPassword.value
                                          ? const SizedBox()
                                          : const Tooltip(
                                        message: 'required',
                                        child: Icon(
                                          Icons.error,
                                          color: Colors.red,
                                        ),
                                      );
                                    }),
                                  ),
                                  ),

                            ),
                            SizedBox(
                                height: MediaQuery.of(context).size.height * 0.07),
                            Stack(children: [
                              GestureDetector(
                                onTap: () async {
                                    _submitForm(context); // Assuming _submitForm is an asynchronous function
                                },
                                child: Image.asset(
                                  'assets/images/Submit tickxxxhdpi.png',
                                  width: layout.getHeight(70), // Adjust the width as needed
                                  height: layout.getHeight(70), // Adjust the height as needed
                                ),
                              ),
                              if (loginController.isLoading.value)
                                Positioned.fill(
                                  child: Container(
                                    color: Colors.black.withOpacity(0.5),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                            Color(0xff010080)),
                                      ),
                                    ),
                                  ),
                                ),
                            ]),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _submitForm(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomLoadingIndicator();
      },
    );
    String username = usernameController.text.trim();
    String password = passwordController.text;

    if (username.isEmpty) {
      // Handle empty username
      Navigator.pop(context);
      _showLoginFailedDialog(context,  'Error', 'Username cannot be empty');
      return;
    }

    if (password.isEmpty) {
      // Handle empty password
      Navigator.pop(context);
      _showLoginFailedDialog(context, 'Error', 'Password cannot be empty');
      return;
    }

    try {
      FocusScope.of(context).unfocus();
      loginController.setLoading(true);

      var url = Uri.parse('https://br-isgalleon.com/api/login/login.php');
      var request = http.MultipartRequest('POST', url);

      request.fields['LoginId'] = username;
      request.fields['LoginPassword'] = password;

      var response = await http.Response.fromStream(await request.send());
      var jsonResponse = json.decode(response.body);
      loginController.setLoading(false);

      if (response.statusCode == 200) {
        bool loginSuccess = json.decode(response.body)['success'];
        if (loginSuccess) {
          // print('Login successful! Response: ${response.body}');
          var sessionData = jsonResponse['sessionData'];
          if(sessionData["user_type_id"].toString() == "4"){
            // print("Executed");
            await saveSessionData(sessionData);
            print(sessionData);
            Navigator.pop(context);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => DashboardPage(),
              ),
            );
          }
          else{
            // print("My session data is: ${sessionData}");
            Navigator.pop(context);
            _showLoginFailedDialog(context,  'Failed',"This account is an admin account. Admins cannot log in.");
          }
        } else {
          Navigator.pop(context);
          print("${response.statusCode} ${response.body}");
          _showLoginFailedDialog(context,  'Failed',json.decode(response.body)['message']);

        }
      } else {
        Navigator.pop(context);
        _showLoginFailedDialog(context, 'Failed', json.decode(response.body)['message']);
      }
    } catch (error) {
      print('Error: $error');
      Navigator.pop(context);
      _showLoginFailedDialog(context,  'Failed', "An unexpected error occurred. Please try again later.");
    }
  }

  Future<void> saveSessionData(Map<String, dynamic> sessionData) async {
    //print(sessionData);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool("seen", true);
      print("seen: true");
      prefs.setString("user_password", passwordController.text);
      prefs.setString("user_id", sessionData["user_id"].toString() ?? "");
      prefs.setString("user_name", sessionData["user_name"].toString() ?? "");
      prefs.setString("full_name", sessionData["full_name"].toString() ?? "");
      prefs.setString("user_type_id", sessionData["user_type_id"].toString() ?? "");
      prefs.setString("user_type_name", sessionData["user_type_name"].toString() ?? "");
      prefs.setString("sb_name", sessionData["sb_name"].toString() ?? "");
      prefs.setString(
          "designation_name", sessionData["designation_name"].toString() ?? "");
      prefs.setString("access_level", sessionData["access_level"].toString() ?? "");
      prefs.setString("picture_name", sessionData["picture_name"].toString() ?? "");
      prefs.setString("employee_id", sessionData["employee_id"].toString() ?? "");
      prefs.setString("designation_id", sessionData["designation_id"].toString() ?? "");
      prefs.setString(
          "employee_position_id", sessionData["employee_position_id"].toString() ?? "");
      print(prefs.getString("user_name"));
      print("He HE he");
    } catch (error) {

      print('Error saving session data: $error');
    }
  }

  void _showLoginFailedDialog(BuildContext context,String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF333333),
          // Body color
          title: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white),
                ),
                const Icon(
                  Icons.error,
                  color: Colors.white,
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
