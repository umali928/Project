import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Sellerlogin.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: NavigationDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            SizedBox(width: 8),
            Text(
              "Seller-Dashboard",
              style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            Spacer(), // Push "LSPUMART" to the right
            Text(
              "LSPUMART",
              style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ],
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Home / Dashboard",
                  style: GoogleFonts.poppins(color: Colors.black54)),
              SizedBox(height: 10),
              DashboardCard(
                  title: "Total Orders",
                  value: "400",
                  percentChange: "+10%",
                  icon: Icons.shopping_bag,
                  color: Colors.green),
              DashboardCard(
                  title: "Total Sell",
                  value: "₱4200.5",
                  percentChange: "-5%",
                  icon: Icons.account_balance_wallet,
                  color: Colors.redAccent),
              DashboardCard(
                  title: "Total Products",
                  value: "452",
                  percentChange: "+23",
                  icon: Icons.category,
                  color: Colors.purple),
              SizedBox(height: 20),
              OrderSummary(),
              ReviewOrders(),
            ],
          ),
        ),
      ),
    );
  }
}

class NavigationDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF800000),
            ),
            child: Center(
              child: Text(
                'Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
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

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final String percentChange;
  final IconData icon;
  final Color color;

  DashboardCard(
      {required this.title,
      required this.value,
      required this.percentChange,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 40, color: color),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.poppins(
                          fontSize: 14, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Text(value,
                      style: GoogleFonts.roboto(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.trending_up, size: 14, color: Colors.green),
                      SizedBox(width: 4),
                      Text(percentChange,
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: Colors.green)),
                      SizedBox(width: 4),
                      Text("vs last month",
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: Colors.black45)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Order Summary",
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            OrderProgress(
                title: "Pending Orders",
                percent: 0.4,
                color: Colors.orange,
                orders: "160/400 Orders"),
            OrderProgress(
                title: "Shipped Orders",
                percent: 0.3,
                color: Colors.purple,
                orders: "120/400 Orders"),
            OrderProgress(
                title: "Delivered Orders",
                percent: 0.3,
                color: Colors.green,
                orders: "120/400 Orders"),
          ],
        ),
      ),
    );
  }
}

class OrderProgress extends StatelessWidget {
  final String title;
  final double percent;
  final Color color;
  final String orders;

  OrderProgress(
      {required this.title,
      required this.percent,
      required this.color,
      required this.orders});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(title,
              style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.w500)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinearProgressIndicator(
                  value: percent,
                  color: color,
                  backgroundColor: Colors.grey[300]),
              SizedBox(height: 4),
              Text(orders,
                  style:
                      GoogleFonts.poppins(fontSize: 12, color: Colors.black54)),
            ],
          ),
        ),
      ],
    );
  }
}

class ReviewOrders extends StatelessWidget {
  final List<Order> orders = [
    Order(
        date: "01/04/2024",
        id: "P12345",
        name: "Pancit canton",
        location: "Pila, Laguna",
        status: "In Transit",
        statusColor: Colors.blue),
    Order(
        date: "02/04/2024",
        id: "ZM2345",
        name: "GIN",
        location: "Sta. Rosa, Laguna",
        status: "Pending",
        statusColor: Colors.orange),
    Order(
        date: "24/05/2024",
        id: "PX6789",
        name: "Bear Brand",
        location: "Cavite, Philippines",
        status: "Delivered",
        statusColor: Colors.green),
    Order(
        date: "24/05/2024",
        id: "CC5432",
        name: "Paracetemol",
        location: "Cavite, Philippines",
        status: "Delivered",
        statusColor: Colors.green),
    Order(
        date: "23/05/2024",
        id: "AH8765",
        name: "USB Cable",
        location: "Cebu, Philippines",
        status: "Pending",
        statusColor: Colors.orange),
  ];

  @override
  Widget build(BuildContext context) {
    double textScale = MediaQuery.of(context).textScaleFactor;
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Review Orders",
              style: GoogleFonts.poppins(
                  fontSize: 18 * textScale, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  children: orders
                      .map((order) => OrderItem(
                          order: order, maxWidth: constraints.maxWidth))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class Order {
  final String date;
  final String id;
  final String name;
  final String location;
  final String status;
  final Color statusColor;

  Order(
      {required this.date,
      required this.id,
      required this.name,
      required this.location,
      required this.status,
      required this.statusColor});
}

class OrderItem extends StatelessWidget {
  final Order order;
  final double maxWidth;

  OrderItem({required this.order, required this.maxWidth});

  @override
  Widget build(BuildContext context) {
    double textScale = MediaQuery.of(context).textScaleFactor;
    bool isMobile = maxWidth < 600; // Mobile breakpoint

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.date,
                    style: GoogleFonts.poppins(
                        fontSize: 14 * textScale,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54)),
                Text(order.id,
                    style: GoogleFonts.poppins(
                        fontSize: 12 * textScale, color: Colors.black45)),
                Text(order.name,
                    style: GoogleFonts.poppins(
                        fontSize: 14 * textScale, fontWeight: FontWeight.w500)),
                Text(order.location,
                    style: GoogleFonts.poppins(
                        fontSize: 12 * textScale, color: Colors.black54)),
                SizedBox(height: 5),
                Align(
                  alignment: Alignment.centerLeft,
                  child: StatusBadge(
                      status: order.status, color: order.statusColor),
                ),
                Divider(),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                    flex: 2,
                    child: Text(order.date,
                        style: GoogleFonts.poppins(
                            fontSize: 14 * textScale,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54))),
                Expanded(
                    flex: 3,
                    child: Text(order.name,
                        style: GoogleFonts.poppins(
                            fontSize: 14 * textScale,
                            fontWeight: FontWeight.w500))),
                Expanded(
                    flex: 2,
                    child: Text(order.location,
                        style: GoogleFonts.poppins(
                            fontSize: 12 * textScale, color: Colors.black54))),
                Expanded(
                    flex: 1,
                    child: StatusBadge(
                        status: order.status, color: order.statusColor)),
              ],
            ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String status;
  final Color color;

  StatusBadge({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(status,
          style: GoogleFonts.poppins(
              fontSize: 12, fontWeight: FontWeight.bold, color: color)),
    );
  }
}
