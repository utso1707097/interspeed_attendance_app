import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class DashboardController extends GetxController {
  String currentUserId = "";
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
  RxString appVersion = ''.obs;
  RxString appLink = ''.obs;

  @override
  void onInit() async{
    super.onInit();
    await fetchSessionData();
    await fetchAppVersion();
    // print("The version is: ${appVersion.value} - ${currentUserId}");
    if (appVersion.value!="" && currentUserId!= "") {
      print("called");
      checkForUpdate(
          currentUserId, "interspeed", appVersion.value, Get.context!);
    }
  }

  Future<void> fetchAppVersion() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      appVersion.value = packageInfo.version;
      print("App Version: ${appVersion.value}");
    } catch (e) {
      print('Error fetching app version: $e');
    }
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
    currentUserId = prefs.getString('user_id') ?? '';
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

  Future<void> checkForUpdate(String userId, String appName,
      String currentVersion, BuildContext context) async {
    try {
      // Set up the URL
      final String url =
          'https://br-isgalleon.com/api/app_version/version_check.php';

      // Create the multipart request
      final http.MultipartRequest request =
          http.MultipartRequest('POST', Uri.parse(url));

      String modifiedVersionCode =
          currentVersion.substring(0, currentVersion.length - 2);

      // Add your data to the request
      request.fields['UserId'] = userId;
      request.fields['AppName'] = appName;
      request.fields['CurrentVersion'] = modifiedVersionCode;
      print(request.fields);

      // Send the request
      final http.Response response =
          await http.Response.fromStream(await request.send());
      print("this is the response body: ${response.body}");
      if (response.statusCode == 200) {
        // Request was successful
        Map<String, dynamic> responseData = jsonDecode(response.body);
        // Process the response data, you can handle it according to your requirements

        if (responseData['success']) {
          String message = responseData['message'];

          // Check if the message is "Version detail updated"
          if (message == "New version found.") {
            // Handle the case when a new version is found
            Map<String, dynamic> appInfo = responseData['appInfo'];
            // Extract information from appInfo and take necessary actions
            String appName = appInfo['app_name'];
            String appVersion = appInfo['app_version'];
            String appLocationUrl = appInfo['app_location_url'];
            // Call another function or perform actions based on the new version information
            showUpdateDialog(context, "Update", "Please update your app",
                appLocationUrl, appVersion);
          }
        }
        print("This is response for app response: ${responseData}");
      } else {
        // Request failed
        // print('Request failed with status: ${response.statusCode}');
      }
    } catch (error) {
      // Handle errors
      print('Error sending version check request: $error');
    }
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

  Future<void> downloadFile(String appLocationUrl) async {
    // print(appLocationUrl);
    Uri fileUrl = Uri.parse(appLocationUrl);
    print("This is file url: $fileUrl");
    // const fileUrl = 'YOUR_SHAREABLE_LINK'; // Replace with your shareable link
    if (await canLaunchUrl(fileUrl)) {
      await launchUrl(fileUrl);
    } else {
      throw 'Could not launch $fileUrl';
    }
  }

  void showUpdateDialog(BuildContext context, String title, String message,
      String appLocationUrl, String updatedApkVersion) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF333333),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white),
              ),
              const Icon(
                Icons.arrow_circle_up,
                color: Colors.blue,
              ),
            ],
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 10),
              Text(
                'New Version: $updatedApkVersion',
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                'Your apk version: ${appVersion.value.substring(0, appVersion.value.length - 2)}',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          actions: [
            // Update button instead of cancel
            TextButton(
              onPressed: (){
                downloadFile(appLocationUrl);
              },
              child: const Text('Update', style: TextStyle(color: Colors.red)),
            ),
            TextButton(onPressed:  (){Navigator.pop(context);}, child: const Text('Cancel', style: TextStyle(color: Colors.red)),)
          ],
        );
      },
    );
  }
}
