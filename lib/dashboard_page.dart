import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:interspeed_attendance_app/camera_page.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:interspeed_attendance_app/login_page.dart';
import 'package:intl/intl.dart';
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
    var currentTime = DateFormat('h:mm a', 'en_US').format(DateTime.now().toUtc().add(const Duration(hours: 6))); // Dhaka UTC+6
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
      // appBar: AppBar(
      //   iconTheme: const IconThemeData(color: Colors.white),
      //   title: const Text(
      //     'Attendance',
      //     style: TextStyle(
      //       fontSize: 24,
      //       fontWeight: FontWeight.w500,
      //       color: Colors.white,
      //     ),
      //   ),
      //   backgroundColor: const Color(0xff010080),
      //   // automaticallyImplyLeading: false,
      // ),
      drawer: Drawer(
        backgroundColor: const Color(0xff1a1a1a),
        width: MediaQuery.of(context).size.width * 0.75,
        child: ListView(
          children: [
            DrawerHeader(
              padding: const EdgeInsets.all(0),
              margin: const EdgeInsets.all(0),
              child: UserAccountsDrawerHeader(
                margin: const EdgeInsets.all(0),
                decoration: const BoxDecoration(
                  color: Color(0xff333333)
                ),
                accountName: Text("${fullName}"),
                accountEmail: const Text("example@gmail.com"),
                currentAccountPicture: Image.network(
                  "https://winaero.com/blog/wp-content/uploads/2017/12/User-icon-256-blue.png",
                ),
              ),
            ),
            const ListTile(
              leading: Icon(Icons.home,color: Colors.white,),
              title: Text("Home",style: TextStyle(color: Colors.white),),
            ),
            const ListTile(
              leading: Icon(Icons.person,color: Colors.white,),
              title: Text("Profile",style: TextStyle(color: Colors.white),),
            ),
            const ListTile(
              leading: Icon(Icons.email,color: Colors.white,),
              title: Text("Email",style: TextStyle(color: Colors.white),),
            ),
            const ListTile(
              leading: Icon(Icons.phone,color: Colors.white,),
              title: Text("Phone",style: TextStyle(color: Colors.white),),
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app,color: Colors.white,),
              title: const Text("Logout",style: TextStyle(color: Colors.white),),
              onTap: () {
                _showLogoutDialog();
              },
            ),
          ],
        ),
      ),


      body: Container(
        color: const Color(0xff1a1a1a),
        child: Column(
          children: [
            // Image.asset('assets/images/ic_attendance_inactive_btn.png'),
            Container(
              width: double.infinity,
              height: 180,
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
                  Image.asset(
                    'assets/images/logo.jpg',
                    width: 70,
                    height: 70,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$fullName",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        "Software Engineer",
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        "Interspeed Marketing Solution Ltd",
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

            Container(
              // color: Colors.white,
              height: 200,
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: 110,
                    height: 140,
                    decoration: BoxDecoration(
                      color: const Color(0xff3a473e),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Column(
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            color: Color(0xff00a0b0),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16.0),
                              topRight: Radius.circular(16.0),
                            ),
                          ),
                          width: double.infinity,
                          height: 25,
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        GestureDetector(

                          onTap: () {
                            getCurrentLocation();
                            setState(() {
                              _isSignInButtonClicked = true;
                              _isSignOutButtonClicked = false;
                            });
                            // Add your custom logic here
                          },
                          child: Container(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.asset('assets/images/entry_button.png', height: 70, width: 70),
                                const Text(
                                  'Entry',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 6
                        ),
                        Container(
                          width: double.infinity,
                          alignment: Alignment.bottomCenter,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset('assets/images/entry_time_box.png', height: 13),
                              Text(
                                currentTime,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],

                    ),
                  ),
                  Container(
                    width: 110,
                    height: 140,
                    decoration: BoxDecoration(
                      color: const Color(0xff3a473e),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Column(
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            color: Color(0xfffec34f),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16.0),
                              topRight: Radius.circular(16.0),
                            ),
                          ),
                          width: double.infinity,
                          height: 25,
                        ),
                        const SizedBox(
                          height: 12,
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
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset('assets/images/exit_button.png', height: 70, width: 70),
                              const Text(
                                'Exit',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                            height: 6
                        ),

                        Container(
                          width: double.infinity,
                          alignment: Alignment.bottomCenter,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset('assets/images/exit_time_box.png', height: 13),
                              Text(
                                currentTime,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        )

                      ],
                    ),
                  )
                ],
              ),
            ),

            // Padding(
            //   padding: const EdgeInsets.fromLTRB(32, 64, 32, 16),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //     children: [
            //       GestureDetector(
            //         onTap: () {
            //           getCurrentLocation();
            //           setState(() {
            //             _isSignInButtonClicked = true;
            //             _isSignOutButtonClicked = false;
            //           });
            //           // Add your custom logic here
            //         },
            //         child: Padding(
            //           padding: EdgeInsets.all(
            //               MediaQuery.of(context).size.width * 0.05),
            //           // Adjust the padding based on screen width
            //           child: Stack(
            //             alignment: Alignment.center,
            //             children: [
            //               Image.asset(
            //                 _isSignInButtonClicked
            //                     ? 'assets/images/ic_attendance_active_btn.png'
            //                     : 'assets/images/ic_attendance_inactive_btn.png',
            //                 // Replace with your image path
            //                 width: MediaQuery.of(context).size.width * 0.25,
            //                 // Adjust the width based on screen width
            //                 height: MediaQuery.of(context).size.width * 0.25,
            //                 // Adjust the height based on screen width
            //                 fit: BoxFit
            //                     .cover, // Adjust the fit based on your requirement
            //               ),
            //               const SizedBox(height: 8.0),
            //               // Adjust the spacing between image and text
            //               Text(
            //                 'Sign In',
            //                 style: TextStyle(
            //                   fontWeight: FontWeight.w900,
            //                   color: _isSignInButtonClicked
            //                       ? Colors.black
            //                       : Colors.white,
            //                 ),
            //               ),
            //             ],
            //           ),
            //         ),
            //       ),
            //       const SizedBox(
            //         width: 20,
            //       ),
            //       GestureDetector(
            //         onTap: () {
            //           getCurrentLocation();
            //           setState(() {
            //             _isSignOutButtonClicked = true;
            //             _isSignInButtonClicked = false;
            //           });
            //           // Add your custom logic here
            //         },
            //         child: Padding(
            //           padding: EdgeInsets.all(
            //               MediaQuery.of(context).size.width * 0.05),
            //           // Adjust the padding based on screen width
            //           child: Stack(
            //             alignment: Alignment.center,
            //             children: [
            //               Image.asset(
            //                 _isSignOutButtonClicked
            //                     ? 'assets/images/ic_attendance_active_btn.png'
            //                     : 'assets/images/ic_attendance_inactive_btn.png',
            //                 // Replace with your image path
            //                 width: MediaQuery.of(context).size.width * 0.25,
            //                 // Adjust the width based on screen width
            //                 height: MediaQuery.of(context).size.width * 0.25,
            //                 // Adjust the height based on screen width
            //                 fit: BoxFit
            //                     .cover, // Adjust the fit based on your requirement
            //               ),
            //               const SizedBox(height: 8.0),
            //               // Adjust the spacing between image and text
            //               Text(
            //                 'Sign Out',
            //                 style: TextStyle(
            //                   fontWeight: FontWeight.w900,
            //                   color: _isSignOutButtonClicked
            //                       ? Colors.black
            //                       : Colors.white,
            //                 ),
            //               ),
            //             ],
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),



            _isSignInButtonClicked
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
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
                                color: 0xff74c2c6,
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
                              color: 0xff74c2c6,
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
                    padding: const EdgeInsets.symmetric(horizontal: 24),
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
                                      color: 0xfffed593,
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
                                    color: 0xfffed593,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )),
                  )
                : const SizedBox.shrink(),
            GestureDetector(
              onTap: () {
                // Handle button click here
                print('Button Clicked');
                // Add your custom logic or navigation here
              },
              child: Image.asset(
                'assets/images/Submit tickxxxhdpi.png', // Replace with your asset image path
                width: 70, // Adjust width as needed
                height: 70, // Adjust height as needed
                fit: BoxFit.cover, // Adjust the fit based on your requirement
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
      {required String image,
      required String title,
      required String description,
      required int color}) {
    return Card(
      // Customize the card appearance as needed
      elevation: 3,
      color: const Color(0xff1a1a1a),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          //color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
              child: Image.asset(
                image,
                color: Color(color),
                fit: BoxFit.fill,
                // Adjust the fit based on your requirement
              ),
            ),
            Text(
              description,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1a1a1a),
          title: Container(// Header area color
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0), // Adjust the radius as needed
          ),
        );

      },
    );
  }
}
