import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.name});

  final String name;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();

  List<Map<String, dynamic>> messages = [
    {"text": "Hey! How are you?", "isMe": false},
    {"text": "I’m good! What about you?", "isMe": true},
    {"text": "Everything fine here bro!", "isMe": false},
    {"text": "Great to hear!", "isMe": true},
  ];

  void sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      messages.add({"text": _controller.text.trim(), "isMe": true});
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffECE5DD), // WhatsApp chat bg

      appBar: AppBar(
        backgroundColor: const Color(0xff075E54),
        elevation: 0,
        titleSpacing: 0,

        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage("assets/user.jpg"), // change image
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text("online", style: TextStyle(fontSize: 13)),
              ],
            ),
          ],
        ),
        actions: [
          Icon(Icons.videocam),
          SizedBox(width: 20),
          Icon(Icons.call),
          SizedBox(width: 20),
          Icon(Icons.more_vert),
          SizedBox(width: 10),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                bool isMe = messages[index]["isMe"];

                return Align(
                  alignment: isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                      color: isMe ? Color(0xffDCF8C6) : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                        bottomLeft: isMe
                            ? Radius.circular(12)
                            : Radius.circular(0),
                        bottomRight: isMe
                            ? Radius.circular(0)
                            : Radius.circular(12),
                      ),
                    ),
                    child: Text(
                      messages[index]["text"],
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),

          // ---------------- INPUT BAR ---------------- //
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            color: const Color(0xffECE5DD),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.emoji_emotions_outlined),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: () {},
                ),

                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: "Message",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                CircleAvatar(
                  backgroundColor: const Color(0xff075E54),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
