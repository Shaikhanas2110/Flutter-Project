import 'package:flutter/material.dart';
import 'package:my_app/views/data/classes/theme_provider.dart';
import 'package:my_app/views/page/home_page.dart';
import 'package:my_app/views/page/register_page.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  String email = "";
  String password = "";
  late bool _obscurePassword;

  // Brand colors
  static const Color _bg = Color(0xFF0B0F1A);
  static const Color _surface = Color(0xFF0F1424);
  static const Color _indigo = Color(0xFF6366F1);
  static const Color _cyan = Color(0xFF06B6D4);
  static const Color _indigoLight = Color(0xFF818CF8);
  static const Color _amber = Color(0xFFF59E0B);

  String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  Future<void> loginUser(BuildContext context) async {
    _formKey.currentState!.save();
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Login successful",
            style: GoogleFonts.dmSans(color: Colors.white),
          ),
          backgroundColor: _indigo,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );

      context.read<ThemeProvider>().refreshThemeForUser();
    } on FirebaseAuthException catch (e) {
      String message = "Login failed";
      if (e.code == 'user-not-found') {
        message = "User not found";
      } else if (e.code == 'wrong-password') {
        message = "Incorrect password";
      } else if (e.code == 'invalid-email') {
        message = "Invalid email format";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.dmSans(color: Colors.white),
          ),
          backgroundColor: const Color(0xFFE24B4A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Something went wrong",
            style: GoogleFonts.dmSans(color: Colors.white),
          ),
          backgroundColor: const Color(0xFFE24B4A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _obscurePassword = true;
  }

  Widget _buildSubPill({
    required String name,
    required String amount,
    required Color dot,
    bool faded = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: faded
            ? const Color(0xFF6366F1).withOpacity(0.08)
            : Colors.white.withOpacity(0.04),
        border: Border.all(
          color: faded
              ? const Color(0xFF6366F1).withOpacity(0.25)
              : Colors.white.withOpacity(0.07),
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: faded
                    ? Colors.white.withOpacity(0.3)
                    : Colors.white.withOpacity(0.55),
              ),
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: faded ? _indigoLight : Colors.white.withOpacity(0.85),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required IconData icon,
    required Function(String?) onSaved,
    required String? Function(String?) validator,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.5),
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 7),
        TextFormField(
          style: GoogleFonts.dmSans(color: Colors.white, fontSize: 14),
          obscureText: isPassword && _obscurePassword,
          keyboardType: isPassword ? null : TextInputType.emailAddress,
          onSaved: onSaved,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.dmSans(
              color: Colors.white.withOpacity(0.2),
              fontSize: 14,
            ),
            prefixIcon: Icon(
              icon,
              color: Colors.white.withOpacity(0.25),
              size: 18,
            ),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.white.withOpacity(0.25),
                      size: 18,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  )
                : null,
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: _indigo.withOpacity(0.7),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE24B4A), width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFE24B4A),
                width: 1.5,
              ),
            ),
            errorStyle: GoogleFonts.dmSans(
              color: const Color(0xFFE24B4A),
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 700;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: isWide ? _buildWideLayout(context) : _buildNarrowLayout(context),
      ),
    );
  }

  // ── Wide layout (tablet / desktop) — sidebar + form side by side ──
  Widget _buildWideLayout(BuildContext context) {
    return Row(
      children: [
        // Sidebar
        SizedBox(width: 340, child: _buildSidebar()),
        Container(width: 1, color: Colors.white.withOpacity(0.06)),
        // Form
        Expanded(
          child: Container(
            color: _surface,
            child: Center(child: _buildFormCard(context)),
          ),
        ),
      ],
    );
  }

  // ── Narrow layout (phone) — stacked ──
  Widget _buildNarrowLayout(BuildContext context) {
    return Container(
      color: _bg,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          children: [
            _buildNarrowHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildFormCard(context),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── Sidebar (wide only) ──
  Widget _buildSidebar() {
    return Container(
      color: _bg,
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_indigo, _cyan],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.wallet_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'SubTracker',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Tagline
          RichText(
            text: TextSpan(
              style: GoogleFonts.dmSerifDisplay(
                fontSize: 28,
                color: Colors.white,
                height: 1.3,
              ),
              children: const [
                TextSpan(text: 'Every subscription,\n'),
                TextSpan(
                  text: 'finally in focus.',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: _indigoLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Track, manage and cancel what you don\'t need.\nStay in control of your spending.',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: Colors.white.withOpacity(0.4),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 28),

          // Subscription pills
          _buildSubPill(name: 'Netflix', amount: '₹649 / mo', dot: _indigo),
          const SizedBox(height: 8),
          _buildSubPill(name: 'Spotify', amount: '₹119 / mo', dot: _cyan),
          const SizedBox(height: 8),
          _buildSubPill(name: 'Adobe CC', amount: '₹1,675 / mo', dot: _amber),
          const SizedBox(height: 8),
          _buildSubPill(
            name: '+ 9 more subscriptions',
            amount: '₹4,800',
            dot: const Color.fromRGBO(255, 255, 255, 0.2),
            faded: true,
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ── Compact header for narrow / phone layout ──
  Widget _buildNarrowHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
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
              Icons.wallet_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'SubTracker',
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ── Form card ──
  Widget _buildFormCard(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Eyebrow
            Text(
              'WELCOME BACK',
              style: GoogleFonts.dmSans(
                fontSize: 11,
                letterSpacing: 2,
                color: _indigo,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sign in',
              style: GoogleFonts.dmSerifDisplay(
                fontSize: 30,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'to your SubTracker account',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: const Color.fromRGBO(255, 255, 255, 0.38),
              ),
            ),
            const SizedBox(height: 32),

            // Email
            _buildField(
              label: 'Email address',
              hint: 'you@example.com',
              icon: Icons.mail_outline_rounded,
              onSaved: (v) => email = v!,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Email is required';
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Password
            _buildField(
              label: 'Password',
              hint: '••••••••',
              icon: Icons.lock_outline_rounded,
              isPassword: true,
              onSaved: (v) => password = v!,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password is required';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),

            // Forgot password
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 8,
                  ),
                ),
                child: Text(
                  'Forgot password?',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: _indigo.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 6),

            // Sign in button
            SizedBox(
              width: double.infinity,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 10
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_indigo, _cyan],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      loginUser(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Sign in',
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 22),

            // Divider
            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: Colors.white.withValues(alpha: 0.07),
                    thickness: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'or continue with',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: Colors.white.withValues(alpha: 0.07),
                    thickness: 1,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Google button
            SizedBox(
              width: double.infinity,
              child: InkWell(
                onTap: () {
                  // Your Google Auth logic here
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white, 
                    border: Border.all(
                      color: const Color(
                        0xFF747775,
                      ), 
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(
                      12,
                    ), // Matching corner smoothness
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'images/download.png',
                        height: 20,
                        width: 20,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Continue with Google',
                        style: TextStyle(
                          fontFamily: 'Roboto', // Official requirement
                          fontSize:
                              15, // Adjusted slightly to match design hierarchy
                          fontWeight: FontWeight
                              .w500, // Product Sans / Roboto Medium style
                          color: const Color(
                            0xFF1F1F1F,
                          ), // Dark charcoal text color
                          letterSpacing: 0.25,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Sign up row
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  );
                },
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "New here? ",
                        style: GoogleFonts.dmSans(
                          color: Colors.white.withValues(alpha: 0.3),
                          fontSize: 13,
                        ),
                      ),
                      TextSpan(
                        text: 'Create an account',
                        style: GoogleFonts.dmSans(
                          color: _indigoLight,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
