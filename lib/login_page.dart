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
  final _formKey = GlobalKey<FormState>();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 36, 159, 233),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: TextFormField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Enter your username",
                      hintStyle: TextStyle(
                        fontSize: 20,
                      ),
                      prefixIcon: Icon(
                        Icons.person,
                        color: Colors.deepPurple,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }else if (value.contains(RegExp(r'\d'))) {
                        return 'Username cannot contain numbers';
                      }
                      return null;
                    }),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Enter your password",
                        hintStyle: TextStyle(
                          fontSize: 20,
                        ),
                        prefixIcon: Icon(
                          Icons.person,
                          color: Colors.deepPurple,
                        ),
                        suffixIcon: Icon(
                          Icons.lock,
                          color: Colors.deepPurple,
                        )),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    }),
              ),

              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 16.0),
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _submitForm();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fill input')),
                        );
                      }
                    },
                    child: const Text('Submit'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm () async{
    String username = usernameController.text.trim();
    String password = passwordController.text;

    try {
      var url = Uri.parse('https://br-isgalleon.com/api/login/login.php');
      var request = http.MultipartRequest('POST', url);

      request.fields['LoginId'] = username;
      request.fields['LoginPassword'] = password;

      var response = await http.Response.fromStream(await request.send());
      var jsonResponse = json.decode(response.body);
      if (response.statusCode == 200) {
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
      prefs.setString('employee_position_id', sessionData['employee_position_id']);
    } catch (error) {
      print('Error saving session data: $error');
    }
  }
}




// https://br-isgalleon.com/login/login.php