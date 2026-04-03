import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  final List<String> notifications = [
    "User A sent you a message",
    "User B is now online",
    "3 new messages unread",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.notifications),
            SizedBox(width: 8),
            Text("Notifications"),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: Icon(Icons.circle_notifications, color: Colors.blue),
              title: Text(notifications[index]),
              onTap: () {
                // Xử lý khi người dùng nhấn vào thông báo
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Bạn chọn: ${notifications[index]}")),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
