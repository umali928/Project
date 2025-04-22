import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'SellerLogin.dart'; // Import SellerLoginScreen

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
  State<SellerRegistrationScreen> createState() =>
      _SellerRegistrationScreenState();
}

class _SellerRegistrationScreenState extends State<SellerRegistrationScreen> {
  bool _isPasswordVisible = false;

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
                          icon: Icons.store_outlined),
                      _buildTextField('Street', 'Enter street',
                          icon: Icons.home_outlined),
                      _buildTextField('Barangay', 'Enter barangay',
                          icon: Icons.location_city),
                      _buildTextField(
                          'City or Municipality', 'Enter city or municipality',
                          icon: Icons.location_city_outlined),
                      _buildTextField('Province', 'Enter province',
                          icon: Icons.map_outlined),
                      _buildPhoneField(),
                      _buildPasswordField(),
                      const Spacer(), // Pushes the button to bottom
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
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
          );
        },
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
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
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
        Text('Set Password',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8.0),
        TextField(
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
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }
}
