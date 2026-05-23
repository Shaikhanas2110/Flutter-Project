import 'package:flutter/material.dart';
import 'package:my_app/views/page/home_page.dart';
import 'package:my_app/views/page/payment_page.dart';
import 'package:my_app/views/page/report_page.dart';
import 'package:my_app/views/page/settings_page.dart';
import 'drawer_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';

enum DrawerPage { subscriptions, payments, reports, settings }

class AppDrawer extends StatefulWidget {
  final DrawerPage currentPage;
  const AppDrawer({super.key, required this.currentPage});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  static const Color _bg = Color(0xFF0B0F1A);
  static const Color _indigo = Color(0xFF6366F1);
  static const Color _cyan = Color(0xFF06B6D4);

  String username = "";
  String email = "";

  Future<void> fetchUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Grab email from Auth directly
    setState(() {
      email = user.email ?? "";
    });

    final ref = FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(user.uid)
        .child("username");

    final snapshot = await ref.get();
    setState(() {
      username = snapshot.exists ? snapshot.value.toString() : "User";
    });
  }

  String get _initials {
    if (username.isEmpty) return "U";
    final parts = username.trim().split(" ");
    if (parts.length >= 2) {
      return "${parts[0][0]}${parts[1][0]}".toUpperCase();
    }
    return username[0].toUpperCase();
  }

  void _navigate(BuildContext context, Widget page) {
    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        transitionsBuilder: (_, __, ___, child) => child,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: _bg,
      width: 280,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Logo header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_indigo, _cyan],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(
                      Icons.donut_small_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Substrata',
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // ── Section label ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                'MENU',
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  letterSpacing: 1.8,
                  color: Colors.white.withOpacity(0.25),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // ── Nav items ──
            DrawerItem(
              icon: Icons.grid_view_rounded,
              label: 'Subscriptions',
              isSelected: widget.currentPage == DrawerPage.subscriptions,
              onTap: () => _navigate(context, HomeScreen()),
            ),
            DrawerItem(
              icon: Icons.receipt_long_outlined,
              label: 'Payments',
              isSelected: widget.currentPage == DrawerPage.payments,
              onTap: () => _navigate(context, PaymentScreen()),
            ),
            DrawerItem(
              icon: Icons.bar_chart_rounded,
              label: 'Reports',
              isSelected: widget.currentPage == DrawerPage.reports,
              onTap: () => _navigate(context, ReportsScreen()),
            ),
            DrawerItem(
              icon: Icons.tune_rounded,
              label: 'Settings',
              isSelected: widget.currentPage == DrawerPage.settings,
              onTap: () => _navigate(context, SettingsScreen()),
            ),

            const Spacer(),

            // ── Divider ──
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              color: Colors.white.withOpacity(0.07),
            ),

            const SizedBox(height: 16),

            // ── User card ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_indigo, _cyan],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _initials,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            username.isEmpty ? "User" : username,
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (email.isNotEmpty)
                            Text(
                              email,
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                color: Colors.white.withOpacity(0.35),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
