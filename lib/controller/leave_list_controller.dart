import 'package:get/get.dart';

class LeaveListController extends GetxController {
  RxList<Map<String, dynamic>> leaveApplications = <Map<String, dynamic>>[].obs;

  void setLeaveApplications(List<Map<String, dynamic>> applications) {
    leaveApplications.assignAll(applications);
  }
}