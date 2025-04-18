import 'package:flutter/material.dart';
import 'sellerRegister.dart'; // Import SellerRegistrationScreen
import 'package:google_fonts/google_fonts.dart';
import 'sellerdashboard.dart'; // Import SellerDashboardScreen
void main() {
  runApp(const SellerLoginApp());
}

class SellerLoginApp extends StatelessWidget {
  const SellerLoginApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SellerLoginScreen(),
    );
  }
}

class SellerLoginScreen extends StatelessWidget {
  const SellerLoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: constraints.maxWidth > 600 ? 200.0 : 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LSPUMART',
                      style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      'Login to your Seller Account',
                      style: GoogleFonts.poppins(fontSize: 35, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter your Store Name and password to log in',
                      style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                     Text('Store Name', style: GoogleFonts.poppins(fontSize: 12),),
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'Enter your Store Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text('Password'),
                    PasswordField(),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => DashboardScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF651D32),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: Text('Log In',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                    const SizedBox(height: 30),
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                      ],
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
                                    MaterialPageRoute(builder: (context) => SellerRegistrationApp()),
                              );
                            },
                            child: Text('Sign Up',
                                style: GoogleFonts.poppins(color: Colors.blue)),
                          ),
                        ],
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

class PasswordField extends StatefulWidget {
  const PasswordField({Key? key}) : super(key: key);

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _isObscured = true;

  void _togglePasswordView() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: _isObscured,
      decoration: InputDecoration(
        hintText: 'Enter your password',
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(_isObscured ? Icons.visibility_off : Icons.visibility),
          onPressed: _togglePasswordView,
        ),
      ),
    );
  }
}
