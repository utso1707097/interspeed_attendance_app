import 'package:flutter/material.dart';

class AddUserDialog extends StatelessWidget {
  final List<Map<String, dynamic>> resultList;

  const AddUserDialog({Key? key, required this.resultList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? _selectedItem;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7.0),
        //color: const Color(0xff333333),
      ),
      child: AlertDialog(
        backgroundColor: const Color(0xff1a1a1a),
        title: const Text(
          'Select Employee',
          style: TextStyle(color: Colors.white),
        ),
        content: DropdownButtonFormField<Map<String, dynamic>>(
          dropdownColor: const Color(0xff1a1a1a),
          items: resultList.map((item) {
            return DropdownMenuItem<Map<String, dynamic>>(
              value: item,
              child: Text(
                item['name'] ?? '',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }).toList(),
          onChanged: (value) {
            _selectedItem = value;
          },
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.red),
            ),
          ),
          TextButton(
            onPressed: () {
              // Perform add operation with _selectedItem
              if (_selectedItem != null) {
                // Add your logic to handle the selected item
                print("Adding item: $_selectedItem");
              }
              // Navigator.of(context).pop();
            },
            child: const Text(
              'Add',
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );

  }
}
