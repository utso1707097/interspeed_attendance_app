import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  final Map<String, dynamic> sessionData;

  DashboardPage({required this.sessionData});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    final  userId = widget.sessionData['user_id'];
    final String userName = widget.sessionData['user_name'];
    final String fullName = widget.sessionData['full_name'];
    final userTypeId = widget.sessionData['user_type_id'];
    final pictureName = widget.sessionData['picture_name'];
    final userTypeName = widget.sessionData['user_type_name'];
    final employeeId = widget.sessionData['employee_id'];
    final designationId = widget.sessionData['designation_id'];
    final employeePositionId = widget.sessionData['employee_position_id'];
    return Scaffold(
      appBar: AppBar(

        title: const Text(
          'Attendance',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.blue[600],
        // automaticallyImplyLeading: false,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              padding: const EdgeInsets.all(0),
              child: UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: Colors.blue[600]),
                accountName: Text("$fullName"),
                accountEmail: const Text("utso097.csekuet@gmail.com"),
                onDetailsPressed: () {
                  //MySnackBar(Text("User account drawer header tapped"), context);
                },
                currentAccountPicture: Image.network(
                  "https://winaero.com/blog/wp-content/uploads/2017/12/User-icon-256-blue.png"
                ),
              ),
            ),
            const ListTile(
              leading: Icon(Icons.home),
              title: Text("Home"),
            ),
            const ListTile(
              leading: Icon(Icons.person),
              title: Text("Profile"),
            ),
            const ListTile(
              leading: Icon(Icons.email),
              title: Text("Email"),
            ),
            const ListTile(
              leading: Icon(Icons.phone),
              title: Text("Phone"),
            ),
            const ListTile(
              leading: Icon(Icons.contact_page),
              title: Text("Contact"),
            ),
          ],
        ),
      ),
      body: Container(
        child: Text(
          'Welcome $userName',
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
