import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChangePw extends StatefulWidget {
  const ChangePw({super.key});

  @override
  State<ChangePw> createState() => _ChangePwState();
}

class _ChangePwState extends State<ChangePw> {
  final _formKey = GlobalKey<FormState>();
  String email = "";
  final TextEditingController emailController = TextEditingController();

  // ── Brand colors (Matched from ReportsScreen & SettingsScreen) ──
  static const Color _bg = Color(0xFF0B0F1A);
  static const Color _card = Color(0xFF131929);
  static const Color _indigo = Color(0xFF6366F1);
  static const Color _cyan = Color(0xFF06B6D4);
  static const Color _border = Color(0x1AFFFFFF);
  static const Color _errorRed = Color(0xFFE24B4A);

  Future<void> resetPassword(BuildContext context, String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: _card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: _border),
          ),
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Password reset email sent. Check your inbox.',
            style: GoogleFonts.dmSans(color: Colors.white, fontSize: 13),
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Something went wrong';

      if (e.code == 'user-not-found') {
        message = 'No user found with this email';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address';
      }

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: _card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: _errorRed),
          ),
          behavior: SnackBarBehavior.floating,
          content: Text(
            message,
            style: GoogleFonts.dmSans(color: _errorRed, fontSize: 13),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: true,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white.withOpacity(0.6)),
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
              'SubTracker',
              style: GoogleFonts.dmSerifDisplay(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Page Heading ──
                Text(
                  'Reset Password',
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 26,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Enter your account details to receive a recovery link',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.35),
                  ),
                ),

                const SizedBox(height: 28),

                // ── Input Container Block ──
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _card,
                    border: Border.all(color: _border),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EMAIL ADDRESS',
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          letterSpacing: 1.5,
                          color: Colors.white.withOpacity(0.35),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        style: GoogleFonts.dmSans(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        onSaved: (value) {
                          email = value!;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email is required';
                          }
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value)) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "name@example.com",
                          hintStyle: GoogleFonts.dmSans(
                            color: Colors.white.withOpacity(0.15),
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: _bg.withOpacity(0.5),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          errorStyle: GoogleFonts.dmSans(
                            color: _errorRed,
                            fontSize: 11,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: _border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: _indigo,
                              width: 1.5,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: _errorRed),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: _errorRed,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Form Action Button ──
                InkWell(
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      resetPassword(context, emailController.text.trim());
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_indigo, _cyan],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: _indigo.withOpacity(0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Send Reset Link',
                        style: GoogleFonts.dmSans(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
