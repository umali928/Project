import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'cart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'searchPage.dart'; // or wherever WishlistButton is defined

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
  runApp(ProductDetailApp());
}

class ProductDetailApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const ProductDetailPage(
          productData: {}, productId: ''), // Default values
      debugShowCheckedModeBanner: false,
    );
  }
}

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> productData;
  final String productId;

  const ProductDetailPage(
      {Key? key, required this.productData, required this.productId})
      : super(key: key);

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  double rating = 0.0;
  int reviewsCount = 0;
  String storeName = 'Loading...'; // Default or placeholder
  @override
  void initState() {
    super.initState();
    fetchProductDetails();
  }

  void fetchProductDetails() async {
    try {
      final productDoc = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .get();

      if (productDoc.exists) {
        final data = productDoc.data()!;
        final sellerId =
            data['sellerId']; // This is the ID inside sellerInfo subcollection

        final usersSnapshot =
            await FirebaseFirestore.instance.collection('users').get();

        for (var userDoc in usersSnapshot.docs) {
          final sellerInfoSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(userDoc.id)
              .collection('sellerInfo')
              .doc(sellerId)
              .get();

          if (sellerInfoSnapshot.exists) {
            final sellerData = sellerInfoSnapshot.data();
            setState(() {
              rating = data['rating'] ?? 0.0;
              reviewsCount = data['reviewsCount'] ?? 0;
              storeName = sellerData?['storeName'] ?? 'Unknown Seller';
            });
            return; // Exit loop once found
          }
        }

        // If not found in any user document
        setState(() {
          storeName = 'Unknown Seller';
        });
      }
    } catch (e) {
      print("Error fetching product details or seller name: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.productData;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          WishlistHeartIcon(data: {
            'productId': widget.productId,
            'productName': widget.productData['productName'],
            'price': widget.productData['price'],
            'imageUrl': widget.productData['imageUrl'],
          }),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black),
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
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.04, vertical: 12),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF651D32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text("Please log in to add items to your cart")),
                    );
                    return;
                  }

                  try {
                    final cartRef = FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .collection('cart');

                    final existing = await cartRef
                        .where('productId', isEqualTo: widget.productId)
                        .limit(1)
                        .get();

                    if (existing.docs.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Item already in cart")),
                      );
                    } else {
                      await cartRef.add({
                        'productId': widget.productId,
                        'productName': widget.productData['productName'],
                        'price': widget.productData['price'],
                        'imageUrl': widget.productData['imageUrl'],
                        'quantity': 1,
                        'addedAt': Timestamp.now(),
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Added to cart")),
                      );
                    }
                  } catch (e) {
                    print("Add to cart error: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Failed to add to cart")),
                    );
                  }
                },
                child: Text("Add to Cart",
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              height: MediaQuery.of(context).size.height * 0.3,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                image: product['imageUrl'] != null
                    ? DecorationImage(
                        image: NetworkImage(product['imageUrl']),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              alignment: Alignment.center,
              child:
                  product['imageUrl'] == null ? const Text("No Image") : null,
            ),
            const SizedBox(height: 16),

            // Product Name
            Text(
              product['productName'] ?? 'No Name',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 8),
            // Store Name
            Text(
              "Product by: $storeName",
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            // Product Price
            Text(
              "₱${product['price']?.toString() ?? '0'}",
              style: GoogleFonts.roboto(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Product Description
            Text(
              "Description",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              product['description'] ?? 'No description available.',
              style: GoogleFonts.poppins(height: 1.6, fontSize: 16),
            ),
            const SizedBox(height: 20),

            // Product Stock
            Text(
              "Stock: ${product['stock']?.toString() ?? '0'}",
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            const SizedBox(height: 32),

            // Rating and Reviews
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(1),
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "$reviewsCount Reviews",
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Reviews Section
            Text(
              "Reviews",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            reviewsCount > 0
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: reviewsCount,
                    itemBuilder: (context, index) {
                      // Placeholder for actual review data
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.grey.shade300,
                              child:
                                  const Icon(Icons.person, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "User $index",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "This is a placeholder review. Replace this with actual review content.",
                                    style: GoogleFonts.poppins(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  )
                : Center(
                    child: Text(
                      "No reviews yet. Be the first to review this product!",
                      style: GoogleFonts.poppins(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
            const SizedBox(height: 32),

            // Spacer to fill remaining space
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.2,
            ),
          ],
        ),
      ),
    );
  }
}

class WishlistHeartIcon extends StatelessWidget {
  final Map<String, dynamic> data;

  const WishlistHeartIcon({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final productId = data['productId'];

    if (user == null) {
      return const Icon(Icons.favorite_border, color: Colors.grey);
    }

    final wishlistRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('wishlist');

    return StreamBuilder<QuerySnapshot>(
      stream: wishlistRef
          .where('productId', isEqualTo: productId)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        final isWishlisted = snapshot.hasData && snapshot.data!.docs.isNotEmpty;

        return IconButton(
          icon: Icon(
            isWishlisted ? Icons.favorite : Icons.favorite_border,
            color: isWishlisted ? Colors.red : Colors.black,
          ),
          onPressed: () async {
            if (!isWishlisted) {
              await wishlistRef.add({
                'productId': productId,
                'productName': data['productName'],
                'price': data['price'],
                'imageUrl': data['imageUrl'],
                'timestamp': FieldValue.serverTimestamp(),
              });

              // 🔄 Update WishlistButton state (used in SearchPage)
              WishlistButton.updateWishlistState(productId, true); // for adding
              if (WishlistButton.refreshCallback != null) {
                WishlistButton.refreshCallback!();
              }
            } else {
              final toRemove = await wishlistRef
                  .where('productId', isEqualTo: productId)
                  .get();

              for (var doc in toRemove.docs) {
                await wishlistRef.doc(doc.id).delete();
              }

              // 🔄 Sync state on removal
              WishlistButton.updateWishlistState(
                  productId, false); // for removing
              if (WishlistButton.refreshCallback != null) {
                WishlistButton.refreshCallback!();
              }
            }
          },
        );
      },
    );
  }
}
