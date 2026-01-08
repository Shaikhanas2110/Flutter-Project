import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:my_app/views/page/login_page.dart';

class OnBoardWidget extends StatefulWidget {
  const OnBoardWidget({super.key});

  @override
  State<OnBoardWidget> createState() => OnBoardWidgetState();
}

class OnBoardWidgetState extends State<OnBoardWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF000000), Color(0xFF000000)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset('lotties/Welcome.json'),
              SizedBox(height: 100),
              Text(
                "Manage Your Subscriptions.",
                style: TextStyle(
                  fontSize: 25,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Know where your money goes, Save smarter with every subscription.",
                maxLines: 2,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, color: Colors.grey),
              ),
              SizedBox(height: 50),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return LoginPage();
                        },
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(20.0),
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text('Get Started'.toUpperCase()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
