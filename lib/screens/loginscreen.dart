import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants.dart'; // Ensure primaryColor is defined here
import 'package:admin/screens/main/main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();//final declares a variable that can only be set once
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? errorMessage;

  Future<void> allowAdminToLogin() async {//function to allow for login
    try {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Please Wait...",
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        backgroundColor: primaryColor,
      ));

      final UserCredential authResult = await FirebaseAuth.instance.signInWithEmailAndPassword(//method to signin
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final currentAdmin = authResult.user;
      if (currentAdmin != null) {
        final adminDoc = await FirebaseFirestore.instance.collection("admins").doc(currentAdmin.uid).get();
        if (adminDoc.exists) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainScreen()));
        } else {
          setState(() {
            errorMessage = "Admin does not exist.";
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Login failed: ${e.toString()}",
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
        backgroundColor: primaryColor,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(screenWidth < 400 ? 8.0 : 16.0), // Adjust padding for small screens
            child: Card(
              color: secondaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(screenWidth < 400 ? 16.0 : 24.0), // Adjust padding inside card
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/logoadmin.png',
                      height: screenWidth < 400 ? 120 : 180, // Smaller image for small screens
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Admin Login",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: screenWidth < 400 ? 20 : 24, // Smaller font size for small screens
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: screenWidth < 400 ? 300 : 400, // Adjust max width
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: _emailController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: const TextStyle(color: Colors.white54),
                              prefixIcon: const Icon(Icons.email, color: Colors.white54),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: primaryColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: primaryColor),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: const TextStyle(color: Colors.white54),
                              prefixIcon: const Icon(Icons.lock, color: Colors.white54),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                  color: Colors.white54,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: primaryColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: primaryColor),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ],
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: allowAdminToLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth < 400 ? 24 : 32,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        "Login",
                        style: TextStyle(color: Colors.white, fontSize: 16),
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