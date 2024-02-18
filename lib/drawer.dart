import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:interspeed_attendance_app/dashboard_page.dart';
import 'package:interspeed_attendance_app/login_page.dart';
import 'package:interspeed_attendance_app/profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'controller/dashboard_controller.dart';
import 'leave_application_page.dart';

class MyDrawer extends StatelessWidget {
  // Access the DashboardController using Get.find

  // Extract relevant data from sessionData
  final BuildContext context;

  const MyDrawer({
    Key? key,
    required this.context,
  }) : super(key: key);

  @override
  Widget build(BuildContext context){
    DashboardController dashboardController = Get.find<DashboardController>();
    String fullName = dashboardController.sessionData['full_name'] ?? '';
    String sbName = dashboardController.sessionData['sb_name'] ?? '';
    return Drawer(
      backgroundColor: const Color(0xff1a1a1a),
      width: MediaQuery.of(context).size.width * 0.75,
      child: ListView(
        children: [
          DrawerHeader(
            padding: const EdgeInsets.all(0),
            margin: const EdgeInsets.all(0),
            child: UserAccountsDrawerHeader(
              margin: const EdgeInsets.all(0),
              decoration: const BoxDecoration(color: Color(0xff333333)),
              accountName: Text(fullName),
              accountEmail: Text(sbName),
              currentAccountPicture: Image.network(
                "https://winaero.com/blog/wp-content/uploads/2017/12/User-icon-256-blue.png",
              ),
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.home,
              color: Colors.white,
            ),
            title: const Text(
              "Home",
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DashboardPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.person,
              color: Colors.white,
            ),
            title: const Text(
              "Profile",
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              // Fetch user data when the ListTile is tapped
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfilePage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.edit_calendar,
              color: Colors.white,
            ),
            title: const Text(
              "Request Leave",
              style: TextStyle(color: Colors.white),
            ),
            onTap: (){
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LeaveApplicationPage(),
                ),
              );
            },
          ),
          const ListTile(
            leading: Icon(
              Icons.change_circle,
              color: Colors.white,
            ),
            title: Text(
              "Update Password",
              style: TextStyle(color: Colors.white),
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.exit_to_app_sharp,
              color: Colors.white,
            ),
            title: const Text(
              "Logout",
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              _showLogoutDialog();
            },
          ),
        ],
      ),
    );
  }

  // void sendUserDataToProfile() async {
  //   try {
  //
  //     // final Uri uri = Uri.parse('https://na57.salesforce.com/services/oauth2/token');
  //     // final map = <String, dynamic>{};
  //     // map['grant_type'] = 'password';
  //     // map['client_id'] = '3MVG9dZJodJWITSviqdj3EnW.LrZ81MbuGBqgIxxxdD6u7Mru2NOEs8bHFoFyNw_nVKPhlF2EzDbNYI0rphQL';
  //     // map['client_secret'] = '42E131F37E4E05313646E1ED1D3788D76192EBECA7486D15BDDB8408B9726B42';
  //     // map['username'] = 'example@mail.com.us';
  //     // map['password'] = 'ABC1234563Af88jesKxPLVirJRW8wXvj3D';
  //
  //     // http.Response response = await http.post(
  //     //   uri,
  //     //   body: map,
  //     // );
  //     final String profileDataUrl = 'https://br-isgalleon.com/api/employee/get_employee_by_id.php';
  //     final Uri uri = Uri.parse(profileDataUrl);
  //     final map = <String, dynamic>{};
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     // Add parameters for the user data
  //     // print(prefs.getString('employee_id'));
  //     map['EmployeeId'] = prefs.getString('employee_id') ?? '0';
  //     map['UserId'] = prefs.getString('user_id') ?? '0';
  //
  //     // print("employee_id:${map['EmployeeId']},user_id:${map['UserId']}.");
  //
  //     // Send the combined data request
  //     final http.Response response =
  //     await http.post(
  //       uri,
  //       body: map,
  //     );
  //     print("Request data: $map");
  //     print('Response status code: ${response.statusCode}');
  //     print('Response body: ${response.body}');
  //
  //     if (response.statusCode == 200) {
  //       // If the server returns a 200 OK response, parse the data
  //       final Map<String, dynamic> userData = json.decode(response.body);
  //       print('User data: ${userData}');
  //
  //       // Navigate to the profile page and pass the user data
  //       if (userData['success'] == true) {
  //         List<Map<String, dynamic>> resultList = (userData['resultList'] as List<dynamic>)
  //             .map((item) => Map<String, dynamic>.from(item))
  //             .toList();
  //         // Navigate to the profile page and pass the user data
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => ProfilePage(),
  //           ),
  //         );
  //       } else {
  //         // Show the attendance dialog with a failure message
  //         _showAttendacneDialog("Failed", "User data not available", 0);
  //       }
  //
  //     } else {
  //       // If the server did not return a 200 OK response,
  //       // handle the error accordingly (you might want to show an error message)
  //       print('Failed to load user data. Status code: ${response.statusCode}');
  //     }
  //   } catch (error) {
  //     // Handle errors
  //     print('Error getting combined data: $error');
  //   }
  // }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1a1a1a),
          title: Container(
            // Header area color
            child: const Text(
              'Are you sure?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'You will be logged out.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                _logout();
                Navigator.pop(context, 'OK');
              },
              child: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
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

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs
        .clear(); // Clear all stored data, you might want to clear specific keys

    // Navigate to the login screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void _showAttendacneDialog(String title, String message, int statusCode) {
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
