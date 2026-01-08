import 'package:flutter/material.dart';
import 'package:my_app/views/page/home_page.dart';
import 'package:my_app/views/page/payment_page.dart';
import 'package:my_app/views/page/report_page.dart';
import 'package:my_app/views/page/settings_page.dart';
import 'drawer_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

enum DrawerPage { subscriptions, payments, reports, settings }

class AppDrawer extends StatefulWidget {
  final DrawerPage currentPage;

  const AppDrawer({super.key, required this.currentPage});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String username = "Loading...";

  Future<void> fetchUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ref = FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(user.uid)
        .child("username");

    final snapshot = await ref.get();

    if (snapshot.exists) {
      setState(() {
        username = snapshot.value.toString();
      });
    } else {
      setState(() {
        username = "User";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUsername();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.only(top: 10.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF000000), Color(0xFF000000)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              DrawerItem(
                icon: Icons.subscriptions,
                title: 'Subscriptions',
                isSelected: widget.currentPage == DrawerPage.subscriptions,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          HomeScreen(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                            return child; // no animation
                          },
                    ),
                  );
                },
              ),

              DrawerItem(
                icon: Icons.payment,
                title: 'Payments',
                isSelected: widget.currentPage == DrawerPage.payments,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          PaymentScreen(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                            return child; // no animation
                          },
                    ),
                  );
                },
              ),

              DrawerItem(
                icon: Icons.bar_chart,
                title: 'Reports',
                isSelected: widget.currentPage == DrawerPage.reports,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          ReportsScreen(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                            return child; // no animation
                          },
                    ),
                  );
                },
              ),

              DrawerItem(
                icon: Icons.settings,
                title: 'Settings',
                isSelected: widget.currentPage == DrawerPage.settings,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          SettingsScreen(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                            return child; // no animation
                          },
                    ),
                  );
                },
              ),
              const Spacer(),
              const Divider(color: Color(0xFF1f1f1f)),

              /// USER INFO (BOTTOM)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const CircleAvatar(radius: 22, child: Icon(Icons.person)),
                    const SizedBox(width: 12),
                    Text(
                      username.isNotEmpty ? username : "U",                      
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
