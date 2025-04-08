import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'SellerLogin.dart'; // Import SellerLoginScreen
import 'dart:io';

void main() {
  runApp(const SellerRegistrationApp());
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
  State<SellerRegistrationScreen> createState() => _SellerRegistrationScreenState();
}

class _SellerRegistrationScreenState extends State<SellerRegistrationScreen> {
  bool _isPasswordVisible = false;
  File? _selectedImage;

  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
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
      body: SingleChildScrollView(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double horizontalPadding = constraints.maxWidth > 600 ? 80.0 : 24.0;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sign up', style: GoogleFonts.poppins(fontSize: 32.0, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8.0),
                  Text('Create an account to continue!', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14.0)),
                  const SizedBox(height: 24.0),
                  _buildTextField('Full Name', 'Input full name', icon: Icons.person_outline),
                  _buildTextField('Store Name', 'Input store name', icon: Icons.store_outlined),
                  _buildTextField('Email', 'Input email', icon: Icons.email_outlined),
                  _buildTextField('Address', 'Input address', icon: Icons.location_on_outlined),
                  _buildPhoneField(),
                  _buildPasswordField(),
                  _buildImageField(),

                  const SizedBox(height: 24.0),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF651D32),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                      ),
                      child: Text('Register', style: GoogleFonts.poppins(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      )),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, {IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8.0),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon) : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
          ),
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  Widget _buildPhoneField() {
    return _buildTextField('Phone Number', '(09) 726-0592', icon: Icons.phone);
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Set Password', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8.0),
        TextField(
          obscureText: !_isPasswordVisible,
          decoration: InputDecoration(
            hintText: 'Enter password',
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
          ),
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  Widget _buildImageField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('BIR Photo', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8.0),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: Colors.grey),
            ),
            child: _selectedImage != null
                ? Image.file(_selectedImage!, fit: BoxFit.cover)
                : const Center(child: Text('Tap to upload BIR Photo')),
          ),
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }
}