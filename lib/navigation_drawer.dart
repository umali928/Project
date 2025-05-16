import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Sellerlogin.dart';
import 'sellerdashboard.dart';
import 'ManageProduct.dart';
import 'OrderManagement.dart';
import 'SellerProfile.dart';
import 'SellerViewSales.dart';
class NavigationDrawer extends StatefulWidget {
  @override
  State<NavigationDrawer> createState() => _NavigationDrawerState();
}

class _NavigationDrawerState extends State<NavigationDrawer> {
  String storeName = "My Store";

  @override
  void initState() {
    super.initState();
    loadStoreName();
  }

  Future<void> loadStoreName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? name = prefs.getString('sellerStoreName');
    setState(() {
      storeName = name ?? "My Store";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF800000),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.store, size: 40, color: Colors.white),
                    SizedBox(height: 10),
                    Text(
                      storeName,
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
                DrawerItem(
                    icon: Icons.dashboard,
                    text: "Dashboard",
                    destination: DashboardScreen()),
                DrawerItem(
                    icon: Icons.inventory,
                    text: "Manage Product",
                    destination: Manageproduct()),
                DrawerItem(
                    icon: Icons.shopping_cart,
                    text: "Manage Orders",
                    destination: OrderManagementPage()),
                DrawerItem(
                    icon: Icons.bar_chart,
                    text: "View Sales",
                    destination: SellerViewSales()),
                DrawerItem(
                  icon: Icons.person,
                  text: "Profile",
                  destination: SellerProfile(),
                ),
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
  final Widget? destination;
  final VoidCallback? onTap;

  const DrawerItem({
    required this.icon,
    required this.text,
    this.isLogout = false,
    this.destination,
    this.onTap,
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
      onTap: () async {
        Navigator.pop(context); // Close the drawer

        if (isLogout) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.clear();

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SellerLoginScreen()),
          );
        } else if (onTap != null) {
          onTap!();
        } else if (destination != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination!),
          );
        }
      },
      hoverColor: Colors.grey[200],
    );
  }
}
