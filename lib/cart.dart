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
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white, // White background
      ),
      home: CartScreen(),
    );
  }
}

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: screenWidth * 0.07), // Scaled icon
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Your Cart",
          style: GoogleFonts.poppins(
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.bold), // Scaled text
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                CartItem(),
                CartItem(),
                CartItem(),
              ],
            ),
          ),
          OrderSummary(),
        ],
      ),
    );
  }
}

class CartItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth * 0.04; // Scaled font size
    double iconSize = screenWidth * 0.06; // Scaled icon size

    return Card(
      color: Colors.white,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: screenWidth * 0.03),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.03),
        child: Row(
          children: [
            Container(
              width: screenWidth * 0.15,
              height: screenWidth * 0.15,
              color: Colors.grey[300],
            ),
            SizedBox(width: screenWidth * 0.03),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Product Name",
                      style: GoogleFonts.poppins(
                          fontSize: fontSize, fontWeight: FontWeight.bold)),
                  Text("Variant: Grey",
                      style: TextStyle(
                          fontSize: fontSize * 0.8, color: Colors.grey)),
                  Text("₱1999.99",
                      style: GoogleFonts.poppins(
                          fontSize: fontSize, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                    icon: Icon(Icons.remove, size: iconSize), onPressed: () {}),
                Text("1", style: GoogleFonts.poppins(fontSize: fontSize)),
                IconButton(
                    icon: Icon(Icons.add, size: iconSize), onPressed: () {}),
              ],
            ),
            IconButton(
                icon: Icon(Icons.delete, color: Colors.red, size: iconSize),
                onPressed: () {}),
          ],
        ),
      ),
    );
  }
}

class OrderSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth * 0.04;
    double iconSize = screenWidth * 0.06; // Scaled icon size

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 5,
            spreadRadius: 1,
            offset: Offset(0, -2),
          ),
        ],
      ),
      margin: EdgeInsets.all(screenWidth * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Order Summary",
              style: GoogleFonts.poppins(
                  fontSize: fontSize, fontWeight: FontWeight.bold)),
          Divider(),
          _buildRow("Items", "3", fontSize),
          _buildRow("Subtotal", "₱54", fontSize),
          _buildRow("Discount", "₱4", fontSize),
          _buildRow("Delivery Charges", "₱2", fontSize),
          Divider(),
          _buildRow("Total", "₱60", fontSize, bold: true),
          SizedBox(height: screenWidth * 0.04),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF651D32),
                padding: EdgeInsets.symmetric(vertical: screenWidth * 0.04),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onPressed: () {},
              icon: Icon(Icons.payment, size: iconSize, color: Colors.white),
              label: Text(
                "Proceed",
                style: GoogleFonts.poppins(
                    fontSize: fontSize, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String left, String right, double fontSize,
      {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(left,
            style: GoogleFonts.poppins(
                fontSize: fontSize,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        Text(right,
            style: GoogleFonts.poppins(
                fontSize: fontSize,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
}
