import 'package:flutter/material.dart';
import 'package:my_app/views/pages/chat_list_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.wallet, size: 80, color: Color(0xff25D366)),
                      SizedBox(height: 25),
                      Text(
                        "WELCOME",
                        style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 25),
                      SizedBox(
                        width: 500,
                        child: Center(
                          child: TextField(
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(width: 1.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.blue,
                                  width: 2.0,
                                ), // selected color
                                borderRadius: BorderRadius.circular(12),
                              ),
                              border: OutlineInputBorder(),
                              hintText: "Email",
                              prefixIcon: Icon(
                                Icons.email,
                                color: Color(0xff25D366),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 18,
                              ),
                            ),
                            onEditingComplete: () {
                              setState(() {});
                            },
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                      ),
                      SizedBox(height: 25),
                      SizedBox(
                        width: 500,
                        child: Center(
                          child: TextField(
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(width: 1.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.blue,
                                  width: 2.0,
                                ), // selected color
                                borderRadius: BorderRadius.circular(12),
                              ),
                              border: OutlineInputBorder(),
                              hintText: "Password",
                              prefixIcon: Icon(
                                Icons.remove_red_eye,
                                color: Color(0xff25D366),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 18,
                              ),
                            ),
                            onEditingComplete: () {
                              setState(() {});
                            },
                            keyboardType: TextInputType.visiblePassword,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: 500,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            MaterialButton(
                              onPressed: () {},
                              child: Text("Forget Password?"),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 25),
                      SizedBox(
                        width: 500,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xff25D366),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return ChatListPage();
                                },
                              ),
                            );
                          },
                          child: Text(
                            "Submit",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
