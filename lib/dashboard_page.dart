import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:interspeed_attendance_app/camera_page.dart';
import 'package:geolocator/geolocator.dart';
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
  double latitude = -1;
  double longitude = -1;
  int accuracy = 100;

  getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      log("Location Denied");
      LocationPermission ask = await Geolocator.requestPermission();
    } else {
      Position currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      log("Latitude=${currentPosition.latitude.toString()}");
      log("Longitude=${currentPosition.longitude.toString()}");
      log("Accuracy=${currentPosition.accuracy.toString()}");
      setState(() {
        latitude = currentPosition.latitude;
        longitude = currentPosition.longitude;
        accuracy = currentPosition.accuracy.toInt();
      });
    }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs
        .clear(); // Clear all stored data, you might want to clear specific keys

    // Navigate to the login screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
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
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Attendance',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xff010080),
        // automaticallyImplyLeading: false,
      ),
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.75,
        child: ListView(
          children: [
            DrawerHeader(
              padding: const EdgeInsets.all(0),
              margin: const EdgeInsets.all(0),
              child: UserAccountsDrawerHeader(
                margin: const EdgeInsets.all(0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xff010080),
                      Colors.blue,
                    ],
                    stops: [0.0, 1.0],
                    tileMode: TileMode.clamp,
                  ),
                ),
                accountName: Text("${fullName}"),
                accountEmail: const Text("example@gmail.com"),
                currentAccountPicture: Image.network(
                  "https://winaero.com/blog/wp-content/uploads/2017/12/User-icon-256-blue.png",
                ),
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
              leading: const Icon(Icons.exit_to_app),
              title: const Text("Logout"),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                      ),
                      title: const Text('Are you sure?'),
                      content: const Text('you will be logged out.'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context, 'Cancel'),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Color(0xff010080),
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
                              color: Color(0xff010080),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      body: Container(
        color: const Color(0xfff2f2f2),
        child: Column(
          children: [
            // Image.asset('assets/images/ic_attendance_inactive_btn.png'),
            Stack(
              children: [
                Container(
                  color: Colors.blue,
                  height: 100,
                  width: double.infinity,
                  child: FractionallySizedBox(
                    alignment: Alignment.topCenter,
                    widthFactor: 0.6,
                    // Set the desired width as a fraction (0.0 to 1.0)
                    heightFactor: 0.6,
                    // Set the desired height as a fraction (0.0 to 1.0)
                    child: Image.asset('assets/images/ic_calendar.png'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 64, 32, 16),
                  child: Container(
                    // padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            getCurrentLocation();
                            setState(() {
                              _isSignInButtonClicked = true;
                              _isSignOutButtonClicked = false;
                            });
                            // Add your custom logic here
                          },
                          child: Padding(
                            padding: EdgeInsets.all(
                                MediaQuery.of(context).size.width * 0.05),
                            // Adjust the padding based on screen width
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.asset(
                                  _isSignInButtonClicked
                                      ? 'assets/images/ic_attendance_active_btn.png'
                                      : 'assets/images/ic_attendance_inactive_btn.png',
                                  // Replace with your image path
                                  width:
                                      MediaQuery.of(context).size.width * 0.25,
                                  // Adjust the width based on screen width
                                  height:
                                      MediaQuery.of(context).size.width * 0.25,
                                  // Adjust the height based on screen width
                                  fit: BoxFit
                                      .cover, // Adjust the fit based on your requirement
                                ),
                                const SizedBox(height: 8.0),
                                // Adjust the spacing between image and text
                                Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: _isSignInButtonClicked
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        GestureDetector(
                          onTap: () {
                            getCurrentLocation();
                            setState(() {
                              _isSignOutButtonClicked = true;
                              _isSignInButtonClicked = false;
                            });
                            // Add your custom logic here
                          },
                          child: Padding(
                            padding: EdgeInsets.all(
                                MediaQuery.of(context).size.width * 0.05),
                            // Adjust the padding based on screen width
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.asset(
                                  _isSignOutButtonClicked
                                      ? 'assets/images/ic_attendance_active_btn.png'
                                      : 'assets/images/ic_attendance_inactive_btn.png',
                                  // Replace with your image path
                                  width:
                                      MediaQuery.of(context).size.width * 0.25,
                                  // Adjust the width based on screen width
                                  height:
                                      MediaQuery.of(context).size.width * 0.25,
                                  // Adjust the height based on screen width
                                  fit: BoxFit
                                      .cover, // Adjust the fit based on your requirement
                                ),
                                const SizedBox(height: 8.0),
                                // Adjust the spacing between image and text
                                Text(
                                  'Sign Out',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: _isSignOutButtonClicked
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            _isSignInButtonClicked
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CameraPage(),
                                  ),
                                );
                              },
                              child: _buildCard(
                                image: 'assets/images/ic_camera.png',
                                title: 'Camera',
                                description: 'Image Captured',
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Expanded(
                            child: _buildCard(
                              image: 'assets/images/ic_gps.png',
                              title: 'GPS',
                              description: 'Accuracy: ${accuracy.toString()}',
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(),

            _isSignOutButtonClicked
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                  child: Container(
                                    child: _buildCard(
                                      image: 'assets/images/ic_camera.png',
                                      title: 'Camera',
                                      description: 'Image Captured',
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                Expanded(
                                  child: _buildCard(
                                    image: 'assets/images/ic_gps.png',
                                    title: 'GPS',
                                    description:
                                        'Accuracy: ${accuracy.toString()}',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )),
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
      {required String image,
      required String title,
      required String description}) {
    return Card(
      // Customize the card appearance as needed
      elevation: 3,
      color: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
              child: Image.asset(
                image,
                color: const Color(0xff010080),
                fit: BoxFit.fill,
                // Adjust the fit based on your requirement
              ),
            ),
            Text(
              description,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
