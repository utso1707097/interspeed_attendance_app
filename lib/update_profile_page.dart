import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interspeed_attendance_app/profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'camera_page_with_galary.dart';
import 'controller/update_profile_controller.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:image/image.dart' as img;

import 'utils/custom_loading_indicator.dart';

class UpdateProfilePage extends StatelessWidget {
  final List<Map<String, dynamic>> resultList;
  final GlobalKey<FormState> _formKeyUpdate = GlobalKey<FormState>();

  UpdateProfilePage({required this.resultList});

  final EmployeeUpdateController controller =
      Get.put(EmployeeUpdateController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1a1a1a),
      // resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  // Unfocus the text field when tapping outside
                  FocusScope.of(context).unfocus();
                },
                child: Form(
                  key: _formKeyUpdate, // Add a GlobalKey<FormState> for the Form
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Card
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
                                child: Obx(
                                      () => ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: controller.imagePath.value.isEmpty
                                        ? resultList[0]['picture_name'] != ""
                                        ? Image.network(
                                      'https://br-isgalleon.com/image_ops/employee/${resultList[0]['picture_name'].toString()}',
                                      width: MediaQuery.of(context).size.width * 0.2,
                                      height: MediaQuery.of(context).size.height * 0.2,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        // Handle image loading error
                                        return Image.asset('assets/images/person.png',
                                          width: MediaQuery.of(context).size.width * 0.3,
                                          height: MediaQuery.of(context).size.width * 0.2,
                                        );
                                      },
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
                                )
                                ,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.camera_alt, color: Colors.red),
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CameraPageWithGallery(controller: controller),
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
                        resultList.isNotEmpty ? resultList[0]['name'].toString() : null,
                        controller.fieldModificationStatus,
                        TextInputType.text,
                      ),
                      buildDateField(
                        "Date of Birth",
                        controller.dateOfBirth,
                        resultList.isNotEmpty ? resultList[0]['date_of_birth'].toString()  : null,
                        context,
                        controller.fieldModificationStatus,
                      ),
                      buildTextField(
                          "Emergency Contact Number",
                          controller.officialMobile,
                          resultList.isNotEmpty
                              ? resultList[0]['contact_number_emergency'].toString()
                              : null,
                          controller.fieldModificationStatus,
                          TextInputType.number),
                      buildTextField(
                          "Contact Number",
                          controller.personalMobile,
                          resultList.isNotEmpty
                              ? resultList[0]['contact_number'].toString()
                              : null,
                          controller.fieldModificationStatus,
                          TextInputType.number),
                      buildTextField(
                        "Present Address",
                        controller.presentAddress,
                        resultList.isNotEmpty
                            ? resultList[0]['present_address'].toString()
                            : null,
                        controller.fieldModificationStatus,
                        TextInputType.text,
                      ),
                      buildTextField(
                        "Permanent Address",
                        controller.permanentAddress,
                        resultList.isNotEmpty
                            ? resultList[0]['permanent_address'].toString()
                            : null,
                        controller.fieldModificationStatus,
                        TextInputType.text,
                      ),
                      buildTextField(
                        "Father Name",
                        controller.fatherName,
                        resultList.isNotEmpty ? resultList[0]['father_name'].toString()  : null,
                        controller.fieldModificationStatus,
                        TextInputType.text,
                      ),
                      buildTextField(
                        "Mother Name",
                        controller.motherName,
                        resultList.isNotEmpty ? resultList[0]['mother_name'].toString()  : null,
                        controller.fieldModificationStatus,
                        TextInputType.text,
                      ),
                      // buildTextField(
                      //   "Spouse Name",
                      //   controller.spouseName,
                      //   resultList.isNotEmpty ? resultList[0]['spouse_name'] : null,
                      //   controller.fieldModificationStatus,
                      //   TextInputType.text,
                      // ),
                      // buildTextField(
                      //   "Marital Status",
                      //   controller.maritalStatus,
                      //   resultList.isNotEmpty
                      //       ? resultList[0]['marital_status']
                      //       : null,
                      //   controller.fieldModificationStatus,
                      //   TextInputType.text,
                      // ),
                      buildDropdownField(
                        "Marital Status",
                        controller.maritalStatus,
                        resultList.isNotEmpty
                            ? resultList[0]['marital_status'].toString()
                            : "",
                        controller.fieldModificationStatus,
                        ["Single", "Married", "Divorced", "Widowed"],
                      ),

                      buildDropdownField(
                        "Gender",
                        controller.genderType,
                        resultList.isNotEmpty
                            ? resultList[0]['gender'].toString()
                            : "",
                        controller.fieldModificationStatus,
                        ["Male","Female","Third Gender","Prefer not to say"],
                      ),

                      Obx(()=> Visibility(
                          visible: resultList.isNotEmpty && resultList[0]['is_identification_verified'].toString() == "0",
                  child: Column(
                    children: [
                      // Dropdown field for gender
                      buildDropdownField(
                        "Identification type",
                        controller.identityTypeName,
                        resultList.isNotEmpty ? resultList[0]['identity_type_name'].toString() : "Not Provided",
                        controller.fieldModificationStatus,
                        ["NID", "TIN"],
                      ),

                      // First text field
                      Visibility(
                        visible: controller.identityTypeName.value.toString() == "NID",
                        child: buildTextField(
                          "National Identification Number",
                          controller.identityNumber,
                          resultList.isNotEmpty ? resultList[0]['identity_number'].toString() : null,
                          controller.fieldModificationStatus,
                          TextInputType.number,
                        ),
                      ),

                      // Text field for Tax Identification Number (TIN)
                      Visibility(
                        visible: controller.identityTypeName.value.toString() == "TIN",
                        child: buildTextField(
                          "Tax Identification Number",
                          controller.tinNumber,
                          resultList.isNotEmpty ? resultList[0]['tin_number'] : null,
                          controller.fieldModificationStatus,
                          TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ),
                      ),




                      buildTextField(
                        "Email",
                        controller.emailPersonal,
                        resultList.isNotEmpty
                            ? resultList[0]['email'].toString()
                            : null,
                        controller.fieldModificationStatus,
                        TextInputType.emailAddress,
                      ),
                      // buildTextField(
                      //   "Email Business",
                      //   controller.emailBusiness,
                      //   resultList.isNotEmpty
                      //       ? resultList[0]['email_business']
                      //       : null,
                      //   controller.fieldModificationStatus,
                      //   TextInputType.emailAddress,
                      // ),
                      // buildTextField(
                      //   "Identity Mark",
                      //   controller.identityMark,
                      //   resultList.isNotEmpty ? resultList[0]['identity_mark'] : null,
                      //   controller.fieldModificationStatus,
                      //   TextInputType.text,
                      // ),
                      buildTextField(
                        "Blood Group",
                        controller.bloodGroup,
                        resultList.isNotEmpty ? resultList[0]['blood_group'].toString()  : null,
                        controller.fieldModificationStatus,
                        TextInputType.text,
                      ),
                      buildTextField(
                        "Religion",
                        controller.religion,
                        resultList.isNotEmpty ? resultList[0]['religion'].toString()  : null,
                        controller.fieldModificationStatus,
                        TextInputType.text,
                      ),
                      buildTextField(
                        "Remark",
                        controller.remark,
                        resultList.isNotEmpty ? resultList[0]['remark'].toString()  : null,
                        controller.fieldModificationStatus,
                        TextInputType.text,
                      ),

                      // Save Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            alignment: Alignment.center,
                            child: ElevatedButton(
                              onPressed: () {
                                updateProfile(context);
                                // Implement logic to save the updated profile
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Colors.green,
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

                          Container(
                            alignment: Alignment.center,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => ProfilePage()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                "Cancel",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),

                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String title, RxString value, String? initialValue,
      RxMap<RxString, bool> fieldModificationStatus, TextInputType inputType) {
    RxString rxString = RxString(title);
    final TextEditingController textController = TextEditingController(
        text: fieldModificationStatus[rxString] ?? false
            ? value.value
            : initialValue);

    // Initialize modification status if not present
    if (!fieldModificationStatus.containsKey(rxString)) {
      fieldModificationStatus[rxString] =
          false; // Set to false for the initial value
    }

    // Set the cursor position after the initial value
    final int cursorPosition = textController.text.length;
    textController.selection =
        TextSelection.fromPosition(TextPosition(offset: cursorPosition));

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
            keyboardType: inputType,
            onChanged: (newValue) {
              fieldModificationStatus[rxString] =
                  true; // Update modification status
              value.value = newValue;
            },
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

  Widget buildDropdownField(String title, RxString value, String? initialValue, RxMap<RxString, bool> fieldModificationStatus, List<String> dropdownItems,{bool? identity_type_field}) {
    RxString rxString = RxString(title);

    // Ensure that initialValue is in the dropdownItems list
    if (initialValue != null && !dropdownItems.contains(initialValue)) {
      dropdownItems.insert(0, initialValue);
    }

    final TextEditingController textController = TextEditingController(text: fieldModificationStatus[rxString] ?? false ? value.value : initialValue);

    // Initialize modification status if not present
    if (!fieldModificationStatus.containsKey(rxString)) {
      fieldModificationStatus[rxString] = false; // Set to false for the initial value
    }

    // Set the cursor position after the initial value
    final int cursorPosition = textController.text.length;
    textController.selection = TextSelection.fromPosition(TextPosition(offset: cursorPosition));

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
          child: DropdownButtonFormField<String>(
            dropdownColor: const Color(0xff1a1a1a), // Set the background color
            items: dropdownItems.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(color: Colors.white,fontSize: 16),
                ),
              );
            }).toList(),
            value: value.value.isNotEmpty ? value.value : initialValue,
            onChanged: (newValue) {
              fieldModificationStatus[rxString] = true; // Update modification status
              value.value = newValue!;
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Select $title",
              hintStyle: const TextStyle(color: Colors.grey),
            ),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }


  Widget buildDateField(String title, RxString value, String? initialValue,
      BuildContext context, RxMap<RxString, bool> fieldModificationStatus) {
    RxString rxString = RxString(title);
    final TextEditingController textController = TextEditingController(
        text: fieldModificationStatus[rxString] ?? false
            ? value.value
            : initialValue);

    // Initialize modification status if not present
    if (!fieldModificationStatus.containsKey(rxString)) {
      fieldModificationStatus[rxString] =
          false; // Set to false for initial value
    }

    // Set the initial value after the widget has been built

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
        InkWell(
          onTap: () {
            if (title == 'Date of Birth') {
              selectDate(context, value, textController,rxString);
            }
          },
          child: AbsorbPointer(
            child: Container(
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
          ),
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  Future<void> selectDate(BuildContext context, RxString value,
      TextEditingController textController,RxString rxString) async {
    final DateTime? pickedDate = await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        final double dialogHeight = MediaQuery.of(context).size.height * 0.5;
        final double dialogWidth = MediaQuery.of(context).size.width *0.9;
        return Center(
          child: AlertDialog(
            backgroundColor: const Color(0xFF333333),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(0),
                    height: dialogHeight,
                    width: dialogWidth,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Colors.red,
                          onPrimary: Colors.black,
                          onSurface: Colors.white,
                        ),
                        textButtonTheme: TextButtonThemeData(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.green,
                          ),
                        ),
                      ),
                      child: SfDateRangePicker(
                        view: DateRangePickerView.decade,
                        monthViewSettings: DateRangePickerMonthViewSettings(
                          blackoutDates: [DateTime(2020, 03, 26)],
                          weekendDays: [5],
                          firstDayOfWeek: 1,
                        ),
                        monthCellStyle: DateRangePickerMonthCellStyle(
                          textStyle: const TextStyle(color: Colors.white),
                          blackoutDatesDecoration: BoxDecoration(
                            color: Colors.red,
                            border: Border.all(
                                color: const Color(0xFFF44436), width: 1),
                            shape: BoxShape.circle,
                          ),
                          weekendDatesDecoration: BoxDecoration(
                            color: Colors.red,
                            border: Border.all(
                                color: const Color(0xFFB6B6B6), width: 1),
                            shape: BoxShape.circle,
                          ),
                          specialDatesDecoration: BoxDecoration(
                            color: Colors.green,
                            border: Border.all(
                                color: const Color(0xFF2B732F), width: 1),
                            shape: BoxShape.circle,
                          ),
                          blackoutDateTextStyle: const TextStyle(
                              color: Colors.white,
                              decoration: TextDecoration.lineThrough),
                          specialDatesTextStyle:
                              const TextStyle(color: Colors.white),
                          todayCellDecoration: BoxDecoration(
                            color: const Color(0xFFDFDFDF),
                            border: Border.all(
                                color: const Color(0xFFB6B6B6), width: 1),
                            shape: BoxShape.circle,
                          ),
                          todayTextStyle: const TextStyle(color: Colors.black),
                        ),
                        selectionMode: DateRangePickerSelectionMode.single,
                        headerStyle: const DateRangePickerHeaderStyle(
                          textAlign: TextAlign.center,
                          textStyle: TextStyle(color: Colors.white),
                        ),
                        showActionButtons: true,
                        selectionColor: Colors.green,
                        rangeSelectionColor: Colors.white.withOpacity(0.3),
                        onSelectionChanged:
                            (DateRangePickerSelectionChangedArgs args) {
                          // Update the value and text field when a date is selected
                          value.value = args.value.toString();
                          // Format the selected date to "yyyy-MM-dd"
                          final formattedDate =
                              DateFormat('yyyy-MM-dd').format(args.value);
                          print(formattedDate);
                          controller.fieldModificationStatus[rxString] = true;
                          value.value = formattedDate;

                          // Update the text field with the formatted date
                          textController.text = formattedDate;
                        },
                        onCancel: () {
                          Navigator.of(context).pop(null);
                        },
                        onSubmit: (dynamic value) {
                          controller.fieldModificationStatus[rxString] = true;
                          Navigator.of(context).pop(value);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (pickedDate != null) {
      // Only update the value if it is not null
      final formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      value.value = formattedDate; // Set the value of the date field
    }
  }


  Future<String> convertImageToBase64(String imagePath) async {
    // Read the image file
    File imageFile = File(imagePath);
    List<int> imageBytes = await imageFile.readAsBytes();

    // Decode the image
    img.Image image = img.decodeImage(Uint8List.fromList(imageBytes))!;

    // Encode the image to base64
    String base64Image = base64Encode(img.encodeJpg(image));

    return base64Image;
  }

  void updateProfile(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomLoadingIndicator();
      },
    );
    final url =
    Uri.parse('https://br-isgalleon.com/api/employee/insert_employee.php');
    final photoUploadUrl = Uri.parse(
        'https://br-isgalleon.com/api/employee/save_employee_photo.php');
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Fetch user_id from shared preferences
    final String? userId = prefs.getString('user_id');
    final String? employeeId = prefs.getString('employee_id');
    // Check if userId is null, handle accordingly
    if (userId == null) {
      Navigator.pop(context);
      print('Error: user_id is null');
      return;
    }
    if(employeeId == null){
      Navigator.pop(context);
      print('Error: employee_id is null');
      return;
    }

    // Prepare form data
    final formData = {
      'UserId': userId.toString(),
      'TargetEmployeeId': employeeId.toString(),
      'EmployeeName': controller.employeeName.value.isNotEmpty
          ? controller.employeeName.value
          : (resultList[0]['name'] ?? ''),
      'DateOfBirth': controller.dateOfBirth.value.isNotEmpty
          ? controller.dateOfBirth.value.toString()
          : (resultList[0]['date_of_birth'] ?? ''),

      'ContactNumberEmergency': controller.officialMobile.value.isNotEmpty
          ? controller.officialMobile.value
          : (resultList[0]['contact_number_emergency'] ?? ''),
      'ContactNumber': controller.personalMobile.value.isNotEmpty
          ? controller.personalMobile.value
          : (resultList[0]['contact_number'] ?? ''),
      'Gender': controller.genderType.value.isNotEmpty
          ? controller.genderType.value
          : (resultList[0]['gender'] ?? ''),
      'PresentAddress': controller.presentAddress.value.isNotEmpty
          ? controller.presentAddress.value
          : (resultList[0]['present_address'] ?? ''),
      'PermanentAddress': controller.permanentAddress.value.isNotEmpty
          ? controller.permanentAddress.value
          : (resultList[0]['permanent_address'] ?? ''),
      'MotherName': controller.motherName.value.isNotEmpty
          ? controller.motherName.value
          : (resultList[0]['mother_name'] ?? ''),
      'FatherName': controller.fatherName.value.isNotEmpty
          ? controller.fatherName.value
          : (resultList[0]['father_name'] ?? ''),
      // 'SpousedName': controller.spouseName.value.isNotEmpty
      //     ? controller.spouseName.value
      //     : (resultList[0]['spouse_name'] ?? ''),
      'MartialStatus': controller.maritalStatus.value.isNotEmpty
          ? controller.maritalStatus.value.toString()
          : (resultList[0]['marital_status'] ?? ''),
      'Email': controller.emailPersonal.value.isNotEmpty
          ? controller.emailPersonal.value
          : (resultList[0]['email'] ?? ''),
      // 'EmailAddressBusiness': controller.emailBusiness.value.isNotEmpty
      //     ? controller.emailBusiness.value
      //     : (resultList[0]['email_business'] ?? ''),
      // 'IdentityMark': controller.identityMark.value.isNotEmpty
      //     ? controller.identityMark.value
      //     : (resultList[0]['identity_mark'] ?? ''),
      'IdentityTypeId': controller.identityTypeName.value.isNotEmpty
          ? (controller.identityTypeName.value == 'NID' ? '1' : (controller.identityTypeName.value == 'TIN' ? '0' : ''))
          : (resultList.isNotEmpty ? (resultList[0]['identity_type_id'] ?? '') : ''),
      'IdentityTypeName': controller.identityTypeName.value.isNotEmpty
          ? controller.identityTypeName.value
          : (resultList.isNotEmpty ? (resultList[0]['identity_type_name'] ?? '') : ''),
      'IdentityNumber': controller.identityNumber.value.isNotEmpty
          ? controller.identityNumber.value
          : (resultList[0]['identity_number'] ?? ''),
      'TinNumber': controller.tinNumber.value.isNotEmpty
          ? controller.tinNumber.value
          : (resultList[0]['tin_number'] ?? ''),


      'BloodGroup': controller.bloodGroup.value.isNotEmpty
          ? controller.bloodGroup.value
          : (resultList[0]['blood_group'] ?? ''),
      'Religion': controller.religion.value.isNotEmpty
          ? controller.religion.value
          : (resultList[0]['religion'] ?? ''),
      'Remark': controller.remark.value.isNotEmpty
          ? controller.remark.value
          : (resultList[0]['remark'] ?? ''),
    };

    // print("Hey I am formdata: $formData");
    // formData.forEach((key, value) {
    //   print('$key: ${value.runtimeType}');
    // });
    // print('${controller.imagePath.value}');
    // String base64Image = '';
    // if (controller.imagePath.value != '') {
    //   base64Image =
    //   await convertImageToBase64(controller.imagePath.value);
    // }
    final request = http.MultipartRequest('POST', url);

    try {
      // Add other form fields
      formData.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      // Send the multipart request
      final response = await http.Response.fromStream(await request.send());
      // Add this print statement to check the response body
      print('Response body: ${response.body}');
      print('Response code: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Directly handle the response body
        print('Response body: ${response.body}');

        // Process the response data as needed
        // For example, you may directly use the response body without decoding
        String responseBody = response.body;
        if (responseBody.contains('"success":true')) {
          // Handle success
          if(controller.imagePath.value != ''){
            updateImage(context, userId, employeeId, photoUploadUrl);
            Navigator.pop(context);
            controller.clearValues();
          }
          else{
            Navigator.pop(context);
            print('Update successful');
            controller.clearValues();
          }
          prefs.setString("full_name", formData["EmployeeName"]);
          Navigator.pop(context);
          // Push the previous page with replacement
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ProfilePage()),
          );
          _showAttendacneDialog(
            context,
            "Success",
            "Profile updated successfully!",
            200,
          );
        } else {
          // Handle failure
          Navigator.pop(context);
          print('Update failed: $responseBody');
          _showAttendacneDialog(
            context,
            "Failed",
            "Profile update failed!",
            0,
          );
        }
      }else {
        // Request failed
        Navigator.pop(context);
        print('Request failed with status: ${response.statusCode}');
        // print('${response.body}');
        // Show failure dialog or handle failure scenario as needed
        _showAttendacneDialog(
          context,
          "Failed",
          "Check your internet connection or login again!",
          0,
        );
      }
    } catch (error) {
      // Handle errors
      Navigator.pop(context);
      print('Error sending request: $error');

      // Show failure dialog or handle error scenario as needed
      _showAttendacneDialog(
          context, "Failed", "Check your internet connection from outside", 0);
    }
  }

  void updateImage(BuildContext context, String userId,String employeeId,Uri photoUploadUrl) async{
    print(userId);
    print(employeeId);
    final imageRequest = http.MultipartRequest('POST', photoUploadUrl);
    imageRequest.fields['UserId'] = userId.toString();
    imageRequest.fields['TargetEmployeeId'] = employeeId.toString();

    // Add image data to the request
    if (controller.imagePath.value.isNotEmpty) {
      String base64Image = await convertImageToBase64(controller.imagePath.value);
      imageRequest.fields['ImageData'] = base64Image;

      final imageResponse = await http.Response.fromStream(await imageRequest.send());

      // Handle the image update response
      print('Image Update Response code: ${imageResponse.statusCode}');
      print('Image Update Response body: ${imageResponse.body}');
      if (imageResponse.statusCode == 200) {
        print('Profile image updated successfully!');
      } else {
        print('Failed to update profile image: ${imageResponse.body}');
      }
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
