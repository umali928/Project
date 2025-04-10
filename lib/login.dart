import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'register.dart';
import 'dashboard.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyBbSQOdsCh7ImLhewcIhHUTcj9-1xbShQk",
        authDomain: "lspumart.firebaseapp.com",
        databaseURL: "https://lspumart-default-rtdb.asia-southeast1.firebasedatabase.app",
        projectId: "lspumart",
        storageBucket: "lspumart.firebasestorage.app",
        messagingSenderId: "533992551897",
        appId: "1:533992551897:web:d04a482ad131a0700815c8"
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  await Supabase.initialize(
    url: 'https://haoiqctsijynxwfoaspm.supabase.co',
     anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhhb2lxY3RzaWp5bnh3Zm9hc3BtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQxNzU3MDMsImV4cCI6MjA1OTc1MTcwM30.7kilmu9kxrABgg4ZMz9GIHm5Jv4LHLAIYR1_8q1eDEI', // Replace with your Supabase anon key
  );

  // 🔑 Check for existing session
  firebase_auth.User? user = firebase_auth.FirebaseAuth.instance.currentUser;
  runApp(user != null ? Dashboard() : const MyApp());
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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void loginUser() async {
    try {
      final credential = await firebase_auth.FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      print("Logged in user UID: ${credential.user?.uid}");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Dashboard()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: Incorrect Email Or Password")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          double textFieldWidth = constraints.maxWidth > 600 ? 400 : double.infinity;
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
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
                      style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 44),
                    SizedBox(
                      width: textFieldWidth,
                      child: TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          filled: true,
                          fillColor: Colors.grey[200],
                          contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(width: textFieldWidth, child: PasswordField(controller: passwordController)),
                    const SizedBox(height: 38),
                    SizedBox(
                      width: textFieldWidth,
                      child: ElevatedButton(
                        onPressed: loginUser,
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
                          style: GoogleFonts.poppins(fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignUpScreen()),
                        );
                      },
                        child: RichText(
                        text: TextSpan(
                          text: 'No account? ',
                          style: GoogleFonts.poppins(
                          color: Colors.black87,
                          fontSize: 16,
                          ),
                          children: [
                          TextSpan(
                            text: 'Register Here',
                            style: GoogleFonts.poppins(
                            color: const Color(0xFF651D32),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            decoration: TextDecoration.underline,
                            ),
                          ),
                          ],
                        ),
                        ),
                      ),
                    //HIDE FOR NOW
                    // const SizedBox(height: 16),
                    // Text(
                    //   'Or continue with',
                    //   style: GoogleFonts.poppins(
                    //     color: Color(0xFF651D32),
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                    // const SizedBox(height: 12),
                    // OutlinedButton.icon(
                    //   onPressed: () {},
                    //   icon: Image.asset('assets/googleicon.png', height: 24),
                    //   label: Text(
                    //     'Continue with Google',
                    //     style: GoogleFonts.poppins(
                    //       color: Color(0xFF651D32),
                    //       fontSize: 18,
                    //       fontWeight: FontWeight.bold,
                    //     ),
                    //   ),
                    //   style: OutlinedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
                    // ),
                    // const SizedBox(height: 50),
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
  final TextEditingController controller;

  const PasswordField({required this.controller});

  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  void _togglePasswordVisibility() {
    setState(() => _obscureText = !_obscureText);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
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
          icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
          onPressed: _togglePasswordVisibility,
        ),
      ),
    );
  }
}
