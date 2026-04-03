import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          _buildHeader(context), // ✅ FIX context

          Expanded(
            child: Row(
              children: [
                // ===== LEFT: CONTACTS =====
                Container(
                  width: 250,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                        right: BorderSide(color: Colors.grey.shade300)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        width: double.infinity,
                        child: Text(
                          "Contacts",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          children: [
                            _buildContact("User A", true),
                            _buildContact("User B", false),
                            _buildContact("User C", true),
                            _buildContact("User D", false),
                            Divider(),
                            ListTile(
                              leading: Icon(Icons.group_add),
                              title: Text("New Group"),
                            ),
                            ListTile(
                              leading: Icon(Icons.person_add),
                              title: Text("Add Friend"),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ===== CENTER: CHAT =====
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        height: 60,
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                              bottom:
                                  BorderSide(color: Colors.grey.shade300)),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(child: Icon(Icons.person)),
                            SizedBox(width: 10),
                            Text(
                              "User A",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),

                      Expanded(
                        child: ListView(
                          padding: EdgeInsets.all(16),
                          children: [
                            _buildMessage("Xin chào!", false),
                            _buildMessage("Bạn khỏe không?", true),
                            _buildMessage("Tớ ổn, còn bạn?", false),
                          ],
                        ),
                      ),

                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        color: Colors.white,
                        child: Row(
                          children: [
                            Icon(Icons.emoji_emotions_outlined),
                            SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: "Type a message...",
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.send, color: Colors.blue),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===== HEADER FIXED =====
  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2F80ED), Color(0xFF56CCF2)],
        ),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4),
        ],
      ),
      child: Row(
        children: [
          Row(
            children: [
              Icon(Icons.chat_bubble_outline, color: Colors.white),
              SizedBox(width: 8),
              Text(
                "Real-Time Chat",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          Spacer(),

          // Search
          Container(
            width: 250,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Icon(Icons.search, size: 18, color: Colors.grey),
                SizedBox(width: 5),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search...",
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Spacer(),

          // Right side
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                child: Icon(Icons.person, size: 16),
              ),
              SizedBox(width: 8),
              Text("User Name", style: TextStyle(color: Colors.white)),

              SizedBox(width: 10),

              // 🔔 Notification
              Stack(
                children: [
                  IconButton(
                    icon: Icon(Icons.notifications, color: Colors.white),
                    onPressed: () {
                      Navigator.pushNamed(context, '/notifications');
                    },
                  ),
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        "1",
                        style:
                            TextStyle(fontSize: 8, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(width: 10),

              // ⚙️ Settings
              IconButton(
                icon: Icon(Icons.settings, color: Colors.white),
                onPressed: () {
                  Navigator.pushNamed(context, '/settings');
                },
              ),

              SizedBox(width: 10),

              // 🔌 Logout
              IconButton(
                icon: Icon(Icons.power_settings_new, color: Colors.white),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildContact(String name, bool online) {
    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(child: Icon(Icons.person)),
          if (online)
            Positioned(
              right: 0,
              bottom: 0,
              child: CircleAvatar(
                radius: 5,
                backgroundColor: Colors.green,
              ),
            )
        ],
      ),
      title: Text(name),
    );
  }

  Widget _buildMessage(String text, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[200] : Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(text),
      ),
    );
  }
}