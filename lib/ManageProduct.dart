import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'AddProduct.dart';
import 'package:lspu/navigation_drawer.dart' as custom;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'EditProduct.dart';

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
    url: 'https://haoiqctsijynxwfoaspm.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Product List',
      theme: ThemeData(primarySwatch: Colors.green),
      home: Manageproduct(),
    );
  }
}

class Manageproduct extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;
    final userId = FirebaseAuth.instance.currentUser?.uid;

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
      body: userId == null
          ? Center(child: Text("User not logged in"))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .collection('sellerInfo')
                  .limit(1)
                  .snapshots(),
              builder: (context, sellerSnapshot) {
                if (sellerSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!sellerSnapshot.hasData ||
                    sellerSnapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No seller info found."));
                }

                final sellerId = sellerSnapshot.data!.docs.first.id;
                print("Current seller ID: $sellerId"); // Add this line to debug

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('products')
                      .where('sellerId', isEqualTo: sellerId)
                      .snapshots(),
                  builder: (context, productSnapshot) {
                    if (productSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (!productSnapshot.hasData ||
                        productSnapshot.data!.docs.isEmpty) {
                      return Center(child: Text("No products found."));
                    }
                    if (!productSnapshot.hasData ||
                        productSnapshot.data!.docs.isEmpty) {
                      return Center(
                          child:
                              Text("No products found (sellerId: $sellerId)"));
                    }

                    final products = productSnapshot.data!.docs;

                    return Padding(
                      padding: EdgeInsets.all(isLargeScreen ? 24 : 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Home / Manage Product",
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
                                final product = products[index].data()
                                    as Map<String, dynamic>;
                                final stockValue = product['stock'];
                                final stock = stockValue is int
                                    ? stockValue
                                    : stockValue is String
                                        ? int.tryParse(stockValue) ?? 0
                                        : 0;
                                return Container(
                                  margin: EdgeInsets.only(
                                      bottom: isLargeScreen ? 20 : 16),
                                  padding:
                                      EdgeInsets.all(isLargeScreen ? 20 : 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 6,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (product['imageUrl'] != null &&
                                          product['imageUrl'].isNotEmpty)
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Image.network(
                                            product['imageUrl'],
                                            height: 180,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      SizedBox(height: 12),
                                      Text(
                                        product['productName'] ?? 'No Name',
                                        style: GoogleFonts.poppins(
                                          fontSize: isLargeScreen ? 18 : 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "Category: ${product['category'] ?? 'N/A'}",
                                        style: GoogleFonts.poppins(
                                          fontSize: isLargeScreen ? 14 : 13,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Text(
                                        "Stock: $stock",
                                        style: GoogleFonts.poppins(
                                          fontSize: isLargeScreen ? 14 : 13,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Text(
                                        "Price: ₱${product['price']?.toString() ?? '0.00'}",
                                        style: GoogleFonts.roboto(
                                          fontSize: isLargeScreen ? 14 : 13,
                                          color: Colors.green[700],
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Divider(height: 20, thickness: 1),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          TextButton.icon(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      EditProductScreen(
                                                    productId:
                                                        products[index].id,
                                                    productData: product,
                                                    sellerId: sellerId,
                                                    userId: userId,
                                                  ),
                                                ),
                                              );
                                            },
                                            icon: Icon(Icons.edit,
                                                color: Colors.blue),
                                            label: Text(
                                              "Edit",
                                              style: GoogleFonts.poppins(
                                                color: Colors.blue,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          TextButton.icon(
                                            onPressed: () async {
                                              // Show confirmation dialog
                                              bool confirmDelete =
                                                  await showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                  title: Text('Confirm Delete'),
                                                  content: Text(
                                                      'Are you sure you want to delete this product?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.of(context)
                                                              .pop(false),
                                                      child: Text('Cancel'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.of(context)
                                                              .pop(true),
                                                      child: Text(
                                                        'Delete',
                                                        style: TextStyle(
                                                            color: Colors.red),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );

                                              if (confirmDelete != true) {
                                                return; // User canceled the deletion
                                              }

                                              final productId =
                                                  products[index].id;

                                              try {
                                                // Only delete the product document from Firestore
                                                await FirebaseFirestore.instance
                                                    .collection('products')
                                                    .doc(productId)
                                                    .delete();

                                                print(
                                                    'Product deleted successfully.');

                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                      content: Text(
                                                          'Product deleted successfully')),
                                                );
                                              } catch (e) {
                                                print(
                                                    'Error deleting product: $e');
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                      content: Text(
                                                          'Failed to delete product')),
                                                );
                                              }
                                            },
                                            icon: Icon(Icons.delete,
                                                color: Colors.red),
                                            label: Text(
                                              "Remove",
                                              style: GoogleFonts.poppins(
                                                color: Colors.red,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
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
            color: Colors.white,
          ),
        ),
        icon:
            Icon(Icons.add, color: Colors.white, size: isLargeScreen ? 24 : 20),
        backgroundColor: Color(0xFF651D32),
      ),
    );
  }
}
