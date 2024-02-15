import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final userData;

  const ProfilePage({Key? key, required this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display user data on the profile page
            Text("${userData['id']}"),
            Text("${userData['name']}"),
            Text("${userData['designation_name']}"),
            // Add more fields as needed
          ],
        ),
      ),
    );
  }
}
