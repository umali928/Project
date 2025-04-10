import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart'; // Make sure this file exists and points to your login screen
// import 'dart:typed_data';
import 'package:flutter/services.dart';
class VerifyScreen extends StatefulWidget {
  final User user;
  final String fullName;
  final String email;
  final String profilePicUrl;
   VerifyScreen({
    required this.user,
    required this.fullName,
    required this.email,
    required this.profilePicUrl,
  });


  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Timer _timer;
  bool _resent = false;
  // bool _isInserted = false;
  @override
  void initState() {
    super.initState();
    _startVerificationCheck();
  }

  void _startVerificationCheck() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      await widget.user.reload();
      var refreshedUser = _auth.currentUser;

      if (refreshedUser != null && refreshedUser.emailVerified) {
        // _isInserted = true; // Prevent multiple inserts
        // Insert user data into Firestore
        await _firestore.collection('users').doc(refreshedUser.uid).set({
        'fullName': widget.fullName,
        'email': widget.email,
        'profilePicUrl': widget.profilePicUrl,
        'createdAt': Timestamp.now(),
      });
        timer.cancel();
         // Now that the email is verified, store the data in Firestore
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Verification successful!')));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }

  DateTime? _lastVerificationRequestTime;
  Future<void> _resendVerification() async {
  // Check if it's too soon to resend the verification email
  if (_lastVerificationRequestTime != null &&
      DateTime.now().difference(_lastVerificationRequestTime!).inMinutes < 5) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please wait a few minutes before requesting again')));
    return;
  }

  try {
    if (!widget.user.emailVerified) {
      await widget.user.sendEmailVerification();
      setState(() => _resent = true);
      _lastVerificationRequestTime = DateTime.now();  // Update last request time
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Verification email sent again')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Email is already verified')));
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error resending email: $e")));
  }
}

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFF651D32); // Maroon
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: themeColor,
        title: const Text("Verify Email", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width > 600 ? 60 : 20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Icon(Icons.mark_email_read_rounded, size: 100, color: themeColor),
                const SizedBox(height: 20),
                Text(
                  "Please verify your email",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: themeColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  "We’ve sent an email to:",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                Text(
                  widget.user.email ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                Text(
                  "Click the link in your inbox to verify your email.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(height: 30),
                CircularProgressIndicator(color: themeColor),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: _resendVerification,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Resend Email"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                if (_resent)
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      "Verification email resent!",
                      style: TextStyle(color: Colors.green),
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
