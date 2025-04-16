import 'package:flutter/material.dart';
import 'Sellerlogin.dart';
class NavigationDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          SizedBox(
            height: 200, // Adjust height as needed
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF800000),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons
                          .store, // You can change to Icons.dashboard, Icons.store, etc.
                      size: 40,
                      color: Colors.white,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'My Store',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerItem(icon: Icons.dashboard, text: "Dashboard"),
                DrawerItem(icon: Icons.add, text: "Add Product"),
                DrawerItem(icon: Icons.inventory, text: "Manage Product"),
                DrawerItem(icon: Icons.shopping_cart, text: "Manage Orders"),
                DrawerItem(icon: Icons.bar_chart, text: "View Sales"),
                DrawerItem(icon: Icons.local_offer, text: "Discount & Coupons"),
                DrawerItem(icon: Icons.message, text: "Message Users"),
                DrawerItem(
                    icon: Icons.account_balance_wallet, text: "Withdraw"),
                DrawerItem(icon: Icons.person, text: "Profile"),
                Divider(),
                DrawerItem(icon: Icons.logout, text: "Log Out", isLogout: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DrawerItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isLogout;

  const DrawerItem({
    required this.icon,
    required this.text,
    this.isLogout = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isLogout ? Colors.redAccent : Colors.black87,
      ),
      title: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isLogout ? Colors.redAccent : Colors.black87,
        ),
      ),
      onTap: () {
        if (isLogout) {
          // Navigate to login screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    SellerLoginScreen()), // make sure LoginScreen exists in login.dart
          );
        } else {
          // Other navigation logic if needed
        }
      },
      hoverColor: Colors.grey[200],
    );
  }
}