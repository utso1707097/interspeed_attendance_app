import 'dart:convert';
import 'dart:developer';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:interspeed_attendance_app/camera_page.dart';
import 'package:geolocator/geolocator.dart';
import 'package:interspeed_attendance_app/drawer.dart';
import 'package:interspeed_attendance_app/utils/layout_size.dart';
import 'package:intl/intl.dart';

import 'controller/dashboard_controller.dart';



class DashboardPage extends StatelessWidget {
  final DashboardController dashboardController = Get.put(DashboardController());

  DashboardPage(){
    dashboardController.fetchSessionData();
  }


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
      dashboardController.updateLocation(currentPosition);
    }
  }

  Future<void> sendAttendanceData(BuildContext context) async {
    // Set up the URL
    final String url = dashboardController.isSignInButtonClicked.value
        ? 'https://br-isgalleon.com/api/attendance/insert_daily_attendance_in.php'
        : 'https://br-isgalleon.com/api/attendance/insert_daily_attendance_out.php';


    // Create the multipart request
    final http.MultipartRequest request =
        http.MultipartRequest('POST', Uri.parse(url));

    //Validate the request
    if (dashboardController.isSignOutButtonClicked.value && dashboardController.signOutBase64Image.value.isEmpty) {
      // Handle the case when _base64Image is empty
      dashboardController.setLoading(false);
      print('Error: Image data is empty');
      _showAttendacneDialog(context,"Failed", "Required selfie! please click a selfie", 0);
      return;
    }

    if (dashboardController.isSignInButtonClicked.value && (dashboardController.signInBase64Image.value == null || dashboardController.signInBase64Image.value.isEmpty)) {
      // Handle the case when _base64Image is empty
      dashboardController.setLoading(false);
      print('Error: Image data is empty');
      _showAttendacneDialog(context,"Failed", "Required selfie! please click a selfie", 0);
      return;
    }

    if (dashboardController.latitude.value == -1 || dashboardController.longitude.value == -1) {
      // Handle the case when latitude or longitude is not set
      dashboardController.setLoading(false);
      _showAttendacneDialog(context,"Failed", "Location is mandatory for this action! Make sure location service is enabled", 0);
      print('Error: Latitude or longitude not set');
      return;
    }

    // Add your data to the request
    request.fields['UserId'] = dashboardController.sessionData['user_id']!;
    request.fields['LatValue'] = dashboardController.latitude.value.toString();
    request.fields['Accuracy'] = dashboardController.accuracy.value.toString();
    request.fields['LonValue'] = dashboardController.longitude.value.toString();
    if (dashboardController.isSignInButtonClicked.value) {
      request.fields['InRemark'] = dashboardController.remarkController.value.text;
    } else if (dashboardController.isSignOutButtonClicked.value) {
      request.fields['OutRemark'] = dashboardController.remarkController.value.text;
    }
    request.fields['ImageData'] =
    dashboardController.isSignInButtonClicked.value ? dashboardController.signInBase64Image.value : dashboardController.signOutBase64Image.value;


    // Send the request
    try {
      final http.Response response =
          await http.Response.fromStream(await request.send());
      if (response.statusCode == 200) {
        // Request was successful
        Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success'] && dashboardController.isSignInButtonClicked.value)
          dashboardController.showAttendanceDialog(
              Get.context!, "Success", "You have successfully entered!", 200);
        else if (responseData['success'] && dashboardController.isSignOutButtonClicked.value)
          dashboardController.showAttendanceDialog(
              Get.context!, "Success", "Bye bye, see you next time!", 200);
        else
          dashboardController.showAttendanceDialog(
              Get.context!, "Failed", "Attendance already recorded!", 0);

        dashboardController.setSignInButtonClicked(false);
        dashboardController.setSignOutButtonClicked(false);
        dashboardController.clearData();


        // Process the response data
        print(responseData);
      }
      else {
        // Request failed
        _showAttendacneDialog(
            context,"Failed", "Check your internet connection or login again!", 0);
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (error) {
      // Handle errors
      _showAttendacneDialog(context,"Failed", "Check your internet connection", 0);
      print('Error sending request: $error');
    } finally {
      dashboardController.setLoading(false);
    }
  }

  // https://br-isgalleon.com/api/employee/get_employee_by_id.php


  @override
  Widget build(BuildContext context) {
    final layout = AppLayout(context: context);
    var currentTime = DateFormat('h:mm a', 'en_US').format(
        DateTime.now().toUtc().add(const Duration(hours: 6))); // Dhaka UTC+6
   // Add this line
    return Obx((){
      print(dashboardController.sessionData);
      final String fullName = dashboardController.sessionData['full_name'] ?? '';
      final officeName = dashboardController.sessionData['office_name'] ?? ''; // Add this line
      final designationName = dashboardController.sessionData['designation_name'] ?? '';
      final userImage = dashboardController.sessionData['picture_name'] ?? '';
      print(userImage);
      return Scaffold(
        drawer: MyDrawer(context: context),
        body: DoubleBackToCloseApp(
          snackBar: const SnackBar(
            content: Text('Tap again to exit'),
          ),
          child: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,  // Set a specific height if needed
              color: const Color(0xff1a1a1a),
              child: Column(
                children: [
                  Container(
                    color: const Color(0xff1a1a1a),
                    child: Column(
                      children: [
                        // Image.asset('assets/images/ic_attendance_inactive_btn.png'),
                        Container(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height * 0.25, // Adjust the factor as needed
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
                              // Flex 1 - userImage section
                              Expanded(
                                flex: 1,
                                child: Container(
                                  height: MediaQuery.of(context).size.height * 0.1, // Set a specific height
                                  child: userImage != ""
                                      ? Image.network(
                                    'https://br-isgalleon.com/image_ops/employee/${userImage.toString()}',
                                    width: MediaQuery.of(context).size.width * 0.1,
                                    height: MediaQuery.of(context).size.height* 0.1,
                                  )
                                      : Image.asset(
                                    'assets/images/logo.jpg',
                                    width: MediaQuery.of(context).size.width * 0.2,
                                    height: MediaQuery.of(context).size.height * 0.1,
                                  ),
                                ),
                              ),
                              // Flex 2 - Column section
                              Expanded(
                                flex: 2,
                                child: Container(
                                  height: MediaQuery.of(context).size.height * 0.1, // Set a specific height
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        fullName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        designationName,
                                        style:const  TextStyle(
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
                                ),
                              ),
                            ],
                          ),
                        ),

                        Column(
                          children: [
                            SizedBox(
                              // color: Colors.white,
                              height: layout.getHeight(200),
                              width: double.infinity,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width * 0.32,
                                    height: MediaQuery.of(context).size.width * 0.40,
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
                                            dashboardController.setSignInButtonClicked(true);
                                            dashboardController.setSignOutButtonClicked(false);
                                            // Add your custom logic here
                                          },
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
                                    width: MediaQuery.of(context).size.width * 0.32,
                                    height: MediaQuery.of(context).size.width * 0.40,
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
                                            dashboardController.setSignOutButtonClicked(true);
                                            dashboardController.setSignInButtonClicked(false);
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

                            dashboardController.isSignInButtonClicked.value
                                ? Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 26),
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
                                        Container(
                                          width: MediaQuery.of(context).size.width * 0.35,
                                          height: MediaQuery.of(context).size.width * 0.40,
                                          child: GestureDetector(
                                            onTap: () {
                                              navigateToCameraPage();
                                            },
                                            child: _buildCard(
                                              color: 0xff74c2c6,
                                              image: 'assets/images/ic_camera.png',
                                              title: 'Camera',
                                              description: dashboardController.signInBase64Image.value != ""
                                                  ? 'Image Captured'
                                                  : 'Capture Image',
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context).size.width *0.1,
                                        ),
                                        Container(
                                          width: MediaQuery.of(context).size.width * 0.35,
                                          height: MediaQuery.of(context).size.width * 0.40,
                                          child: _buildCard(
                                            color: 0xff74c2c6,
                                            image: 'assets/images/ic_gps.png',
                                            title: 'GPS',
                                            description: dashboardController.accuracy.value == 100
                                                ? 'Loading!'
                                                : 'Accuracy: ${dashboardController.accuracy.value.toString()}',

                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Checkbox(
                                            value: dashboardController.showRemark.value,
                                            onChanged: (value) {
                                              dashboardController.toggleShowRemark(value ?? false);
                                            },
                                          ),
                                          const Text(
                                            "Write remarks",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),

                                    (dashboardController.showRemark.value)
                                        ? Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                      child: Container(
                                        width: MediaQuery.of(context).size.width * 0.9,
                                        height: MediaQuery.of(context).size.height * 0.07,
                                        color: const Color(0xff333333),
                                        child: TextField(
                                          controller: dashboardController.remarkController.value,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                          ),
                                          maxLines: 1,
                                          keyboardType: TextInputType.multiline,
                                          decoration: const InputDecoration(
                                            hintStyle: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xff808080),
                                            ),
                                            border: OutlineInputBorder(),
                                            hintText: 'Remark...',
                                          ),
                                        ),
                                      ),
                                    )
                                        : const SizedBox(),
                                    // Return an empty widget if showRemark is false,

                                    const SizedBox(height: 16),
                                  ],
                                ),


                              ),
                            )
                                : const SizedBox.shrink(),

                            dashboardController.isSignOutButtonClicked.value
                                ? Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 26),
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
                                          Container(
                                            width: MediaQuery.of(context).size.width * 0.35,
                                            height: MediaQuery.of(context).size.width * 0.40,
                                            child: GestureDetector(
                                              onTap: () {
                                                navigateToCameraPage();
                                              },
                                              child: _buildCard(
                                                image: 'assets/images/ic_camera.png',
                                                title: 'Camera',
                                                description: dashboardController.signOutBase64Image.value != ""
                                                    ? 'Image Captured'
                                                    : 'Capture Image',
                                                color: 0xfffed593,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context).size.width *0.1,
                                          ),
                                          Container(
                                            width: MediaQuery.of(context).size.width * 0.35,
                                            height: MediaQuery.of(context).size.width * 0.40,
                                            child: _buildCard(
                                              image: 'assets/images/ic_gps.png',
                                              title: 'GPS',
                                              description: dashboardController.accuracy.value == 100
                                                  ? 'Loading!'
                                                  : 'Accuracy: ${dashboardController.accuracy.value.toString()}',

                                              color: 0xfffed593,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Checkbox(
                                              value: dashboardController.showRemark.value,
                                              onChanged: (value) {
                                                dashboardController.toggleShowRemark(value ?? false);
                                              },
                                            ),
                                            const Text(
                                              "Write remarks",
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),

                                      (dashboardController.showRemark.value)
                                          ? Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                        child: Container(
                                          width: MediaQuery.of(context).size.width * 0.8,
                                          height: MediaQuery.of(context).size.height * 0.07,
                                          color: const Color(0xff333333),
                                          child: TextField(
                                            controller: dashboardController.remarkController.value,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                            ),
                                            maxLines: 1,
                                            keyboardType: TextInputType.multiline,
                                            decoration: const InputDecoration(
                                              hintStyle: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xff808080),
                                              ),
                                              border: OutlineInputBorder(),
                                              hintText: 'Remark...',
                                            ),
                                          ),
                                        ),
                                      )
                                          : const SizedBox(),
                                      // Return an empty widget if showRemark is false,

                                      const SizedBox(height: 16),
                                    ],
                                  )),
                            )
                                : const SizedBox.shrink(),
                            GestureDetector(
                              onTap: () {
                                // Handle button click here
                                dashboardController.setLoading(true);
                                sendAttendanceData(context);
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
                                  if (dashboardController.isLoading.value)
                                    const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                                    ),
                                ],
                              ),
                            )
                          ],
                        ),


                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
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
            const SizedBox(
              height: 6,
            ),
            Text(
              title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
              child: Image.asset(
                image,
                height: 70,
                width:  70,
                color: Color(color),
                fit: BoxFit.fill,
                // Adjust the fit based on your requirement
              ),
            ),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Future<void> navigateToCameraPage() async {
    // Navigate to the camera page and wait for the result
    String? base64Image = await Get.to(() => CameraPage());

    // Handle the base64Image received from the camera page
    if (base64Image != null) {
      // Do something with the base64 image, e.g., display it
      print('Received base64 image: $base64Image');
      if (dashboardController.isSignInButtonClicked.value) {
        dashboardController.setSignInBase64Image(base64Image);
      }
      if (dashboardController.isSignOutButtonClicked.value) {
        dashboardController.setSignOutBase64Image(base64Image);
      }
    } else {
      // Handle the case where the user canceled or an error occurred
      print('Image capture canceled or error occurred');
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
}
