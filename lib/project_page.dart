import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interspeed_attendance_app/single_project_details.dart';
import 'package:interspeed_attendance_app/utils/layout_size.dart';
import 'package:shimmer/shimmer.dart';

import 'controller/project_list_controller.dart';
import 'drawer.dart';

class ProjectPage extends StatelessWidget {
  final String userId;
  final String employeeId;
  final ProjectListController controller = Get.put(ProjectListController());

  ProjectPage({required this.userId, required this.employeeId});

  Widget shimmerLoading() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF333333),
      highlightColor: const Color(0xFF1a1a1a),
      child: Container(
        width: double.infinity,
        height: 150, // Adjust the height as needed
        decoration: const BoxDecoration(
          color: Color(0xff333333),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final layout = AppLayout(context: context);
    return Scaffold(
      drawer: MyDrawer(
        context: context,
      ),
      backgroundColor: const Color(0xff1a1a1a),
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: controller.fetchProjects(context, userId, employeeId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Show shimmer loading while waiting for data
              return shimmerLoading();
            } else {
              if (snapshot.hasError) {
                // Handle error case
                return const Center(
                  child: Text('Error loading projects'),
                );
              } else {
                // Show GridView with project names
                final List<Map<String, dynamic>> projects = snapshot.data ?? [];
                return ListView.builder(
                  itemCount: projects.length,
                  itemBuilder: (context, index) {
                    final List<Color> colors = [
                      const Color(0xff00a0b0),
                      const Color(0xffcc3333),
                      const Color(0xff669900),
                      const Color(0xff9933ff),
                      const Color(0xffff8800),
                    ];

                    final projectName = projects[index]['project_name'] != null
                        ? projects[index]['project_name'].toString()
                        : '';
                    final projectRoleName = projects[index]['project_role_name'] != null
                        ? projects[index]['project_role_name'].toString()
                        : '';
                    final colorIndex = index % colors.length;
                    return Container(
                      height: layout.getHeight(100),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: colors[colorIndex],
                      ),
                      margin: const EdgeInsets.all(10), // Change color based on index
                      child: GestureDetector(
                        onTap: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SingleProjectDetails(userId: userId,
                                projectDetails:projects[index]),
                            ),
                          );
                        },
                        child: ListTile(
                          title: Text(
                            projectName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 25,
                              color: Colors.white,
                            ),
                          ),
                          subtitle: Text(
                            projectRoleName,
                            style: const TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
            }
          },
        ),
      ),
    );
  }

}
