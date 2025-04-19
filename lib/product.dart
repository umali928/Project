import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'cart.dart';
void main() => runApp(ProductDetailApp());

class ProductDetailApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ProductDetailPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ProductDetailPage extends StatefulWidget {
  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final List<String> colors = ["White", "Red", "Blue", "Black", "Green"];
  final List<String> sizes = ["S", "M", "L", "XL"];
  String selectedColor = "White";
  String selectedSize = "M";
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // ignore: unused_local_variable
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.favorite_border, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart_outlined, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartScreen()),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: 12),
        child: Row(
          children: [
            // Quantity Selector
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.remove),
                    onPressed:
                        quantity > 1 ? () => setState(() => quantity--) : null,
                  ),
                  Text('$quantity',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () => setState(() => quantity++),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),
            // Add to Cart Button
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Color(0xFF651D32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {},
                child: Text("Add to Cart",
                    style: GoogleFonts.poppins(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Frame
                Container(
                  height: MediaQuery.of(context).size.height *
                      0.3, // 40% of screen height
                  width: double.infinity,
                  color: Colors.grey.shade300,
                  alignment: Alignment.center,
                  child: Text(
                    'Product Frame',
                    style: GoogleFonts.poppins(
                        fontSize: 20, color: Colors.grey.shade600),
                  ),
                ),
                SizedBox(height: 16),
                Text("PRODUCT NAME",
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold, fontSize: 20)),
                SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.star, size: 14, color: Colors.white),
                          SizedBox(width: 4),
                          Text("4.8",
                              style: GoogleFonts.poppins(color: Colors.white)),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                    Text("574 Reviews",
                        style: GoogleFonts.poppins(color: Colors.grey)),
                  ],
                ),
                SizedBox(height: 12),
                Text("\₱68",
                    style: GoogleFonts.roboto(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text("Description",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                SizedBox(height: 6),
                Text(
                  "Experience comfort and style with our premium slim-fit cotton shirt. "
                  "Designed for all-day wear with breathable fabric and a tailored silhouette.",
                  style: GoogleFonts.poppins(height: 1.4),
                ),
                SizedBox(height: 20),
                Text("Color: $selectedColor",
                    style: GoogleFonts.poppins(fontSize: 16)),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: colors.map((color) {
                    bool isSelected = color == selectedColor;
                    return OutlinedButton(
                      onPressed: () => setState(() => selectedColor = color),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: isSelected
                                ? Color(0xFF651D32)
                                : Colors.grey.shade400),
                        backgroundColor:
                            isSelected ? Color(0xFF651D32) : Colors.transparent,
                        foregroundColor:
                            isSelected ? Colors.white : Color(0xFF651D32),
                      ),
                      child: Text(color),
                    );
                  }).toList(),
                ),
                SizedBox(height: 20),
                Text("Size",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: sizes.map((size) {
                    bool isSelected = size == selectedSize;
                    return OutlinedButton(
                      onPressed: () => setState(() => selectedSize = size),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: isSelected
                                ? Color(0xFF651D32)
                                : Colors.grey.shade400),
                        backgroundColor:
                            isSelected ? Color(0xFF651D32) : Colors.transparent,
                        foregroundColor:
                            isSelected ? Colors.white : Color(0xFF651D32),
                      ),
                      child: Text(size),
                    );
                  }).toList(),
                ),
                SizedBox(height: 32),
                Text("Ratings & Reviews",
                    style: GoogleFonts.poppins(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text("4.8",
                              style: GoogleFonts.poppins(
                                  fontSize: 28, fontWeight: FontWeight.bold)),
                          Text("/5",
                              style: GoogleFonts.poppins(
                                  fontSize: 20, color: Colors.black54)),
                          SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Overall Rating"),
                              Text("574 Ratings",
                                  style:
                                      GoogleFonts.poppins(color: Colors.grey)),
                            ],
                          ),
                          Spacer(),
                          OutlinedButton(
                            onPressed: () {},
                            child: Text("Rate"),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Color(0xFF651D32),
                              side: BorderSide(color: Color(0xFF651D32)),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: List.generate(
                          5,
                          (index) =>
                              Icon(Icons.star, color: Colors.orange, size: 20),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text("Amazing!",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text(
                        "An amazing fit. I am somewhere around 6ft and ordered 40 size. "
                        "It's a perfect fit and quality is worth the price...",
                      ),
                      SizedBox(height: 8),
                      Text("David Johnson, 1st Jan 2020",
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}
