import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:interspeed_attendance_app/camera_page.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:interspeed_attendance_app/login_page.dart';
import 'package:intl/intl.dart';

import 'profile_page.dart';

class DashboardPage extends StatefulWidget {
  final Map<String, dynamic> sessionData;

  DashboardPage({required this.sessionData});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _signInbase64Image = "";
  String _signOutbase64Image = "";
  bool _isSignInButtonClicked = false;
  bool _isSignOutButtonClicked = false;
  double latitude = -1;
  double longitude = -1;
  int accuracy = 100;
  bool showProgressBar = false;

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

  Future<void> sendAttendanceData() async {
    // Set up the URL
    final String url = _isSignInButtonClicked
        ? 'https://br-isgalleon.com/api/attendance/insert_daily_attendance_in.php'
        : 'https://br-isgalleon.com/api/attendance/insert_daily_attendance_out.php';

    // Create the multipart request
    final http.MultipartRequest request =
        http.MultipartRequest('POST', Uri.parse(url));

    //Validate the request
    if (_isSignOutButtonClicked &&
        (_signOutbase64Image == null || _signOutbase64Image!.isEmpty)) {
      // Handle the case when _base64Image is empty
      setState(() {
        showProgressBar = false;
      });
      print('Error: Image data is empty');
      _showAttendacneDialog(
          "Failed", "Required selfie! please click a selfie", 0);
      return;
    }

    if (_isSignInButtonClicked &&
        (_signInbase64Image == null || _signInbase64Image!.isEmpty)) {
      // Handle the case when _base64Image is empty
      setState(() {
        showProgressBar = false;
      });
      print('Error: Image data is empty');
      _showAttendacneDialog(
          "Failed", "Required selfie! please click a selfie", 0);
      return;
    }

    if (latitude == -1 || longitude == -1) {
      // Handle the case when latitude or longitude is not set
      setState(() {
        showProgressBar = false;
      });
      _showAttendacneDialog(
          "Failed",
          "Location is mandatory for this action! Make sure location service is enabled",
          0);
      print('Error: Latitude or longitude not set');
      return;
    }

    // Add your data to the request
    request.fields['UserId'] = widget.sessionData['user_id'];
    request.fields['LatValue'] = latitude.toString();
    request.fields['LonValue'] = longitude.toString();
    request.fields['Accuracy'] = accuracy.toString();
    request.fields['InRemark'] = "";
    request.fields['ImageData'] =
        _isSignInButtonClicked ? _signInbase64Image : _signOutbase64Image;

    // Send the request
    try {
      final http.Response response =
          await http.Response.fromStream(await request.send());

      if (response.statusCode == 200) {
        // Request was successful
        Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success'] && _isSignInButtonClicked)
          _showAttendacneDialog(
              "Success", "You have successfully entered!", 200);
        if (responseData['success'] && _isSignOutButtonClicked)
          _showAttendacneDialog("Success", "Bye bye, see you next time!", 200);
        else
          _showAttendacneDialog("Failed", "Attendance already recorded!", 0);
        setState(() {
          _isSignInButtonClicked
              ? _signInbase64Image = ""
              : _signOutbase64Image = "";
        });
        // Process the response data
        print(responseData);
      } else {
        // Request failed
        _showAttendacneDialog(
            "Failed", "Check your internet connection or login again!", 0);
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (error) {
      // Handle errors
      _showAttendacneDialog("Failed", "Check your internet connection", 0);
      print('Error sending request: $error');
    } finally {
      setState(() {
        showProgressBar = false;
      });
    }
  }

  // https://br-isgalleon.com/api/employee/get_employee_by_id.php
  void sendUserDataToProfile() async {
    try {

      // final Uri uri = Uri.parse('https://na57.salesforce.com/services/oauth2/token');
      // final map = <String, dynamic>{};
      // map['grant_type'] = 'password';
      // map['client_id'] = '3MVG9dZJodJWITSviqdj3EnW.LrZ81MbuGBqgIxxxdD6u7Mru2NOEs8bHFoFyNw_nVKPhlF2EzDbNYI0rphQL';
      // map['client_secret'] = '42E131F37E4E05313646E1ED1D3788D76192EBECA7486D15BDDB8408B9726B42';
      // map['username'] = 'example@mail.com.us';
      // map['password'] = 'ABC1234563Af88jesKxPLVirJRW8wXvj3D';

      // http.Response response = await http.post(
      //   uri,
      //   body: map,
      // );
      final String profileDataUrl = 'https://br-isgalleon.com/api/employee/get_employee_by_id.php';
      final Uri uri = Uri.parse(profileDataUrl);
      final map = <String, dynamic>{};
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // Add parameters for the user data
      map['EmployeeId'] = prefs.getString('employee_id') ?? '0';
      map['UserId'] = prefs.getString('user_id') ?? '0';

      print("employee_id:${map['EmployeeId']},user_id:${map['UserId']}.");

      // Send the combined data request
      final http.Response response =
      await http.post(
        uri,
        body: map,
      );
      print("Request data: $map");
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the data
        final Map<String, dynamic> userData = json.decode(response.body);
        print('User data: ${userData}');

        // Navigate to the profile page and pass the user data
        if (userData['success'] == true) {
          // Navigate to the profile page and pass the user data
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfilePage(userData: userData),
            ),
          );
        } else {
          // Show the attendance dialog with a failure message
          _showAttendacneDialog("Failed", "User data not available", 0);
        }

      } else {
        // If the server did not return a 200 OK response,
        // handle the error accordingly (you might want to show an error message)
        print('Failed to load user data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      // Handle errors
      print('Error getting combined data: $error');
    }
  }


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var currentTime = DateFormat('h:mm a', 'en_US').format(
        DateTime.now().toUtc().add(const Duration(hours: 6))); // Dhaka UTC+6
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
                decoration: const BoxDecoration(color: Color(0xff333333)),
                accountName: Text("${fullName}"),
                accountEmail: const Text("example@gmail.com"),
                currentAccountPicture: Image.network(
                  "https://winaero.com/blog/wp-content/uploads/2017/12/User-icon-256-blue.png",
                ),
              ),
            ),
            const ListTile(
              leading: Icon(
                Icons.home,
                color: Colors.white,
              ),
              title: Text(
                "Home",
                style: TextStyle(color: Colors.white),
              ),
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
                sendUserDataToProfile();
              },
            ),
            const ListTile(
              leading: Icon(
                Icons.email,
                color: Colors.white,
              ),
              title: Text(
                "Email",
                style: TextStyle(color: Colors.white),
              ),
            ),
            const ListTile(
              leading: Icon(
                Icons.phone,
                color: Colors.white,
              ),
              title: Text(
                "Phone",
                style: TextStyle(color: Colors.white),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.exit_to_app,
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
                                Image.asset('assets/images/entry_button.png',
                                    height: 70, width: 70),
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
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          alignment: Alignment.bottomCenter,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset('assets/images/entry_time_box.png',
                                  height: 13),
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
                              Image.asset('assets/images/exit_button.png',
                                  height: 70, width: 70),
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
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          alignment: Alignment.bottomCenter,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset('assets/images/exit_time_box.png',
                                  height: 13),
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
                                navigateToCameraPage();
                              },
                              child: _buildCard(
                                color: 0xff74c2c6,
                                image: 'assets/images/ic_camera.png',
                                title: 'Camera',
                                description: _signInbase64Image != ""
                                    ? 'Image Captured'
                                    : 'Capture Image',
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
                                      navigateToCameraPage();
                                    },
                                    child: _buildCard(
                                      image: 'assets/images/ic_camera.png',
                                      title: 'Camera',
                                      description: _signOutbase64Image != ""
                                          ? 'Image Captured'
                                          : 'Capture Image',
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
                setState(() {
                  showProgressBar = true;
                });
                sendAttendanceData();
                print('Button Clicked');
                // Add your custom logic or navigation here
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    'assets/images/Submit tickxxxhdpi.png',
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                  if (showProgressBar)
                    const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                ],
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
                  color: Colors.white),
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

  Future<void> navigateToCameraPage() async {
    // Navigate to the camera page and wait for the result
    String? base64Image = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraPage(),
      ),
    );

    // Handle the base64Image received from the camera page
    if (base64Image != null) {
      // Do something with the base64 image, e.g., display it
      print('Received base64 image: $base64Image');
      setState(() {
        if (_isSignInButtonClicked) _signInbase64Image = base64Image;
        if (_isSignOutButtonClicked) _signOutbase64Image = base64Image;
      });
    } else {
      // Handle the case where the user canceled or an error occurred
      print('Image capture canceled or error occurred');
    }
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
