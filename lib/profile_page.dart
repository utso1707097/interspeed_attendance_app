import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'drawer.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> excludedKeys = ['id','picture_name' ,'sbu_id','department_id' ,'designation_id','is_active', 'created_by', 'updated_by', 'update_time'];
    return Scaffold(
      backgroundColor: Color(0xff1a1a1a),
      drawer: FutureBuilder(
        future: getFullNameFromSharedPreferences(),
        builder: (context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Loading state
            return ShimmerLoading(context: context);
          } else if (snapshot.hasError) {
            // Error state
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            // Data loaded successfully
            return MyDrawer(context: context,);
          }
        },
      ),

      body: FutureBuilder(
        future: fetchUserData(context),
        builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Loading state
            //return Center(child: CircularProgressIndicator());
            return ShimmerLoading(context: context);
          } else if (snapshot.hasError) {
            // Error state
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            // Data loaded successfully
            //return ShimmerLoading(context: context);
            final resultList = snapshot.data!;
            return SingleChildScrollView(
              child: Container(
                color: const Color(0xff1a1a1a),
                width: double.infinity,
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.25,
                      decoration: const BoxDecoration(
                        color: Color(0xff333333),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          resultList[0]['picture_name'] != ""
                              ? Image.network(
                            'https://br-isgalleon.com/image_ops/employee/${resultList[0]['picture_name'].toString()}',
                            width: MediaQuery.of(context).size.width * 0.2,
                            height: MediaQuery.of(context).size.height * 0.2,
                          )
                              : Image.asset(
                            'assets/images/logo.jpg',
                            width: MediaQuery.of(context).size.width * 0.2,
                            height: MediaQuery.of(context).size.height * 0.2,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                resultList[0]['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                resultList[0]['designation_name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 13,
                                  color: Colors.white,
                                ),
                              ),
                              const Text(
                                "Interspeed Marketing Solutions Ltd",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Column(
                      children: resultList[0].keys.where((key) => !excludedKeys.contains(key)).map((key) {
                        String value = resultList[0][key] ?? '';

                        if (value.isNotEmpty) {
                          return Card(
                            color: const Color(0xFF333333),
                            child: ListTile(
                              title: Text(
                                key,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                value,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                        } else {
                          return Container();
                        }
                      }).toList(),
                    ),
                    // Add more widgets as needed based on resultList
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget ShimmerLoading({required BuildContext context}) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF333333),
      highlightColor: const Color(0xFF1a1a1a),
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.25,
        decoration: const BoxDecoration(
          color: Color(0xff333333),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
      ),
    );
  }

  // Replace this with your actual function for fetching user data
  Future<List<Map<String, dynamic>>> fetchUserData(BuildContext context) async {
    try {
      final String profileDataUrl =
          'https://br-isgalleon.com/api/employee/get_employee_by_id.php';
      final Uri uri = Uri.parse(profileDataUrl);
      final map = <String, dynamic>{};
      SharedPreferences prefs = await SharedPreferences.getInstance();

      map['EmployeeId'] = prefs.getString('employee_id') ?? '0';
      map['UserId'] = prefs.getString('user_id') ?? '0';

      final http.Response response = await http.post(
        uri,
        body: map,
      );

      print("Request data: $map");
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the data
        final Map<String, dynamic> userData = json.decode(response.body);
        print('User data: $userData');

        if (userData['success'] == true) {
          List<Map<String, dynamic>> resultList =
          (userData['resultList'] as List<dynamic>)
              .map((item) => Map<String, dynamic>.from(item))
              .toList();

          return resultList;
        } else {
          // If the server indicates failure, return an empty list or handle it accordingly
          print('Failed to load user data. Success is false.');
          _showAttendacneDialog(context,"Failed", "User data not available", 0);
          return [];
        }
      } else {
        // If the server did not return a 200 OK response,
        // handle the error accordingly (you might want to show an error message)
        print('Failed to load user data. Status code: ${response.statusCode}');
        _showAttendacneDialog(
          context,
          "Error",
          "Failed to load user data. Status code: ${response.statusCode}",
          0,
        );
        return [];
      }
    } catch (error) {
      // Handle errors
      print('Error getting user data: $error');
      _showAttendacneDialog(context,"Error", "Error getting user data: $error", 0);
      return [];
    }
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

  Future<String> getFullNameFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('full_name') ?? "Guest";
  }


}
