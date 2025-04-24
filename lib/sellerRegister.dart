import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'SellerLogin.dart'; // Import SellerLoginScreen
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert'; // For utf8.encode
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore import
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyBbSQOdsCh7ImLhewcIhHUTcj9-1xbShQk",
          authDomain: "lspumart.firebaseapp.com",
          databaseURL:
              "https://lspumart-default-rtdb.asia-southeast1.firebasedatabase.app",
          projectId: "lspumart",
          storageBucket: "lspumart.firebasestorage.app",
          messagingSenderId: "533992551897",
          appId: "1:533992551897:web:d04a482ad131a0700815c8"),
    );
  } else {
    await Firebase.initializeApp(); // Mobile config
  }
  runApp(SellerRegistrationApp());
}

class SellerRegistrationApp extends StatelessWidget {
  const SellerRegistrationApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SellerRegistrationScreen(),
    );
  }
}

class SellerRegistrationScreen extends StatefulWidget {
  const SellerRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<SellerRegistrationScreen> createState() =>
      _SellerRegistrationScreenState();
}

class _SellerRegistrationScreenState extends State<SellerRegistrationScreen> {
  bool _isPasswordVisible = false;

  final TextEditingController storeNameController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController barangayController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController provinceController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void registerSeller() async {
    if (!_formKey.currentState!.validate()) {
      return; // Stop if validation fails
    }

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No authenticated user found.')),
        );
        return;
      }

      // Check if the user already has a seller account
      final sellerSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('sellerInfo')
          .get();

      if (sellerSnapshot.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You already have a seller account.')),
        );
        return;
      }

      // Ensure phone number starts with +63
      String phoneNumber = phoneController.text.trim();
      if (!phoneNumber.startsWith('+63')) {
        phoneNumber = '+63' + phoneNumber;
      }

      final hashedPassword = sha256
          .convert(utf8.encode(passwordController.text.trim()))
          .toString();

      // Save seller data inside user's document -> sellerInfo subcollection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('sellerInfo')
          .add({
        'storeName': storeNameController.text.trim(),
        'street': streetController.text.trim(),
        'barangay': barangayController.text.trim(),
        'city': cityController.text.trim(),
        'province': provinceController.text.trim(),
        'phone': phoneNumber,
        'password': hashedPassword,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration successful!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SellerLoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SellerLoginScreen()),
            );
          },
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double horizontalPadding = constraints.maxWidth > 600 ? 80.0 : 24.0;
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding, vertical: 16.0),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sign up',
                            style: GoogleFonts.poppins(
                                fontSize: 32.0, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8.0),
                        Text('Create an account to continue!',
                            style: GoogleFonts.poppins(
                                color: Colors.grey, fontSize: 14.0)),
                        const SizedBox(height: 24.0),
                        _buildTextField('Store Name', 'Input store name',
                            icon: Icons.store_outlined,
                            controller: storeNameController),
                        _buildTextField('Street', 'Enter street',
                            icon: Icons.home_outlined,
                            controller: streetController),
                        _buildTextField('Barangay', 'Enter barangay',
                            icon: Icons.location_city,
                            controller: barangayController),
                        _buildTextField('City or Municipality',
                            'Enter city or municipality',
                            icon: Icons.location_city_outlined,
                            controller: cityController),
                        _buildTextField('Province', 'Enter province',
                            icon: Icons.map_outlined,
                            controller: provinceController),
                        _buildPhoneField(),
                        _buildPasswordField(controller: passwordController),
                        const Spacer(), // Pushes the button to bottom
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                registerSeller, // Call the register function
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF651D32),
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0)),
                            ),
                            child: Text(
                              'Register',
                              style: GoogleFonts.poppins(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(String label, String hint,
      {IconData? icon, required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8.0),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon) : null,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '$label is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Phone Number',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8.0),
        TextFormField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\+?\d*')),
            LengthLimitingTextInputFormatter(13),
            _PhoneNumberFormatter(),
          ],
          decoration: InputDecoration(
            hintText: '+639123456789',
            prefixIcon: Icon(Icons.phone),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Phone Number is required';
            }
            final phoneRegex = RegExp(r'^\+63\d{10}$');
            if (!phoneRegex.hasMatch(value.trim())) {
              return 'Invalid phone number. Use +63 followed by 10 digits (e.g. +639123456789).';
            }
            return null;
          },
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  Widget _buildPasswordField({required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Set Password',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8.0),
        TextFormField(
          controller: controller,
          obscureText: !_isPasswordVisible,
          decoration: InputDecoration(
            hintText: 'Enter password',
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Password is required';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }
}

// Formatter to ensure phone number starts with +63 and is valid
class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;

    // Ensure it starts with +63
    if (!text.startsWith('+63')) {
      text = '+63' + text.replaceAll(RegExp(r'^\+?63?'), '');
    }

    // Only allow digits after +63
    if (text.length > 3) {
      String prefix = text.substring(0, 3);
      String digits = text.substring(3).replaceAll(RegExp(r'\D'), '');
      text = prefix + digits;
    }

    // Limit to 13 characters
    if (text.length > 13) {
      text = text.substring(0, 13);
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
