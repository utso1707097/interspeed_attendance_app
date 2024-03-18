import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interspeed_attendance_app/controller/project_details_controller.dart';
import 'package:interspeed_attendance_app/drawer.dart';

class SingleProjectDetails extends StatelessWidget {
  final String userId;
  final Map<String, dynamic> projectDetails;
  final ProjectDetailsController controller =
      Get.put(ProjectDetailsController());

  SingleProjectDetails({required this.userId, required this.projectDetails});

  @override
  @override
  Widget build(BuildContext context) {
    print("the project details: $projectDetails");
    return Scaffold(
      drawer: MyDrawer(context: context),
      backgroundColor: const Color(0xff1a1a1a),
      body: SafeArea(
        child: SingleChildScrollView(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: controller.fetchProjectMembers(
              context,
              userId.toString(),
              projectDetails['project_id'].toString(),
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Show loading indicator while waiting for data
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                if (snapshot.hasError) {
                  // Show error message if an error occurred
                  return const Center(
                    child: Text('Error fetching project members'),
                  );
                } else {
                  // Show project details
                  final List<Map<String, dynamic>> projectMembers =
                      snapshot.data ?? [];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.all(10),
                        height: MediaQuery.of(context).size.height * 0.15,
                        decoration: const BoxDecoration(
                            color: Color(0xff00a0b0),
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                            )),
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              projectDetails['project_name'] ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              projectDetails['sbu_name'] ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            Text(
                              "Started at: ${projectDetails['project_date_start'] ?? ''} ",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            Text(
                              "End at: ${projectDetails['project_date_end'] ?? ''} ",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: projectMembers.length,
                        itemBuilder: (context, index) {
                          final member = projectMembers[index];
                          print("member $index : $member");
                          // You can display member details here as per your requirements
                          return Container(
                            margin: const EdgeInsets.only(
                                bottom: 10, right: 10, left: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xff333333),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  title: Text(
                                    member['employee_name'] ?? '',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        member['project_role_name'] ?? '',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        "Contribution Scale : ${member['contribution_scale_name'] ?? ''}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        "Start Date: ${member['date_start'] ?? ''}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        "End Date: ${member['date_end'] ?? ''}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                      projectDetails["project_role_name"] ==
                                          'Manager' &&
                                          projectDetails['employee_id'] !=
                                              member['employee_id']
                                          ? Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {},
                                            style: ElevatedButton.styleFrom(
                                              primary: Colors.lightBlue, // Change button color
                                              onPrimary:
                                              Colors.white, // Change text color
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    10), // Set border radius
                                              ),
                                            ),
                                            child: Text("Give Point"),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {},
                                            style: ElevatedButton.styleFrom(
                                              primary: Colors.red, // Change button color
                                              onPrimary:
                                              Colors.white, // Change text color
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    10), // Set border radius
                                              ),
                                            ),
                                            child: Text("Delete Member"),
                                          ),
                                        ],
                                      )
                                          : SizedBox.shrink(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            primary: Colors.green, // Change button color to green
                            onPrimary: Colors.white, // Change text color to white
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10), // Set border radius
                            ),
                          ),
                          child: Text("Add Member"), // Change button text
                        ),
                      ),
                    ],
                  );
                }
              }
            },
          ),
        ),
      ),
    );
  }

}
