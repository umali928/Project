import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'AddProduct.dart';
import 'package:lspu/navigation_drawer.dart' as custom;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Product List',
      theme: ThemeData(primarySwatch: Colors.green),
      home: AddProductList(),
    );
  }
}

class AddProductList extends StatelessWidget {
  final List<Map<String, dynamic>> products = [
    {
      "name": "Pancit Canton",
      "category": "Food",
      "price": "₱25.00",
      "stock": "120",
    },
    {
      "name": "Bear Brand",
      "category": "Beverages",
      "price": "₱50.00",
      "stock": "80",
    },
    {
      "name": "USB Cable",
      "category": "Electronics",
      "price": "₱100.00",
      "stock": "200",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: custom.NavigationDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Text(
              "Product List",
              style: GoogleFonts.poppins(
                fontSize: isLargeScreen ? 22 : 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Spacer(),
            Text(
              "LSPUMART",
              style: GoogleFonts.poppins(
                fontSize: isLargeScreen ? 18 : 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: EdgeInsets.all(isLargeScreen ? 24 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Home / Add Product",
                  style: GoogleFonts.poppins(
                    fontSize: isLargeScreen ? 16 : 14,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: isLargeScreen ? 20 : 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: isLargeScreen ? 20 : 16),
                        padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
                        decoration: BoxDecoration(
                          color: Color(0xFFF8F8F8),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: isLargeScreen ? 26 : 22,
                              backgroundColor: Color(0xFF651D32),
                              child: Icon(Icons.inventory,
                                  color: Colors.white,
                                  size: isLargeScreen ? 26 : 20),
                            ),
                            SizedBox(width: isLargeScreen ? 20 : 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(product['name'],
                                      style: GoogleFonts.poppins(
                                        fontSize: isLargeScreen ? 18 : 16,
                                        fontWeight: FontWeight.w600,
                                      )),
                                  SizedBox(height: 6),
                                  Text("Category: ${product['category']}",
                                      style: GoogleFonts.poppins(
                                          fontSize: isLargeScreen ? 14 : 13)),
                                  Text("Stock: ${product['stock']}",
                                      style: GoogleFonts.poppins(
                                          fontSize: isLargeScreen ? 14 : 13)),
                                ],
                              ),
                            ),
                            Text(product['price'],
                                style: GoogleFonts.poppins(
                                  fontSize: isLargeScreen ? 16 : 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                )),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddProductScreen()),
          );
        },
        label: Text(
          "Add Product",
          style: GoogleFonts.poppins(
              fontSize: isLargeScreen ? 18 : 16,
              fontWeight: FontWeight.w600,
              color: Colors.white),
        ),
        icon: Icon(Icons.add, color: Colors.white, size: isLargeScreen ? 24 : 20),
        backgroundColor: Color(0xFF651D32),
      ),
    );
  }
}
