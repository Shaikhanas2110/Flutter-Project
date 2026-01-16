import 'package:flutter/material.dart';
import 'package:my_app/views/page/home_page.dart';
import 'package:my_app/views/page/login_page.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

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

  String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  Future<void> registerUser(BuildContext context) async {
    try {
      // 1️⃣ Create user in Firebase Auth
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );

      final uid = userCredential.user!.uid;

      // 2️⃣ Store user data in Realtime DB
      await FirebaseDatabase.instance.ref().child("users").child(uid).set({
        "username": username,
        "email": email,
        "notify": false,
      });

      // 3️⃣ Success → Navigate
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Registration Successful")));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    } catch (e) {
      // 🔴 REAL ERROR SHOWN HERE
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF000000),
        elevation: 1,
        shadowColor: Colors.white,
      ),
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF000000), Color(0xFF000000)],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height * 0.7,
                ),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.wallet_rounded,
                      size: 100,
                      color: Colors.blueAccent,
                    ),

                    const SizedBox(height: 30),

                    const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 30),

                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Username is required';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              username = value!;
                            },
                            decoration: const InputDecoration(
                              labelText: "Username",
                              labelStyle: TextStyle(color: Colors.grey),
                              errorStyle: TextStyle(color: Colors.redAccent),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.blueAccent,
                                  width: 2,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.redAccent),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.redAccent),
                              ),
                            ),
                          ),

                          const SizedBox(height: 15),

                          /// EMAIL
                          TextFormField(
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.emailAddress,
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
                            onSaved: (value) {
                              email = value!;
                            },
                            decoration: const InputDecoration(
                              labelText: "Email",
                              labelStyle: TextStyle(color: Colors.grey),
                              errorStyle: TextStyle(color: Colors.redAccent),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.blueAccent,
                                  width: 2,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.redAccent),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.redAccent),
                              ),
                            ),
                          ),

                          const SizedBox(height: 15),

                          /// PASSWORD
                          TextFormField(
                            style: const TextStyle(color: Colors.white),
                            controller: _passwordController,
                            obscureText: _obscurePassword == true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password is required';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              password = value!;
                            },
                            decoration: InputDecoration(
                              labelText: "Password",
                              labelStyle: const TextStyle(color: Colors.grey),
                              errorStyle: const TextStyle(
                                color: Colors.redAccent,
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.blueAccent,
                                  width: 2,
                                ),
                              ),
                              errorBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.redAccent),
                              ),
                              focusedErrorBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.redAccent),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 15),

                          /// CONFIRM PASSWORD
                          TextFormField(
                            style: const TextStyle(color: Colors.white),
                            obscureText: _obscureConfirmPassword == true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Confirm your password';
                              }
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: "Confirm Password",
                              labelStyle: const TextStyle(color: Colors.grey),
                              errorStyle: const TextStyle(
                                color: Colors.redAccent,
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.blueAccent,
                                  width: 2,
                                ),
                              ),
                              errorBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.redAccent),
                              ),
                              focusedErrorBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.redAccent),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          /// SIGN UP BUTTON
                          ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                await registerUser(context);
                              }
                            },

                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(20.0),
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 40),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),

                          const SizedBox(height: 10),

                          /// LOGIN
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginPage(),
                                ),
                              );
                            },
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Already have an account? ',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Sign In',
                                    style: TextStyle(
                                      color: Colors.blueAccent,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
