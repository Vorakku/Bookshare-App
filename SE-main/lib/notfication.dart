import 'package:flutter/material.dart';

class notification extends StatelessWidget {
  const notification({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF23232C), // Matching the dark theme
        title: Text(
          'Your Notification',
          style: TextStyle(color: Colors.white), // Set text color to white
        ),
        // Removed the leading IconButton to remove the back arrow
      ),
      body: Container(
        color: Color(0xFF23232C), // Background color
        child: ListView(
          children: <Widget>[
            NotificationTile(
              iconData: Icons.comment,
              notificationText: 'User commented on your book.',
              onTap: () {
                // Handle view action
              },
            ),
            NotificationTile(
              iconData: Icons.person_add,
              notificationText: 'User angelly has followed you.',
              onTap: () {
                // Handle view action
              },
            ),
            NotificationTile(
              iconData: Icons.favorite_border,
              notificationText: 'User liked your book.',
              onTap: () {
                // Handle view action
              },
            ),
            NotificationTile(
              iconData: Icons.reply,
              notificationText: 'User replied to your comment.',
              onTap: () {
                // Handle view action
              },
            ),
          ],
        ),
      ),
    );
  }
}


class NotificationTile extends StatelessWidget {
  final IconData iconData;
  final String notificationText;
  final VoidCallback onTap;

  NotificationTile({
    required this.iconData,
    required this.notificationText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(iconData, color: Colors.white),
      title: Text(
        notificationText,
        style: TextStyle(color: Colors.white),
      ),
      trailing: TextButton(
        onPressed: onTap,
        child: Text('View', style: TextStyle(color: Colors.blue)),
      ),
      tileColor: Color(0xFF3A3A45),
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    );
  }
}
