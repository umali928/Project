import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'register.dart'; // Import RegisterScreen
import 'dashboard.dart'; // Import DashboardScreen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          double textFieldWidth =
              constraints.maxWidth > 600 ? 400 : double.infinity;
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),
                    Text(
                      'Login',
                      style: GoogleFonts.poppins(
                        fontSize: 45,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF651D32),
                      ),
                    ),
                    const SizedBox(height: 26),
                    Text(
                      'Welcome to LSPU-Mart',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 44),
                    SizedBox(
                      width: textFieldWidth,
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Email',
                          filled: true,
                          fillColor: Colors.grey[200],
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 20, horizontal: 15),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: textFieldWidth,
                      child: PasswordField(),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: textFieldWidth,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Dashboard()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF651D32),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 60),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Login',
                          style: GoogleFonts.poppins(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignUpScreen()),
                        );
                      },
                      child: Text(
                        'Create new account',
                        style: GoogleFonts.poppins(
                          color: const Color.fromARGB(255, 0, 0, 0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Or continue with',
                      style: GoogleFonts.poppins(
                        color: Color(0xFF651D32),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: Image.asset('assets/googleicon.png', height: 24),
                      label: Text('Continue with Google',
                          style: GoogleFonts.poppins(
                            color: Color(0xFF651D32),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          )),
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
                    const SizedBox(height: 50),
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
  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: _obscureText,
      decoration: InputDecoration(
        labelText: 'Password',
        filled: true,
        fillColor: Colors.grey[200],
        contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: _togglePasswordVisibility,
        ),
      ),
    );
  }
}
