import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lspu/navigation_drawer.dart' as custom;
import 'SellerOrderdetails.dart';

void main() {
  runApp(OrderManagementApp());
}

class OrderManagementApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OrderManagementPage(),
    );
  }
}

class OrderManagementPage extends StatelessWidget {
  final List<OrderInfo> orders = [
    OrderInfo(orderId: "ORD001", customerName: "John Doe", status: "Pending", color: Colors.orange),
    OrderInfo(orderId: "ORD002", customerName: "Jane Smith", status: "Delivered", color: Colors.green),
    OrderInfo(orderId: "ORD003", customerName: "Albert Reyes", status: "In Transit", color: Colors.blue),
    OrderInfo(orderId: "ORD005", customerName: "Joey Marquez", status: "Pending", color: Colors.orange),
  ];

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final textScale = MediaQuery.of(context).textScaleFactor;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Order Management",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.045, // responsive title
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      drawer: custom.NavigationDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Orders",
                            style: GoogleFonts.poppins(
                                fontSize: screenWidth * 0.045,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        ...orders.map((order) => InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => OrderDetailsPage(),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(order.orderId,
                                          style: GoogleFonts.poppins(
                                              fontSize: screenWidth * 0.035)),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Text(order.customerName,
                                          style: GoogleFonts.poppins(
                                              fontSize: screenWidth * 0.035,
                                              fontWeight: FontWeight.w500)),
                                    ),
                                    StatusBadge(status: order.status, color: order.color),
                                  ],
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class OrderInfo {
  final String orderId;
  final String customerName;
  final String status;
  final Color color;

  OrderInfo({
    required this.orderId,
    required this.customerName,
    required this.status,
    required this.color,
  });
}

class StatusBadge extends StatelessWidget {
  final String status;
  final Color color;

  const StatusBadge({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: GoogleFonts.poppins(
          fontSize: screenWidth * 0.03,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
