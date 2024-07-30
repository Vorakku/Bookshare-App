import 'package:flutter/material.dart';

class SaveBookTo extends StatefulWidget {
  @override
  _SaveBookToState createState() => _SaveBookToState();
}

class _SaveBookToState extends State<SaveBookTo> {
  bool _isDefaultChecked = true; // Initial value for checkbox

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Implement create new booklist action
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: Text('Create New Booklist'),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text('Booklist:', style: TextStyle(fontSize: 16)),
          SizedBox(height: 8),
          Row(
            children: [
              Checkbox(
                value: _isDefaultChecked,
                onChanged: (value) {
                  setState(() {
                    _isDefaultChecked = value!;
                  });
                },
              ),
              SizedBox(width: 8),
              Text('Default'),
            ],
          ),
          Row(
            children: [
              Checkbox(
                value: !_isDefaultChecked,
                onChanged: (value) {
                  setState(() {
                    _isDefaultChecked = !value!;
                  });
                },
              ),
              SizedBox(width: 8),
              Text('Booklist 1'),
            ],
          ),
          // Add more checkboxes for additional booklists here
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                ),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Implement the confirm action
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: Text('Confirm'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
