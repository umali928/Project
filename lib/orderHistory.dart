import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF800000),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          foregroundColor: Color.fromARGB(255, 0, 0, 0),
        ),
      ),
      home: const OrderHistoryScreen(),
    );
  }
}

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  final List<Map<String, dynamic>> orders = const [
    {
      "id": "#12345",
      "date": "March 20, 2025",
      "status": "Delivered",
      "total": "150.00",
    },
    {
      "id": "#12346",
      "date": "March 18, 2025",
      "status": "Shipped",
      "total": "80.00",
    },
    {
      "id": "#12347",
      "date": "March 15, 2025",
      "status": "Pending",
      "total": "45.50",
    }
  ];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double iconSize = screenWidth * 0.08;

    return Scaffold(
      appBar: AppBar(
        title: Text("Order History", style: GoogleFonts.poppins(fontSize: screenWidth * 0.07, fontWeight: FontWeight.bold)),  
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              margin: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: screenWidth * 0.2,
                    height: screenWidth * 0.2,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[300],
                    ),
                    child: Center(
                      child: Icon(Icons.image, color: Colors.grey, size: iconSize),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.04),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order["id"],
                          style: GoogleFonts.poppins(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF800000),
                          ),
                        ),
                        SizedBox(height: screenWidth * 0.02),
                         Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(order["date"], style: GoogleFonts.poppins(color: Colors.grey[700], fontSize: screenWidth * 0.04)),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02, vertical: screenWidth * 0.01),
                              decoration: BoxDecoration(
                                color: _getStatusColor(order["status"]),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                order["status"],
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenWidth * 0.02),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total: ₱${order["total"]}",
                              style: GoogleFonts.poppins(
                                fontSize: screenWidth * 0.045,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF800000),
                              ),
                            ),
                            if (order["status"] == "Delivered")
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red, size: iconSize),
                                onPressed: () {
                                  // Implement delete functionality here
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "Delivered":
        return Colors.green;
      case "Shipped":
        return Colors.blue;
      case "Pending":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
