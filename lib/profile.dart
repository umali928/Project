import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login.dart'; // Import LoginPage
import 'SellerLogin.dart'; // Import SellerLoginScreen
import 'privacypolicy.dart'; // Import PrivacyPolicyScreen
import 'orderHistory.dart';
import 'wishlist.dart';
import 'dashboard.dart'; // Import DashboardScreen

void main() {
  runApp(settings());
}

class settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProfilePage(),
    );
  }
}

// This widget holds the BottomNavigationBar
class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 3;

  final List<Widget> _pages = [
    HomeScreen(),
    WishlistScreen(),
    OrderHistoryScreen(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF651D32),
        backgroundColor: Colors.white,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border), label: "Wishlist"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
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
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          "My Account",
          style: GoogleFonts.poppins(
              color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05),
              children: [
                SizedBox(height: screenHeight * 0.03),
                CircleAvatar(
                  radius: screenWidth * 0.15, // Responsive avatar size
                  backgroundColor: Colors.grey[300], // Placeholder color
                  backgroundImage:
                      NetworkImage("https://example.com/profile.jpg"),
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
                buildListTile(Icons.store, "Login Seller", onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SellerLoginScreen()),
                  );
                }),
                buildListTile(Icons.location_on, "Delivery Address"),
                buildListTile(Icons.message, "Messages"),
                Divider(),
                buildListTile(Icons.lock, "Change Password"),
                buildListTile(Icons.privacy_tip, "Privacy Policy", onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => policy()),
                  );
                }),
                buildListTile(Icons.person, "Personal Information"),
                Divider(),
                buildListTile(Icons.logout, "Log Out", color: Colors.red,
                    onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                }),
              ],
            ),
          ),
          // Footer Section
        ],
      ),
    );
  }

  Widget buildListTile(IconData icon, String title,
      {Color color = Colors.black, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      onTap: onTap, 
      tileColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
    );
  }
}
