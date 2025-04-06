import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'wishlist.dart'; // Import WishlistScreen
import 'profile.dart';
import 'cart.dart'; // Import CartScreen
import 'orderHistory.dart';

void main() {
  runApp(EcommerceApp());
}

class EcommerceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Dashboard(),
    );
  }
}

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;

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
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF651D32),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border), label: "Wishlist"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account"),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("LSPU-MART",
                style: GoogleFonts.poppins(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                )),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.bell, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(LucideIcons.shoppingCart, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartScreen()),
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;
          bool isLargeScreen = screenWidth > 600;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    hintText: "Search here ...",
                    prefixIcon: Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 20),

                /// Ad Banner
                SizedBox(
                  height: isLargeScreen ? 300 : 120,
                  child: PageView(
                    controller: PageController(viewportFraction: 0.9),
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        child: AdBanner(
                            imagePath: "assets/ad1.jpg", width: screenWidth),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        child: AdBanner(
                            imagePath: "assets/ad2.png", width: screenWidth),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),
                Text("Category",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),

                if (isLargeScreen)
                  GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 5,
                    childAspectRatio: 1,
                    children: [
                      CategoryItem(icon: Icons.checkroom, label: "Clothes"),
                      CategoryItem(icon: Icons.school, label: "School"),
                      CategoryItem(icon: Icons.sports, label: "Sports"),
                      CategoryItem(icon: Icons.fastfood, label: "Foods"),
                      CategoryItem(icon: Icons.grid_view, label: "All"),
                    ],
                  )
                else
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        CategoryItem(icon: Icons.checkroom, label: "Clothes"),
                        CategoryItem(icon: Icons.school, label: "School"),
                        CategoryItem(icon: Icons.sports, label: "Sports"),
                        CategoryItem(icon: Icons.fastfood, label: "Foods"),
                        CategoryItem(icon: Icons.grid_view, label: "All"),
                      ]
                          .map((item) => Padding(
                                padding: EdgeInsets.only(right: 32),
                                child: item,
                              ))
                          .toList(),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;

  CategoryItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: Colors.grey[200],
          child: Icon(icon, color: Colors.black),
        ),
        SizedBox(height: 5),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }
}

class AdBanner extends StatelessWidget {
  final String imagePath;
  final double width;

  AdBanner({required this.imagePath, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width * 0.8,
      height: width > 600 ? 200 : 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
