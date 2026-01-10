import 'package:flutter/material.dart';
import 'package:my_app/views/page/home_page.dart';
import 'package:my_app/views/page/register_page.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  Future<void> loginUser(BuildContext context) async {
    _formKey.currentState!.save();
    try {
      // Firebase Auth handles password verification
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Login successful")));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String message = "Login failed";

      if (e.code == 'user-not-found') {
        message = "User not found";
      } else if (e.code == 'wrong-password') {
        message = "Incorrect password";
      } else if (e.code == 'invalid-email') {
        message = "Invalid email format";
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Something went wrong")));
    }
  }

  @override
  void initState() {
    super.initState();
    _obscurePassword = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF000000),
        foregroundColor: Colors.white,
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
                      'Login',
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
                          /// EMAIL
                          TextFormField(
                            style: const TextStyle(color: Colors.white),
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
                            obscureText: _obscurePassword == true,
                            onSaved: (value) {
                              password = value!;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password is required';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
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

                          const SizedBox(height: 30),

                          /// LOGIN BUTTON
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                loginUser(context);
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
                              'Login',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),

                          const SizedBox(height: 10),

                          /// REGISTER
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RegisterPage(),
                                ),
                              );
                            },
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Don't have an account? ",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Sign Up',
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
