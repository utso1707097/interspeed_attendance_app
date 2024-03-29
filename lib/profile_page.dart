import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:interspeed_attendance_app/update_profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'drawer.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> excludedKeysPersonal = ['employee_code','office_desk_location_id','date_of_departure','identity_number','department_name','date_of_join','contact_number_emergency','contact_number','email','present_address','permanent_address','tin_number','remark','designation_name','sbu_name','identity_type_name','office_name','department','designation','strategic_business_unit','identity_type','office','id','picture_name' ,'sbu_id','department_id' ,'designation_id','is_active', 'created_by', 'updated_by', 'update_time','is_identification_verified','identity_type_id'];
    List<String> excludedKeysContact = ['employee_code','office_desk_location_id','date_of_departure','identity_number','name','date_of_birth','gender','father_name','mother_name','marital_status','blood_group','religion','department_name','date_of_join','tin_number','remark','designation_name','sbu_name','identity_type_name','office_name','department','designation','strategic_business_unit','identity_type','office','id','picture_name' ,'sbu_id','department_id' ,'designation_id','is_active', 'created_by', 'updated_by', 'update_time','is_identification_verified','identity_type_id'];
    List<String> excludedKeysIdentity = ['employee_code','office_desk_location_id','date_of_departure','name','date_of_birth','gender','father_name','mother_name','marital_status','blood_group','religion','department_name','date_of_join','contact_number_emergency','contact_number','email','identity_type_name','present_address','permanent_address','remark','designation_name','sbu_name','office_name','department','designation','strategic_business_unit','office','id','picture_name' ,'sbu_id','department_id' ,'designation_id','is_active', 'created_by', 'updated_by', 'update_time','is_identification_verified','identity_type_id'];
    List<String> excludedKeysOfficial= ['office_desk_location_id','identity_number','name','date_of_birth','gender','father_name','mother_name','marital_status','blood_group','religion','department_name','contact_number_emergency','contact_number','email','present_address','permanent_address','tin_number','remark','designation_name','sbu_name','identity_type_name','office_name','identity_type','id','picture_name' ,'sbu_id','department_id' ,'designation_id','is_active', 'created_by', 'updated_by', 'update_time','is_identification_verified','identity_type_id'];

    return Scaffold(
      backgroundColor: const Color(0xff1a1a1a),
      drawer: MyDrawer(context: context,),

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
            print(resultList[0]);
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          resultList[0]['picture_name'] != ""
                              ? Image.network(
                            'https://br-isgalleon.com/image_ops/employee/${resultList[0]['picture_name'].toString()}',
                            width: MediaQuery.of(context).size.width * 0.3,
                            height: MediaQuery.of(context).size.width * 0.2,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              // Handle image loading error
                              return Image.asset('assets/images/person.png',
                                width: MediaQuery.of(context).size.width * 0.3,
                                height: MediaQuery.of(context).size.width * 0.2,
                              );
                            },
                          )
                              : Image.asset(
                            'assets/images/person.png',
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
                      height: 8,
                    ),
                    Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color:const Color(0xff74c2c6),
                        borderRadius: BorderRadius.circular(8),
                      ),

                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.symmetric(horizontal: 8,vertical: 8),
                      child: const Text(
                        "Personal Info",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                        ),
                      ),
                    ),


                    Column(
                      children: resultList[0].keys
                          .where((key) => !excludedKeysPersonal.contains(key))
                          .map((key) {
                        String formattedKey = key
                            .replaceAllMapped(RegExp(r'_'), (match) => ' ')
                            .toLowerCase();
                        formattedKey = formattedKey
                            .split(' ')
                            .map((word) => word.isNotEmpty
                            ? word[0].toUpperCase() + word.substring(1)
                            : '')
                            .join(' ');

                        String value = resultList[0][key].toString(); // Convert to string

                        if (value.isNotEmpty && value != 'null') {
                          return Card(
                            color: const Color(0xFF333333),
                            child: ListTile(
                              title: Text(
                                formattedKey,
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
                      })
                          .toList(),
                    ),
                    Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color:const Color(0xff74c2c6),
                        borderRadius: BorderRadius.circular(8),
                      ),

                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.symmetric(horizontal: 8,vertical: 8),
                      child: const Text(
                        "Contact Info",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                        ),
                      ),
                    ),
                    Column(
                      children: resultList[0].keys
                          .where((key) => !excludedKeysContact.contains(key))
                          .map((key) {
                        String formattedKey = key
                            .replaceAllMapped(RegExp(r'_'), (match) => ' ')
                            .toLowerCase();
                        formattedKey = formattedKey
                            .split(' ')
                            .map((word) => word.isNotEmpty
                            ? word[0].toUpperCase() + word.substring(1)
                            : '')
                            .join(' ');

                        String value = resultList[0][key].toString(); // Convert to string

                        if (value.isNotEmpty && value != 'null') {
                          return Card(
                            color: const Color(0xFF333333),
                            child: ListTile(
                              title: Text(
                                formattedKey,
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
                      })
                          .toList(),
                    ),
                    Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color:const Color(0xff74c2c6),
                        borderRadius: BorderRadius.circular(8),
                      ),

                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.symmetric(horizontal: 8,vertical: 8),
                      child: const Text(
                        "Indentity Info",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                        ),
                      ),
                    ),

                    Column(
                      children: resultList[0].keys
                          .where((key) => !excludedKeysIdentity.contains(key))
                          .map((key) {
                        String formattedKey = key
                            .replaceAllMapped(RegExp(r'_'), (match) => ' ')
                            .toLowerCase();
                        formattedKey = formattedKey
                            .split(' ')
                            .map((word) => word.isNotEmpty
                            ? word[0].toUpperCase() + word.substring(1)
                            : '')
                            .join(' ');

                        String value = resultList[0][key].toString(); // Convert to string

                        if (value.isNotEmpty && value != 'null') {
                          return Card(
                            color: const Color(0xFF333333),
                            child: ListTile(
                              title: Text(
                                formattedKey,
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
                      })
                          .toList(),
                    ),

                    Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color:const Color(0xff74c2c6),
                        borderRadius: BorderRadius.circular(8),
                      ),

                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.symmetric(horizontal: 8,vertical: 8),
                      child: const Text(
                        "Official Info",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                        ),
                      ),
                    ),
                    Column(
                      children: resultList[0].keys
                          .where((key) => !excludedKeysOfficial.contains(key))
                          .map((key) {
                        String formattedKey = key
                            .replaceAllMapped(RegExp(r'_'), (match) => ' ')
                            .toLowerCase();
                        formattedKey = formattedKey
                            .split(' ')
                            .map((word) => word.isNotEmpty
                            ? word[0].toUpperCase() + word.substring(1)
                            : '')
                            .join(' ');

                        String value = resultList[0][key].toString(); // Convert to string

                        if (value.isNotEmpty && value != 'null') {
                          return Card(
                            color: const Color(0xFF333333),
                            child: ListTile(
                              title: Text(
                                formattedKey,
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
                      })
                          .toList(),
                    ),

                    const SizedBox(
                      height: 8,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UpdateProfilePage(resultList: resultList), // Replace UpdatePage with the actual name of your update page
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8), // Adjust the radius as needed
                        ),
                      ),
                      child: const Text(
                        'Edit',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 8,
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

  Widget ShimmerLoading({required BuildContext context, int itemCount = 4}) {
    return Column(
      children: [
        Shimmer.fromColors(
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
        ),
        Shimmer.fromColors(
          baseColor: const Color(0xFF333333),
          highlightColor: const Color(0xFF1a1a1a),
          child: ListView.builder(
            itemCount: itemCount,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Container(
                    height: 20,
                    width: MediaQuery.of(context).size.width * 0.6,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  subtitle: Container(
                    height: 16,
                    width: MediaQuery.of(context).size.width * 0.4,
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
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
      String sbName = prefs.getString('sb_name') ?? '';
      map['EmployeeId'] = prefs.getString('employee_id') ?? '0';
      map['UserId'] = prefs.getString('user_id') ?? '0';
      // print("Request data: $map");
      final http.Response response = await http.post(
        uri,
        body: map,
      );

      // print("Request data: $map");
      // print('Response status code: ${response.statusCode}');
      // print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the data
        final Map<String, dynamic> userData = json.decode(response.body);
        print('User data: $userData');
        if (userData['success'] == true) {
          List<Map<String, dynamic>> resultList =
          (userData['resultList'] as List<dynamic>)
              .map((item) {
            // Convert all keys to strings and handle null values
            return Map<String, dynamic>.from(
              item.map((key, value) => MapEntry(key.toString(), value ?? '')),
            );
          })
              .toList();

          if (resultList.isNotEmpty) {
            resultList[0]['department'] = resultList[0]['department_name'] ?? resultList[0]['department'];
            resultList[0]['designation'] = resultList[0]['designation_name'] ?? resultList[0]['designation'];
            resultList[0]['strategic_business_unit'] = resultList[0]['sbu_name'] ?? resultList[0]['strategic_business_unit'];
            resultList[0]['identity_type'] = resultList[0]['identity_type_name'] ?? resultList[0]['identity_type'];
            resultList[0]['office'] = resultList[0]['office_name'] ?? resultList[0]['office'];

            // Remove keys with null values
            resultList[0].removeWhere((key, value) => value == null);

            print("this is: $resultList");
            return resultList;
          }

          print("Empty resultList");
          return [];
        }
        else {
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
