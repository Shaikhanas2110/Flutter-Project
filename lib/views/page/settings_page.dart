import 'package:flutter/material.dart';
import 'package:flutter_app_lock/flutter_app_lock.dart';
import 'package:my_app/views/data/classes/theme_provider.dart';
import 'package:my_app/views/data/notifiers.dart';
import 'package:my_app/views/page/change_pw.dart';
import 'package:my_app/views/page/contact_page.dart';
import 'package:my_app/views/page/login_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../drawer/app_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notifyUser = false;
  String username = "Loading...";
  final user = FirebaseAuth.instance.currentUser;
  late String email = user?.email ?? "no email";

  // ── Brand colors (Matched from ReportsScreen) ──
  static const Color _bg = Color(0xFF0B0F1A);
  static const Color _card = Color(0xFF131929);
  static const Color _indigo = Color(0xFF6366F1);
  static const Color _cyan = Color(0xFF06B6D4);
  static const Color _border = Color(0x1AFFFFFF);
  static const Color _errorRed = Color(0xFFE24B4A);

  Future<void> savePin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_pin', pin);
  }

  Future<void> fetchUsername() async {
    if (user == null) return;

    final ref = FirebaseDatabase.instance.ref().child("users").child(user!.uid);

    final snapshot = await ref.child("username").get();
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

  Future<void> removePin() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('app_pin');
  }

  void loadNotificationStatus() async {
    if (user == null) return;

    final ref = FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(user!.uid)
        .child("notify");

    final snapshot = await ref.get();

    if (snapshot.exists) {
      setState(() {
        notifyUser = snapshot.value as bool;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUsername();
    loadNotificationStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      drawer: const AppDrawer(currentPage: DrawerPage.settings),
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.white.withOpacity(0.06)),
        ),
        title: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_indigo, _cyan],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.wallet_rounded,
                color: Colors.white,
                size: 17,
              ),
            ),
            const SizedBox(width: 9),
            Text(
              'Substrata',
              style: GoogleFonts.dmSerifDisplay(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(
                Icons.menu_rounded,
                color: Colors.white.withOpacity(0.6),
                size: 24,
              ),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Page Heading ──
              Text(
                'Settings',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 26,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage your profile and application preferences',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.35),
                ),
              ),

              const SizedBox(height: 24),

              // ── User Identity Card ──
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: _card,
                  border: Border.all(color: _border),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            username.isNotEmpty ? username : "User",
                            style: GoogleFonts.dmSans(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            email,
                            style: GoogleFonts.dmSans(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Preferences Section ──
              _buildSectionHeader('Preferences'),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _card,
                  border: Border.all(color: _border),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildSwitchRow(
                      icon: Icons.notifications_on_outlined,
                      title: 'Notifications',
                      subtitle: 'Payment reminders and alerts',
                      value: notifyUser,
                      onChanged: (value) async {
                        setState(() {
                          notifyUser = value;
                        });
                        await FirebaseDatabase.instance
                            .ref("users/${user!.uid}")
                            .update({"notify": notifyUser});
                      },
                    ),
                    _buildDivider(),
                    _buildSwitchRow(
                      icon: Icons.dark_mode_outlined,
                      title: themeNotifier.value == ThemeMode.dark
                          ? "Dark Mode"
                          : "Light Mode",
                      subtitle: 'Always Enabled',
                      value: context.watch<ThemeProvider>().isDark,
                      onChanged: (val) {
                        context.read<ThemeProvider>().toggleTheme(val);
                      },
                    ),
                    _buildDivider(),
                    _buildActionRow(
                      icon: Icons.wallet_outlined,
                      title: 'Currency',
                      subtitle: 'USD (\$)',
                      onTap:
                          () {}, // Handled by standard Dropdown design layout
                      trailing: DropdownButtonHideUnderline(
                        child: DropdownButton(
                          items: List.empty(),
                          onChanged: (value) {},
                          icon: Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white.withOpacity(0.25),
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Security Section ──
              _buildSectionHeader('Security'),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _card,
                  border: Border.all(color: _border),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildActionRow(
                      icon: Icons.lock_outline_rounded,
                      title: 'Set Pin To Unlock App',
                      subtitle: 'Secure local lock screen',
                      onTap:
                          () {}, // Maintained from structural button empty code block
                    ),
                    _buildDivider(),
                    _buildActionRow(
                      icon: Icons.phone_android_outlined,
                      title: 'Change Password',
                      subtitle: 'Update account password settings',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChangePw(),
                          ),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildActionRow(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'Payment Method',
                      subtitle: '2 Connected',
                      onTap: () {},
                      trailing: DropdownButtonHideUnderline(
                        child: DropdownButton(
                          items: List.empty(),
                          onChanged: (value) {},
                          icon: Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white.withOpacity(0.25),
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Support Section ──
              _buildSectionHeader('Support'),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _card,
                  border: Border.all(color: _border),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildActionRow(
                      icon: Icons.question_mark_rounded,
                      title: 'Help Center',
                      subtitle: 'FAQs and troubleshooting guide',
                      onTap: () {},
                      trailing: DropdownButtonHideUnderline(
                        child: DropdownButton(
                          items: List.empty(),
                          onChanged: (value) {},
                          icon: Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white.withOpacity(0.25),
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                    _buildDivider(),
                    _buildActionRow(
                      icon: Icons.email_outlined,
                      title: 'Contact Support',
                      subtitle: 'Get in touch with our tech desk',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ContactPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ── Logout Action Item ──
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  AppLock.of(context)?.disable();
                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  }
                  removePin();
                  context.read<ThemeProvider>().refreshThemeForUser();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: _errorRed.withOpacity(0.06),
                    border: Border.all(color: _errorRed.withOpacity(0.2)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.logout_rounded,
                        color: _errorRed,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Logout Account',
                        style: GoogleFonts.dmSans(
                          color: _errorRed,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helper Widgets ──────────────────────────────────────────────────────────

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.dmSans(
          fontSize: 11,
          letterSpacing: 1.5,
          color: Colors.white.withOpacity(0.35),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.white.withOpacity(0.04),
    );
  }

  Widget _buildSwitchRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.5), size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.dmSans(
                    color: Colors.white.withOpacity(0.35),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 24,
            child: Transform.scale(
              scale: 0.8,
              child: Switch(
                activeTrackColor: _indigo.withOpacity(0.4),
                activeColor: _cyan,
                inactiveTrackColor: Colors.white.withOpacity(0.08),
                inactiveThumbColor: Colors.white.withOpacity(0.3),
                value: value,
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.white.withOpacity(0.5), size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.dmSans(
                      color: Colors.white.withOpacity(0.35),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            trailing ??
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white.withOpacity(0.25),
                  size: 14,
                ),
          ],
        ),
      ),
    );
  }
}
