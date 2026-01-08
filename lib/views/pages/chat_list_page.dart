import 'package:flutter/material.dart';
import 'package:my_app/views/data/notifiers.dart';
import 'package:my_app/views/pages/chat_page.dart';

class ChatListPage extends StatelessWidget {
  ChatListPage({super.key});

  final List<Map<String, dynamic>> chats = [
    {"name": "Anas", "message": "Hello My Bro!!", "time": "10:45 AM"},
    {
      "name": "Shlok",
      "message": "What are you doing mann!!",
      "time": "11:50 PM",
    },
    {"name": "Fahad", "message": "Hi Where are you?", "time": "1:00 AM"},
    {"name": "Dad", "message": "Send me money!", "time": "5:00 PM"},
    {"name": "Mom", "message": "Good Job!", "time": "9:45 AM"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff075E54),
        title: Text(
          "WhatsApp",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          Icon(
            Icons.camera_alt,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          SizedBox(width: 20),
          Icon(Icons.search, fontWeight: FontWeight.bold, color: Colors.white),
          SizedBox(width: 20),
          Icon(
            Icons.more_vert,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          SizedBox(width: 20),
        ],
      ),

      body: ListView.builder(
        itemCount: chats.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              ListTile(
                leading: Icon(Icons.person, size: 50),
                title: Text(
                  chats[index]["name"],
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  chats[index]["message"],
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300),
                ),
                trailing: Text(
                  chats[index]["time"],
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w300),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return ChatPage(name: chats[index]["name"]);
                      },
                    ),
                  );
                },
              ),
              Divider(height: 20),
            ],
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Color(0xff075E54),
        child: Icon(Icons.message, color: Colors.white),
      ),
    );
  }
}
