import 'package:get/get.dart';

class EmployeeUpdateController extends GetxController {
  // Employee details
  // RxInt employeeId = RxInt(0);
  RxMap<RxString, bool> fieldModificationStatus = RxMap<RxString, bool>();
  RxString genderType = RxString("");
  RxString identityTypeName = RxString("");
  RxString identityNumber = RxString("");
  RxString tinNumber = RxString("");
  RxString employeeName = RxString("");
  RxString dateOfBirth = RxString("");
  RxString dateOfJoin = RxString("");
  RxString personalMobile = RxString("");
  RxString spouseName = RxString("");
  RxString officialMobile = RxString("");
  RxString presentAddress = RxString("");
  RxString permanentAddress = RxString("");
  RxString fatherName = RxString("");
  RxString motherName = RxString("");
  RxString maritalStatus = RxString("");
  RxString emailPersonal = RxString("");
  RxString emailBusiness = RxString("");
  RxString identityMark = RxString("");
  RxString bloodGroup = RxString("");
  RxString religion = RxString("");
  RxString remark = RxString("");
  RxString pictureName = RxString("");
  RxBool isActive = RxBool(true); // Assuming a boolean value for isActive

  // Designation details
  RxString designationName = RxString("");

  // Image details
  RxString imagePath = RxString(""); // Path to the selected image

  // Methods to set values
  // void setEmployeeId(int id) => employeeId.value = id;
  void setGender(String gender) => genderType.value = gender;
  void setIdentityTypeName(String name) => identityTypeName.value = name;
  void setIdentityNumber(String nid) => identityNumber.value = nid;
  void setTinNumber(String tin) => tinNumber.value = tin;
  void setEmployeeName(String name) => employeeName.value = name;
  void setDateOfBirth(String dob) => dateOfBirth.value = dob;
  void setDateOfJoin(String doj) => dateOfJoin.value = doj;
  void setPersonalMobile(String mobile) => personalMobile.value = mobile;
  void setSpouseName(String name) => spouseName.value = name;
  void setOfficialMobile(String mobile) => officialMobile.value = mobile;
  void setPresentAddress(String address) => presentAddress.value = address;
  void setPermanentAddress(String address) => permanentAddress.value = address;
  void setFatherName(String name) => fatherName.value = name;
  void setMotherName(String name) => motherName.value = name;
  void setMaritalStatus(String status) => maritalStatus.value = status;
  void setEmailPersonal(String email) => emailPersonal.value = email;
  void setEmailBusiness(String email) => emailBusiness.value = email;
  void setIdentityMark(String mark) => identityMark.value = mark;
  void setBloodGroup(String group) => bloodGroup.value = group;
  void setReligion(String religionValue) => religion.value = religionValue;
  void setRemark(String employeeRemark) => remark.value = employeeRemark;
  void setPictureName(String name) => pictureName.value = name;

  bool isFieldModified(RxString field) {
    return fieldModificationStatus[field] ?? false;
  }

  void clearFieldModificationStatus(RxString field) {
    fieldModificationStatus[field] = false;
  }


  // void setIsActive(bool active) => isActive.value = active;

  void setDesignationName(String name) => designationName.value = name;

  // Method to set the image path
  void setImagePath(String path) => imagePath.value = path;

  // Method to clear all values
  void clearValues() {
    // Clear all values
    // employeeId.value = 0;
    fieldModificationStatus.clear();
    spouseName.value = "";
    personalMobile.value = "";
    employeeName.value = "";
    genderType.value = "";
    identityTypeName.value = "";
    identityNumber.value = "";
    tinNumber.value = "";
    dateOfBirth.value = "";
    dateOfJoin.value = "";
    officialMobile.value = "";
    presentAddress.value = "";
    permanentAddress.value = "";
    fatherName.value = "";
    maritalStatus.value = "";
    emailPersonal.value = "";
    emailBusiness.value = "";
    identityMark.value = "";
    bloodGroup.value = "";
    religion.value = "";
    remark.value = "";
    motherName.value = "";
    pictureName.value = "";
    isActive.value = true;

    // Clear designation details
    designationName.value = "";

    // Clear image path
    imagePath.value = "";
  }

}
