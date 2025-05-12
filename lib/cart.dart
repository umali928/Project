import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Checkout.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyBbSQOdsCh7ImLhewcIhHUTcj9-1xbShQk",
          authDomain: "lspumart.firebaseapp.com",
          databaseURL:
              "https://lspumart-default-rtdb.asia-southeast1.firebasedatabase.app",
          projectId: "lspumart",
          storageBucket: "lspumart.firebasestorage.app",
          messagingSenderId: "533992551897",
          appId: "1:533992551897:web:d04a482ad131a0700815c8"),
    );
  } else {
    await Firebase.initializeApp(); // Mobile config
  }
  await Supabase.initialize(
    url:
        'https://haoiqctsijynxwfoaspm.supabase.co', // Replace with your Supabase URL
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhhb2lxY3RzaWp5bnh3Zm9hc3BtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQxNzU3MDMsImV4cCI6MjA1OTc1MTcwM30.7kilmu9kxrABgg4ZMz9GIHm5Jv4LHLAIYR1_8q1eDEI', // Replace with your Supabase anon key
  );
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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        body: Center(
            child: Text("You are not logged in",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold))),
      );
    }
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: screenWidth * 0.07),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Your Cart",
          style: GoogleFonts.poppins(
              fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('cart')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
                child: Text(
              "Your cart is empty",
              style: GoogleFonts.poppins(
                  fontSize: screenWidth * 0.05, fontWeight: FontWeight.w500),
            ));
          }

          final cartDocs = snapshot.data!.docs;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartDocs.length,
                  itemBuilder: (context, index) {
                    final item = cartDocs[index];
                    final productId = item['productId'];

                    return StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('products')
                          .doc(productId)
                          .snapshots(),
                      builder: (context, productSnapshot) {
                        if (productSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                              child:
                                  CircularProgressIndicator()); // Or SizedBox.shrink()
                        }

                        if (!productSnapshot.hasData ||
                            !productSnapshot.data!.exists) {
                          // Product was deleted — remove from cart
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .collection('cart')
                              .doc(item.id)
                              .delete();
                          return SizedBox.shrink();
                        }

                        final productData = productSnapshot.data!.data()
                            as Map<String, dynamic>;

                        return CartItem(
                          productName: productData['productName'],
                          imageUrl: productData['imageUrl'],
                          price: (productData['price'] as num).toDouble(),
                          quantity: item['quantity'],
                          cartItemId: item.id,
                          userId: user.uid,
                        );
                      },
                    );
                  },
                ),
              ),
              OrderSummary(cartDocs: cartDocs),
            ],
          );
        },
      ),
    );
  }
}

class CartItem extends StatelessWidget {
  final String productName;
  final String imageUrl;
  final double price;
  final int quantity;
  final String cartItemId;
  final String userId;

  const CartItem({
    required this.productName,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    required this.cartItemId,
    required this.userId,
  });

  void _updateQuantity(int newQuantity) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(cartItemId)
        .update({'quantity': newQuantity});
  }

  void _deleteItem() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(cartItemId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                width: screenWidth * 0.2,
                height: screenWidth * 0.2,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(productName,
                      style: GoogleFonts.poppins(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  SizedBox(height: 6),
                  Text("₱${price.toStringAsFixed(2)}",
                      style: GoogleFonts.roboto(
                          fontSize: 15, fontWeight: FontWeight.w500)),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove_circle_outline),
                        onPressed: quantity > 1
                            ? () => _updateQuantity(quantity - 1)
                            : null,
                      ),
                      Text('$quantity',
                          style: GoogleFonts.poppins(
                              fontSize: 16, fontWeight: FontWeight.w500)),
                      IconButton(
                        icon: Icon(Icons.add_circle_outline),
                        onPressed: () => _updateQuantity(quantity + 1),
                      ),
                    ],
                  )
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              iconSize: screenWidth * 0.07,
              onPressed: _deleteItem,
            ),
          ],
        ),
      ),
    );
  }
}

class OrderSummary extends StatelessWidget {
  final List<QueryDocumentSnapshot> cartDocs;

  OrderSummary({required this.cartDocs});

  Future<List<Map<String, dynamic>>> _getLatestProductData() async {
    List<Map<String, dynamic>> updatedCart = [];

    for (var item in cartDocs) {
      final productId = item['productId'];
      final productSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get();

      if (productSnapshot.exists) {
        final productData = productSnapshot.data()!;
        final double latestPrice = (productData['price'] as num).toDouble();
        final int quantity = item['quantity'];
        final int stock = productData['stock'];

        updatedCart.add({
          'price': latestPrice,
          'quantity': quantity,
          'stock': stock,
          'productName': productData['productName'],
        });
      }
    }

    return updatedCart;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth * 0.04;

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getLatestProductData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final updatedCart = snapshot.data!;
        int totalItems = 0;
        double subtotal = 0;
        bool hasStockIssue = false;
        String stockWarning = "";

        for (var item in updatedCart) {
          int quantity = item['quantity'];
          int stock = item['stock'];
          String name = item['productName'];

          if (quantity > stock) {
            hasStockIssue = true;
            stockWarning +=
                "• '$name' exceeds stock (Available: $stock, In cart: $quantity)\n";
          }

          totalItems += quantity;
          subtotal += item['price'] * quantity;
        }

        double deliveryCharges = 0.05 * subtotal;

        double total = subtotal + deliveryCharges;

        return Container(
          padding: EdgeInsets.all(screenWidth * 0.04),
          margin: EdgeInsets.all(screenWidth * 0.04),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Order Summary",
                  style: GoogleFonts.notoSans(
                      fontSize: fontSize, fontWeight: FontWeight.bold)),
              Divider(),
              _buildRow("Items", "$totalItems", fontSize),
              _buildRow(
                  "Subtotal", "₱${subtotal.toStringAsFixed(2)}", fontSize),
              _buildRow("Delivery", "₱${deliveryCharges.toStringAsFixed(2)}",
                  fontSize),
              Divider(),
              _buildRow("Total", "₱${total.toStringAsFixed(2)}", fontSize),
              if (hasStockIssue) ...[
                SizedBox(height: 10),
                Text("⚠ Stock issue:",
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold)),
                Text(stockWarning.trim(),
                    style:
                        TextStyle(color: Colors.red, fontSize: fontSize * 0.9)),
              ],
              SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF651D32), // Maroon
                    padding:
                        EdgeInsets.symmetric(vertical: screenWidth * 0.045),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 3,
                  ),
                  onPressed: hasStockIssue
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CheckoutPage(
                                totalPrice: total,
                                userId: FirebaseAuth.instance.currentUser!.uid,
                              ),
                            ),
                          );
                        },
                  icon: Icon(Icons.payment,
                      color: Colors.white, size: screenWidth * 0.06),
                  label: Text(
                    "Proceed to Checkout",
                    style: GoogleFonts.poppins(
                      fontSize: screenWidth * 0.045,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRow(String label, String value, double fontSize) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: fontSize, fontWeight: FontWeight.w500)),
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: fontSize, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
