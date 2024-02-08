import 'package:flutter/material.dart';
import 'package:interspeed_attendance_app/dashboard_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:interspeed_attendance_app/login_page.dart';

class DashboardPage extends StatefulWidget {
  final Map<String, dynamic> sessionData;
  DashboardPage({required this.sessionData});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}


class _DashboardPageState extends State<DashboardPage> {
  bool _isSignInButtonClicked = false;
  bool _isSignOutButtonClicked = false;

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all stored data, you might want to clear specific keys

    // Navigate to the login screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = widget.sessionData['user_id'] ?? '';
    final String userName = widget.sessionData['user_name'] ?? '';
    final String fullName = widget.sessionData['full_name'] ?? '';
    final userTypeId = widget.sessionData['user_type_id'] ?? '';
    final pictureName = widget.sessionData['picture_name'] ?? '';
    final userTypeName = widget.sessionData['user_type_name'] ?? '';
    final employeeId = widget.sessionData['employee_id'] ?? '';
    final designationId = widget.sessionData['designation_id'] ?? '';
    final employeePositionId = widget.sessionData['employee_position_id'] ?? '';
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Attendance',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xff246EE9),
        // automaticallyImplyLeading: false,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              padding: const EdgeInsets.all(0),
              child: UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: Colors.blue[400]),
                accountName: Text("$fullName"),
                accountEmail: const Text("utso097.csekuet@gmail.com"),
                onDetailsPressed: () {
                  //MySnackBar(Text("User account drawer header tapped"), context);
                },
                currentAccountPicture: Image.network(
                    "https://winaero.com/blog/wp-content/uploads/2017/12/User-icon-256-blue.png"),
              ),
            ),
            const ListTile(
              leading: Icon(Icons.home),
              title: Text("Home"),
            ),
            const ListTile(
              leading: Icon(Icons.person),
              title: Text("Profile"),
            ),
            const ListTile(
              leading: Icon(Icons.email),
              title: Text("Email"),
            ),
            const ListTile(
              leading: Icon(Icons.phone),
              title: Text("Phone"),
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text("Logout"),
              onTap: () {
                _logout();
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        //print("Before setState - _isSignOutButtonClicked: $_isSignInButtonClicked");
                        _isSignInButtonClicked = true;
                        _isSignOutButtonClicked = false;
                        //print("After setState - _isSignOutButtonClicked: $_isSignInButtonClicked");
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      primary: _isSignInButtonClicked? const Color(0xff2b7d2e):Color(0xffe60022),
                      shape: const CircleBorder(),
                      padding:
                          const EdgeInsets.all(32.0), // Padding for the button
                    ),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      //print("Before setState - _isSignOutButtonClicked: $_isSignOutButtonClicked");
                      setState(() {
                        _isSignOutButtonClicked = true;
                        _isSignInButtonClicked = false;
                      });
                      //print("After setState - _isSignOutButtonClicked: $_isSignOutButtonClicked");
                    },
                    style: ElevatedButton.styleFrom(
                      primary: _isSignOutButtonClicked? const Color(0xff2b7d2e):Color(0xffe60022),
                      shape: const CircleBorder(),
                      padding:
                          const EdgeInsets.all(32.0), // Padding for the button
                    ),
                    child: const Text(
                      'Sign Out',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          _isSignInButtonClicked ? Padding(
            padding: const EdgeInsets.all(32.0),
            child: Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(Icons.camera,size: 100,),
                  Icon(Icons.location_on_outlined,size: 100,),
                ],
              ),
            ),
          ):  const SizedBox.shrink(),

          _isSignOutButtonClicked ? Padding(
            padding: const EdgeInsets.all(32.0),
            child: Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(Icons.camera,size: 100,),
                  Icon(Icons.location_on_outlined,size: 100,),
                ],
              ),
            ),
          ) :  const SizedBox.shrink(),
        ],
      ),
    );
  }
}
