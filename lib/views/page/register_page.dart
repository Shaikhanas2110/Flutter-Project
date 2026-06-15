import 'package:flutter/material.dart';
import 'package:my_app/views/page/home_page.dart';
import 'package:my_app/views/page/login_page.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  late bool _obscurePassword;
  late bool _obscureConfirmPassword;

  String username = "";
  String email = "";
  String password = "";

  // Brand colors
  static const Color _bg = Color(0xFF0B0F1A);
  static const Color _indigo = Color(0xFF6366F1);
  static const Color _cyan = Color(0xFF06B6D4);
  static const Color _errorRed = Color(0xFFE24B4A);

  String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  Future<void> registerUser(BuildContext context) async {
    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );

      final uid = userCredential.user!.uid;

      await FirebaseDatabase.instance.ref().child("users").child(uid).set({
        "username": username,
        "email": email,
        "notify": false,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Account created!",
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error: $e",
            style: GoogleFonts.dmSans(color: Colors.white),
          ),
          backgroundColor: _errorRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      debugPrint("REGISTER ERROR: $e");
    }
  }

  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _obscurePassword = true;
    _obscureConfirmPassword = true;
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Widget _buildField({
    required String label,
    required String hint,
    required IconData icon,
    required Function(String?) onSaved,
    required String? Function(String?) validator,
    bool isPassword = false,
    bool isConfirm = false,
    TextEditingController? controller,
  }) {
    final obscure = isConfirm ? _obscureConfirmPassword : _obscurePassword;

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
          controller: controller,
          style: GoogleFonts.dmSans(color: Colors.white, fontSize: 14),
          obscureText: (isPassword || isConfirm) && obscure,
          keyboardType: (!isPassword && !isConfirm)
              ? TextInputType.emailAddress
              : null,
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
            suffixIcon: (isPassword || isConfirm)
                ? IconButton(
                    icon: Icon(
                      obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.white.withOpacity(0.25),
                      size: 18,
                    ),
                    onPressed: () => setState(() {
                      if (isConfirm) {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      } else {
                        _obscurePassword = !_obscurePassword;
                      }
                    }),
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
              borderSide: const BorderSide(color: _errorRed, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _errorRed, width: 1.5),
            ),
            errorStyle: GoogleFonts.dmSans(color: _errorRed, fontSize: 12),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top bar ──
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Row(
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white.withOpacity(0.6),
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Logo
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
                    const SizedBox(width: 8),
                    Text(
                      'SubTracker',
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // ── Heading ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GET STARTED',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        letterSpacing: 2,
                        color: _indigo,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create account',
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 30,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Start tracking your subscriptions today',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.38),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ── Form ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Username
                      _buildField(
                        label: 'Username',
                        hint: 'johndoe',
                        icon: Icons.person_outline_rounded,
                        onSaved: (v) => username = v!,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Username is required';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Email
                      _buildField(
                        label: 'Email address',
                        hint: 'you@example.com',
                        icon: Icons.mail_outline_rounded,
                        onSaved: (v) => email = v!,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Email is required';
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value))
                            return 'Enter a valid email';
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
                        controller: _passwordController,
                        onSaved: (v) => password = v!,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Password is required';
                          if (value.length < 6)
                            return 'Password must be at least 6 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password
                      _buildField(
                        label: 'Confirm password',
                        hint: '••••••••',
                        icon: Icons.lock_outline_rounded,
                        isConfirm: true,
                        onSaved: (_) {},
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Confirm your password';
                          if (value != _passwordController.text)
                            return 'Passwords do not match';
                          return null;
                        },
                      ),

                      const SizedBox(height: 28),

                      // ── Sign up button ──
                      SizedBox(
                        width: double.infinity,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [_indigo, _cyan],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                await registerUser(context);
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
                              'Create account',
                              style: GoogleFonts.dmSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Terms note ──
                      Center(
                        child: Text(
                          'By signing up you agree to our Terms & Privacy Policy',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.22),
                            height: 1.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Divider
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.white.withOpacity(0.07),
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'already have an account?',
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.25),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.white.withOpacity(0.07),
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // ── Sign in button ──
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginPage(),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.1),
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: Colors.white.withOpacity(0.04),
                          ),
                          child: Text(
                            'Sign in instead',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
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
}
