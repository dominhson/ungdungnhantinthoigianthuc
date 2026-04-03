import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> notifications = [
    {
      "text": "User A sent you a message",
      "icon": Icons.message,
      "badge": 2
    },
    {
      "text": "User B is now online",
      "icon": Icons.circle,
      "badge": 0
    },
    {
      "text": "3 new messages unread",
      "icon": Icons.mail,
      "badge": 3
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: Container(
          width: 350,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFF2F3E4E), // nền tối giống hình
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.notifications, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        "Notifications",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.close, color: Colors.white70),
                ],
              ),

              SizedBox(height: 10),
              Divider(color: Colors.white24),

              // List notifications
              ...notifications.map((item) {
                return InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Bạn chọn: ${item['text']}")),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        // Icon
                        Stack(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.white10,
                              child: Icon(item['icon'], color: Colors.white),
                            ),

                            // Badge
                            if (item['badge'] > 0)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    item['badge'].toString(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),

                        SizedBox(width: 12),

                        // Text
                        Expanded(
                          child: Text(
                            item['text'],
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}