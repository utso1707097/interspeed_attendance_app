import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'camera_page_with_galary.dart';
import 'controller/update_profile_controller.dart';
import 'package:http/http.dart' as http;

class UpdateProfilePage extends StatelessWidget {
  final List<Map<String, dynamic>> resultList;

  UpdateProfilePage({required this.resultList});
  final EmployeeUpdateController controller =
  Get.put(EmployeeUpdateController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1a1a1a),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child:
                Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Card
                Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Card(
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Container(
                          width: 100.0,
                          height: 100.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: controller.imagePath.value.isEmpty
                                ? resultList[0]['picture_name'] != ""
                                ? Image.network(
                              'https://br-isgalleon.com/image_ops/employee/${resultList[0]['picture_name'].toString()}',
                              width: MediaQuery.of(context).size.width * 0.2,
                              height: MediaQuery.of(context).size.height * 0.2,
                              fit: BoxFit.cover,
                            )
                                : Image.asset(
                              'assets/images/person.png',
                              fit: BoxFit.cover,
                            )
                                : Image.file(
                              File(controller.imagePath.value),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.red),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CameraPageWithGallery(controller: controller),
                            ),
                          );

                          if (result != null) {
                            print('Image picked from gallery: $result');
                          }
                        },
                      ),
                    ],
                  ),
                ),


                // Text Fields
                buildTextField(
                  "Name",
                  controller.employeeName,
                  resultList.isNotEmpty ? resultList[0]['name'] : null,
                ),
                buildTextField(
                  "Date of Birth",
                  controller.dateOfBirth,
                  resultList.isNotEmpty ? resultList[0]['date_of_birth'] : null,
                ),
                buildTextField(
                  "Official Mobile",
                  controller.officialMobile,
                  resultList.isNotEmpty ? resultList[0]['mobile_offical'] : null,
                ),
                buildTextField(
                  "Present Address",
                  controller.presentAddress,
                  resultList.isNotEmpty ? resultList[0]['present_address'] : null,
                ),
                buildTextField(
                  "Permanent Address",
                  controller.permanentAddress,
                  resultList.isNotEmpty ? resultList[0]['permanent_address'] : null,
                ),
                buildTextField(
                  "Father Name",
                  controller.fatherName,
                  resultList.isNotEmpty ? resultList[0]['father_name'] : null,
                ),
                buildTextField(
                  "Mother Name",
                  controller.motherName,
                  resultList.isNotEmpty ? resultList[0]['mother_name'] : null,
                ),
                buildTextField(
                  "Marital Status",
                  controller.maritalStatus,
                  resultList.isNotEmpty ? resultList[0]['marital_status'] : null,
                ),
                buildTextField(
                  "Email Personal",
                  controller.emailPersonal,
                  resultList.isNotEmpty ? resultList[0]['email_personal'] : null,
                ),
                buildTextField(
                  "Email Business",
                  controller.emailBusiness,
                  resultList.isNotEmpty ? resultList[0]['email_business'] : null,
                ),
                buildTextField(
                  "Identity Mark",
                  controller.identityMark,
                  resultList.isNotEmpty ? resultList[0]['identity_mark'] : null,
                ),
                buildTextField(
                  "Blood Group",
                  controller.bloodGroup,
                  resultList.isNotEmpty ? resultList[0]['blood_group'] : null,
                ),
                buildTextField(
                  "Religion",
                  controller.religion,
                  resultList.isNotEmpty ? resultList[0]['religion'] : null,
                ),
                buildTextField(
                  "Remark",
                  controller.remark,
                  resultList.isNotEmpty ? resultList[0]['remark'] : null,
                ),


                // Save Button
                Container(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () {
                      updateProfile();
                      // Implement logic to save the updated profile
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Update",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),

        ),
      ),
    );
  }

  Widget buildTextField(String title, RxString value, String? initialValue) {
    final TextEditingController textController = TextEditingController(text: initialValue);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          decoration: BoxDecoration(
            color: const Color(0xff333333),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: TextFormField(
            style: const TextStyle(color: Colors.white),
            controller: textController,
            onChanged: (newValue) => value.value = newValue,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Enter $title",
              hintStyle: const TextStyle(color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  Future<void> updateProfile() async {
    final url = Uri.parse('https://br-isgalleon.com/api/employee/insert_employee.php');
    final SharedPreferences prefs = await SharedPreferences.getInstance();


    // Fetch user_id from shared preferences
    final String? userId = prefs.getString('user_id');
    final String? employeeId = prefs.getString('employee_id');
    // Check if userId is null, handle accordingly
    if (userId == null) {
      print('Error: user_id is null');
      return;
    }
    // Prepare form data
    final formData = {
      'UserId': userId.toString(),
      'TargetEmployeeId': employeeId,
      'EmployeeName': controller.employeeName.value.isNotEmpty ? controller.employeeName.value : (resultList[0]['name'] ?? ''),
      'DateOfBirth': controller.dateOfBirth.value.isNotEmpty ? controller.dateOfBirth.value : (resultList[0]['date_of_birth'] ?? ''),
      'EmployeeMobileOfficial': controller.officialMobile.value.isNotEmpty ? controller.officialMobile.value : (resultList[0]['mobile_offical'] ?? ''),
      'PresentAddress': controller.presentAddress.value.isNotEmpty ? controller.presentAddress.value : (resultList[0]['present_address'] ?? ''),
      'PermanentAddress': controller.permanentAddress.value.isNotEmpty ? controller.permanentAddress.value : (resultList[0]['permanent_address'] ?? ''),
      'MotherName': controller.motherName.value.isNotEmpty ? controller.motherName.value : (resultList[0]['mother_name'] ?? ''),
      'FatherName': controller.fatherName.value.isNotEmpty ? controller.fatherName.value : (resultList[0]['father_name'] ?? ''),
      'MartialStatus': controller.maritalStatus.value.isNotEmpty ? controller.maritalStatus.value : (resultList[0]['marital_status'] ?? ''),
      'EmailAddressPersonal': controller.emailPersonal.value.isNotEmpty ? controller.emailPersonal.value : (resultList[0]['email_personal'] ?? ''),
      'EmailAddressBusiness': controller.emailBusiness.value.isNotEmpty ? controller.emailBusiness.value : (resultList[0]['email_business'] ?? ''),
      'IdentityMark': controller.identityMark.value.isNotEmpty ? controller.identityMark.value : (resultList[0]['identity_mark'] ?? ''),
      'BloodGroup': controller.bloodGroup.value.isNotEmpty ? controller.bloodGroup.value : (resultList[0]['blood_group'] ?? ''),
      'Religion': controller.religion.value.isNotEmpty ? controller.religion.value : (resultList[0]['religion'] ?? ''),
      'Remark': controller.remark.value.isNotEmpty ? controller.remark.value : (resultList[0]['remark'] ?? ''),
    };



    print(formData);

    try {
      final response = await http.post(
        url,
        body: formData,
      );

      if (response.statusCode == 200) {
        // Handle the response as needed
        print('Update successful');
      } else {
        // Handle errors
        print('Update failed: ${response.statusCode}');
      }
    } catch (error) {
      print('Error sending update request: $error');
    }
  }

}
