import 'package:flutter/material.dart';
import 'package:interspeed_attendance_app/utils/layout_size.dart';

class CustomLoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AppLayout layout = AppLayout(context: context);

    return AlertDialog(
      backgroundColor: Colors.transparent.withOpacity(0),
      contentPadding: EdgeInsets.zero,
      content: FractionallySizedBox(
        widthFactor: 0.35,
        heightFactor: 0.1,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xff333333),
            borderRadius: BorderRadius.circular(6.0), // Adjust the border radius as needed
          ),
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
        ),
      ),
    );
  }
}
