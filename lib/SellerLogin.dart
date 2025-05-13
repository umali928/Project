import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert'; // For utf8.encode
import 'package:shared_preferences/shared_preferences.dart';
import 'sellerRegister.dart';
import 'sellerdashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? sellerStoreName = prefs.getString('sellerStoreName');

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: sellerStoreName != null ? DashboardScreen() : SellerLoginScreen(),
  ));
}

class SellerLoginScreen extends StatefulWidget {
  const SellerLoginScreen({Key? key}) : super(key: key);

  @override
  State<SellerLoginScreen> createState() => _SellerLoginScreenState();
}

class _SellerLoginScreenState extends State<SellerLoginScreen> {
  final TextEditingController storeNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool isPasswordHidden = true; // Added state for password visibility

  void loginSeller() async {
    setState(() => isLoading = true);

    final storeName = storeNameController.text.trim();
    final password = passwordController.text.trim();
    final hashedInputPassword =
        sha256.convert(utf8.encode(password)).toString();

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please login as user first.")),
        );
        return;
      }

      // 🔥 Only check inside the current logged-in user's sellerInfo
      final sellerInfoSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('sellerInfo')
          .where('storeName', isEqualTo: storeName)
          .get();

      if (sellerInfoSnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Seller info not found")),
        );
        return;
      }

      final data = sellerInfoSnapshot.docs.first.data();
      if (data['password'] != hashedInputPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid password")),
        );
        return;
      }

      // ✅ Save session
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('sellerStoreName', storeName);

      // ✅ Navigate to dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: constraints.maxWidth > 600 ? 200.0 : 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('LSPUMART',
                        style: GoogleFonts.poppins(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 40),
                    Text('Login to your Seller Account',
                        style: GoogleFonts.poppins(
                            fontSize: 35, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Enter your Store Name and password to log in',
                        style: GoogleFonts.poppins(
                            fontSize: 16, color: Colors.grey)),
                    const SizedBox(height: 24),
                    Text('Store Name',
                        style: GoogleFonts.poppins(fontSize: 12)),
                    TextFormField(
                      controller: storeNameController,
                      decoration: const InputDecoration(
                        hintText: 'Enter your Store Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Password', style: GoogleFonts.poppins(fontSize: 12)),
                    TextFormField(
                      controller: passwordController,
                      obscureText: isPasswordHidden, // Use state for visibility
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPasswordHidden
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              isPasswordHidden = !isPasswordHidden;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: isLoading ? null : loginSeller,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF651D32),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text('Log In',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              )),
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Don’t have an account? '),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        SellerRegistrationApp()),
                              );
                            },
                            child: Text('Sign Up',
                                style: GoogleFonts.poppins(color: Colors.blue)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProfilePage()),
                          );
                        },
                        child: Text(
                          'Return to Profile',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF651D32),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
