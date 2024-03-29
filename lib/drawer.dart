import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:interspeed_attendance_app/activity_page.dart';
import 'package:interspeed_attendance_app/dashboard_page.dart';
import 'package:interspeed_attendance_app/leave_page.dart';
import 'package:interspeed_attendance_app/login_page.dart';
import 'package:interspeed_attendance_app/password_change_page.dart';
import 'package:interspeed_attendance_app/profile_page.dart';
import 'package:interspeed_attendance_app/project_page.dart';
import 'package:interspeed_attendance_app/utils/layout_size.dart';
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

  Widget _buildPlaceholderImage() {
    return Image.asset(
      'assets/images/person.png', // Replace 'assets/placeholder_image.png' with the path to your placeholder image asset
      fit: BoxFit.fill
      ,
    );
  }

  Widget build(BuildContext context){
    AppLayout layout = AppLayout(context: context);
    DashboardController dashboardController = Get.find<DashboardController>();
    String fullName = dashboardController.sessionData['full_name'] ?? '';
    String sbName = dashboardController.sessionData['sb_name'] ?? '';
    String picture_name = dashboardController.sessionData['picture_name']?? '';
    String user_id = dashboardController.sessionData['user_id'] ?? '';
    String employee_id = dashboardController.sessionData['employee_id'] ?? '';


    return Drawer(
      backgroundColor: const Color(0xff1a1a1a),
      width: MediaQuery.of(context).size.width * 0.75,
      child: ListView(
        children: [
        DrawerHeader(
        padding: EdgeInsets.zero,
        margin: EdgeInsets.zero,
        decoration: BoxDecoration(color: Color(0xff333333)),
        child: UserAccountsDrawerHeader(
          margin: EdgeInsets.zero,
          decoration: BoxDecoration(color: Color(0xff333333)),
          accountName: Text(fullName),
          accountEmail: Text(sbName),
          currentAccountPicture: ClipOval(
            child: Container(
              width: layout.getwidth(70),
              height: layout.getwidth(70),
              child: picture_name != ''
                  ? Image.network(
                'https://br-isgalleon.com/image_ops/employee/${picture_name.toString()}',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Handle network-related errors here
                  print('Error loading image: $error');
                  // Return a placeholder widget as a fallback
                  return _buildPlaceholderImage();
                },
              )
                  : _buildPlaceholderImage(), // Fallback for empty picture_name
            ),
          ),
        ),
      ),
          ListTile(
            leading: const Icon(
              Icons.home,
              color: Color(0xffFFCC80),
              // color: Colors.white,
            ),
            title: const Text(
              "Home",
              style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500),
            ),
            onTap: () {
              Navigator.pop(context);
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
              Icons.manage_accounts,
              color: Color(0xffFFCC80),
              // color: Colors.white,
            ),
            title: const Text(
              "Activity",
              style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ActivityPage(userId: user_id,
                    employeeId: employee_id,),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(
              Icons.edit_calendar,
              color: Color(0xffFFCC80),
            ),
            title: const Text(
              "Leave Info",
              style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500),
            ),
            onTap: (){
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LeaveApplicationListPage(userId: user_id,
                    employeeId: employee_id,),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(
              Icons.edit_calendar,
              color: Color(0xffFFCC80),
            ),
            title: const Text(
              "Projects",
              style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500),
            ),
            onTap: (){
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProjectPage(userId: user_id,
                    employeeId: employee_id,),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(
              Icons.person,
              color: Color(0xffFFCC80),
            ),
            title: const Text(
              "Profile",
              style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500),
            ),
            onTap: () {
              Navigator.pop(context);
              // Fetch user data when the ListTile is tapped
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfilePage(),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(
              Icons.change_circle,
              color: Color(0xffFFCC80),
            ),
            title: const Text(
              "Update Password",
              style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500),
            ),
            onTap: (){
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PasswordChangeForm(userId: user_id,),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.exit_to_app_sharp,
              color: Color(0xffFFCC80),
            ),
            title: const Text(
              "Logout",
              style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500),
            ),
            onTap: () {
              _showLogoutDialog();
            },
          ),
        ],
      ),
    );
  }

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
    // print("The deleted user name is: ");
    // print(prefs.getString('user_name'));

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
