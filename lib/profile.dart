import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SettingsPage(),
    );
  }
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "My Account",
          style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05), // Responsive padding
              children: [
                SizedBox(height: screenHeight * 0.03),
                CircleAvatar(
                  radius: screenWidth * 0.15, // Responsive avatar size
                  backgroundColor: Colors.grey[300], // Placeholder color
                  backgroundImage: NetworkImage("https://example.com/profile.jpg"),
                ),
                SizedBox(height: screenHeight * 0.015),
                Text(
                  "Juan Dela Cruz",
                  style: GoogleFonts.poppins(
                    fontSize: screenWidth * 0.05, // Dynamic text scaling
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "JuanDelaCruz@gmail.com",
                  style: GoogleFonts.poppins(
                    fontSize: screenWidth * 0.04,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenHeight * 0.02),
                buildListTile(Icons.store, "Login Seller"),
                buildListTile(Icons.location_on, "Delivery Address"),
                buildListTile(Icons.message, "Messages"),
                Divider(),
                buildListTile(Icons.lock, "Change Password"),
                buildListTile(Icons.privacy_tip, "Privacy Policy"),
                buildListTile(Icons.person, "Personal Information"),
                Divider(),
                buildListTile(Icons.logout, "Log Out", color: Colors.red),
              ],
            ),
          ),
          // Footer Section
        ],
      ),
    );
  }

  Widget buildListTile(IconData icon, String title, {Color color = Colors.black}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      onTap: () {},
      tileColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
    );
  }
}

