import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:interspeed_attendance_app/dashboard_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    width: MediaQuery.of(context).size.width *
                        0.8, // Adjust the percentage as needed
                    height: 70,
                    child: TextFormField(
                        controller: usernameController,
                        decoration: const InputDecoration(
                          helperText: ' ',
                          // Non-empty helper text to reserve space
                          helperMaxLines: 1,
                          //contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "Username",
                          hintStyle: TextStyle(
                            fontSize: 16,
                          ),
                          prefixIcon: Icon(
                            Icons.person,
                            color: const Color(0xff010080),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          } else if (value.contains(RegExp(r'\d'))) {
                            return 'Username cannot contain numbers';
                          }
                          return null;
                        }),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    width: MediaQuery.of(context).size.width *
                        0.8, // Adjust the percentage as needed
                    height: 70,
                    child: TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                            helperText: ' ',
                            // Non-empty helper text to reserve space
                            helperMaxLines: 1,
                            // contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
                            filled: true,
                            fillColor: Colors.white,
                            hintText: "Password",
                            hintStyle: TextStyle(
                              fontSize: 16,
                            ),
                            prefixIcon: Icon(
                              Icons.key,
                              color: Color(0xff010080),
                            ),
                            suffixIcon: Icon(
                              Icons.lock,
                              color: Color(0xff010080),
                            )),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        }),
                  ),
                  Stack(children: [
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _submitForm(); // Assuming _submitForm is an asynchronous function
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please fill input')),
                          );
                        }
                      },
                      child: const Text(
                        'Submit',
                        style: TextStyle(
                          color: Color(0xff010080),
                        ),
                      ),
                    ),
                    if (_isLoading)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.5),
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xff010080)),
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
    );
  }

  void _submitForm() async {
    String username = usernameController.text.trim();
    String password = passwordController.text;

    try {
      FocusScope.of(context).unfocus();
      setState(() {
        _isLoading = true;
      });
      var url = Uri.parse('https://br-isgalleon.com/api/login/login.php');
      var request = http.MultipartRequest('POST', url);

      request.fields['LoginId'] = username;
      request.fields['LoginPassword'] = password;

      var response = await http.Response.fromStream(await request.send());
      var jsonResponse = json.decode(response.body);
      setState(() {
        _isLoading = false;
      });
      if (response.statusCode == 200) {
        bool loginSuccess = json.decode(response.body)['success'];
        if (loginSuccess) {
          print('Login successful! Response: ${response.body}');
          var sessionData = jsonResponse['sessionData'];
          await saveSessionData(sessionData);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DashboardPage(sessionData: sessionData),
            ),
          );
        } else {
          _showLoginFailedDialog();
        }
      } else {
        print('Login failed! Status Code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> saveSessionData(Map<String, dynamic> sessionData) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('seen', true);
      prefs.setString('user_id', sessionData['user_id']);
      prefs.setString('user_name', sessionData['user_name']);
      prefs.setString('full_name', sessionData['full_name']);
      prefs.setString('user_type_id', sessionData['user_type_id']);
      prefs.setString('picture_name', sessionData['picture_name']);
      prefs.setString('user_type_name', sessionData['user_type_name']);
      prefs.setString('employee_id', sessionData['employee_id']);
      prefs.setString('designation_id', sessionData['designation_id']);
      prefs.setString(
          'employee_position_id', sessionData['employee_position_id']);
    } catch (error) {
      print('Error saving session data: $error');
    }
  }

  void _showLoginFailedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Login Failed'),
          content: Text(
            'Invalid username or password. Please try again.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

// https://br-isgalleon.com/login/login.php
