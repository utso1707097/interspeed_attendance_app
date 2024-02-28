import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardController extends GetxController {
  RxBool isLoading = false.obs;
  RxString signInBase64Image = ''.obs;
  RxString signOutBase64Image = ''.obs;
  RxBool isSignInButtonClicked = false.obs;
  RxBool isSignOutButtonClicked = false.obs;
  RxDouble latitude = RxDouble(-1.0);
  RxDouble longitude = RxDouble(-1.0);
  RxInt accuracy = 100.obs;
  RxBool showRemark = false.obs;
  Rx<TextEditingController> remarkController = TextEditingController().obs;
  RxMap<String, dynamic> sessionData = RxMap<String, dynamic>();

  @override
  void onInit() {
    super.onInit();
    fetchSessionData();
  }

  void clearData() {
    isLoading.value = false;
    signInBase64Image.value = '';
    signOutBase64Image.value = '';
    isSignInButtonClicked.value = false;
    isSignOutButtonClicked.value = false;
    latitude.value = -1.0;
    longitude.value = -1.0;
    accuracy.value = 100;
    showRemark.value = false;
    remarkController.value.clear();
  }

  Future<void> fetchSessionData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    sessionData.value = {
      'user_id': prefs.getString('user_id') ?? '',
      'user_name': prefs.getString('user_name') ?? '',
      'full_name': prefs.getString('full_name') ?? '',
      'user_type_id': prefs.getString('user_type_id') ?? '',
      'user_type_name': prefs.getString('user_type_name') ?? '',
      'sb_name': prefs.getString('sb_name') ?? '',
      'designation_name': prefs.getString('designation_name') ?? '',
      'access_level': prefs.getString('access_level') ?? '',
      'picture_name': prefs.getString('picture_name') ?? '',
      'employee_id': prefs.getString('employee_id') ?? '',
      'designation_id': prefs.getString('designation_id') ?? '',
      'employee_position_id': prefs.getString('employee_position_id') ?? '',
      // Add more key-value pairs as needed...
    };
    // print(sessionData);
    // print("This has been called");
  }

  // Method to set loading state
  void setLoading(bool value) {
    isLoading.value = value;
  }

  void toggleShowRemark(bool value) {
    showRemark.value = value;
  }

  void clearRemark() {
    remarkController.value.clear();
  }

  // Method to set sign-in base64 image
  void setSignInBase64Image(String value) {
    signInBase64Image.value = value;
  }

  // Method to set sign-out base64 image
  void setSignOutBase64Image(String value) {
    signOutBase64Image.value = value;
  }

  // Method to set sign-in button clicked state
  void setSignInButtonClicked(bool value) {
    isSignInButtonClicked.value = value;
  }

  // Method to set sign-out button clicked state
  void setSignOutButtonClicked(bool value) {
    isSignOutButtonClicked.value = value;
  }

  // Method to set latitude
  void setLatitude(double value) {
    latitude.value = value;
  }

  // Method to set longitude
  void setLongitude(double value) {
    longitude.value = value;
  }

  // Method to set accuracy
  void setAccuracy(int value) {
    accuracy.value = value;
  }

  void updateLocation(Position currentPosition) {
    latitude.value = currentPosition.latitude;
    longitude.value = currentPosition.longitude;
    accuracy.value = currentPosition.accuracy.toInt();
  }

  void showAttendanceDialog(
      BuildContext context, String title, String message, int statusCode) {
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
