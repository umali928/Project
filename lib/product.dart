import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'cart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'searchPage.dart';
import 'package:intl/intl.dart';

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
    await Firebase.initializeApp();
  }
  await Supabase.initialize(
    url: 'https://haoiqctsijynxwfoaspm.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhhb2lxY3RzaWp5bnh3Zm9hc3BtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQxNzU3MDMsImV4cCI6MjA1OTc1MTcwM30.7kilmu9kxrABgg4ZMz9GIHm5Jv4LHLAIYR1_8q1eDEI',
  );
  runApp(ProductDetailApp());
}

class ProductDetailApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const ProductDetailPage(productData: {}, productId: ''),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ProductReview {
  final String userId;
  final String userName;
  final String profilePicUrl;
  final String productId;
  final double rating;
  final String comment;
  final DateTime timestamp;

  ProductReview({
    required this.userId,
    required this.userName,
    required this.productId,
    required this.profilePicUrl,
    required this.rating,
    required this.comment,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'productId': productId,
      'rating': rating,
      'comment': comment,
      'timestamp': timestamp,
    };
  }

  factory ProductReview.fromMap(Map<String, dynamic> map) {
    return ProductReview(
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Anonymous',
      profilePicUrl: map['profilePicUrl'] ?? '',
      productId: map['productId'] ?? '',
      rating: map['rating']?.toDouble() ?? 0.0,
      comment: map['comment'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
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
  String storeName = 'Loading...';
  List<ProductReview> reviews = [];
  bool canReview = false;
  TextEditingController reviewController = TextEditingController();
  double userRating = 0.0;
  String? orderId;
  @override
  void initState() {
    super.initState();
    fetchProductDetails();
    checkIfUserCanReview();
  }

  // void _startChatWithSeller(BuildContext context) async {
  //   final user = FirebaseAuth.instance.currentUser;
  //   if (user == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Please log in to message the seller")),
  //     );
  //     return;
  //   }

  //   try {
  //     // Get product document
  //     final productDoc = await FirebaseFirestore.instance
  //         .collection('products')
  //         .doc(widget.productId)
  //         .get();

  //     if (!productDoc.exists || !productDoc.data()!.containsKey('sellerId')) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text("Product or seller information not found")),
  //       );
  //       return;
  //     }

  //     final sellerId = productDoc['sellerId'];
  //     if (sellerId == null || sellerId.isEmpty) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text("Seller ID is missing")),
  //       );
  //       return;
  //     }

  //     // Find the user document that contains the seller ID in its sellerInfo subcollection
  //     final usersSnapshot =
  //         await FirebaseFirestore.instance.collection('users').get();

  //     String? userDocId;
  //     Map<String, dynamic>? sellerData;

  //     for (var userDoc in usersSnapshot.docs) {
  //       // Retrieve all documents from the sellerInfo subcollection
  //       final sellerInfoSnapshot = await FirebaseFirestore.instance
  //           .collection('users')
  //           .doc(userDoc.id)
  //           .collection('sellerInfo')
  //           .get();

  //       for (var doc in sellerInfoSnapshot.docs) {
  //         if (doc.id == sellerId) {
  //           userDocId = userDoc.id;
  //           sellerData = doc.data();
  //           break;
  //         }
  //       }

  //       if (sellerData != null) break;
  //     }

  //     if (sellerData == null) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text("Unable to retrieve seller information")),
  //       );
  //       return;
  //     }

  //     final sellerName = sellerData['storeName'] ?? 'Unknown Seller';

  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => MessageScreen(
  //           otherUserId: userDocId!,
  //           otherUserName: sellerName,
  //           otherUserType: 'seller',
  //           currentUserType: 'user',
  //         ),
  //       ),
  //     );
  //   } catch (e) {
  //     print("Error starting chat: $e");
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Failed to start chat with seller: $e")),
  //     );
  //   }
  // }

  void checkIfUserCanReview() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final orders = await FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .get();

      bool hasDelivered = false;

      for (var order in orders.docs) {
        final orderData = order.data();

        if (orderData['items'] is List) {
          for (var item in orderData['items']) {
            if (item['productId'] == widget.productId &&
                item['status'] == 'Delivered') {
              hasDelivered = true;
              break;
            }
          }
        } else if (orderData['items'] is Map) {
          var item = orderData['items'];
          if (item['productId'] == widget.productId &&
              item['status'] == 'Delivered') {
            hasDelivered = true;
          }
        }

        if (hasDelivered) break;
      }

      for (var order in orders.docs) {
        final orderData = order.data();
        final orderId = order.id;

        if (orderData['items'] is List) {
          for (var item in orderData['items']) {
            if (item['productId'] == widget.productId &&
                item['status'] == 'Delivered') {
              final reviewExists = await FirebaseFirestore.instance
                  .collection('products')
                  .doc(widget.productId)
                  .collection('reviews')
                  .where('userId', isEqualTo: user.uid)
                  .where('orderId', isEqualTo: orderId)
                  .get();

              if (reviewExists.docs.isEmpty) {
                setState(() {
                  canReview = true;
                  this.orderId = orderId; // You'll need to store this
                });
                return;
              }
            }
          }
        }
      }
    } catch (e) {
      print("Error checking review eligibility: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error checking review eligibility")),
      );
    }
  }

  void fetchProductDetails() async {
    try {
      final productDoc = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .get();

      if (productDoc.exists) {
        final data = productDoc.data()!;
        final sellerId = data['sellerId'];

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
            break;
          }
        }

        // Fetch reviews
        final reviewsSnapshot = await FirebaseFirestore.instance
            .collection('products')
            .doc(widget.productId)
            .collection('reviews')
            .orderBy('timestamp', descending: true)
            .get();

        setState(() {
          reviews = reviewsSnapshot.docs
              .map((doc) => ProductReview.fromMap(doc.data()))
              .toList();
        });
      }
    } catch (e) {
      print("Error fetching product details: $e");
    }
  }

  Future<void> submitReview() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || !canReview || userRating == 0.0) return;
    // Validation: Check if rating is at least 1 star
    if (userRating == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a rating (1-5 stars)")),
      );
      return;
    }
    try {
      // Get user details from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final userData = userDoc.data();
      final String displayName =
          userData?['fullName'] ?? user.displayName ?? 'Anonymous';
      final String profilePicUrl = userData?['profilePicUrl'] ?? '';
      // Add the review
      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .collection('reviews')
          .add({
        'userId': user.uid,
        'userName': displayName,
        'profilePicUrl': profilePicUrl,
        'productId': widget.productId,
        'orderId': orderId, // <-- ADD THIS LINE
        'rating': userRating,
        'comment': reviewController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Recalculate average rating
      final reviewsSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .collection('reviews')
          .get();

      double totalRating = 0;
      for (var doc in reviewsSnapshot.docs) {
        totalRating += doc['rating'] ?? 0;
      }
      double newAverage = totalRating / reviewsSnapshot.docs.length;

      // Update product with new rating and review count
      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .update({
        'rating': newAverage,
        'reviewsCount': reviewsSnapshot.docs.length,
      });

      // Refresh UI
      fetchProductDetails();
      reviewController.clear();
      setState(() {
        userRating = 0.0;
        canReview = false; // Add this line to hide the review section
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Review submitted successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit review: $e")),
      );
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
            // Expanded(
            //   child: OutlinedButton(
            //     style: OutlinedButton.styleFrom(
            //       padding: EdgeInsets.symmetric(vertical: 16),
            //       side: BorderSide(color: Color(0xFF651D32)),
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(8),
            //       ),
            //     ),
            //     onPressed: () => _startChatWithSeller(context),
            //     child: Text(
            //       "Message Seller",
            //       style: GoogleFonts.poppins(
            //         color: Color(0xFF651D32),
            //         fontSize: 16,
            //         fontWeight: FontWeight.bold,
            //       ),
            //     ),
            //   ),
            // ),
            // SizedBox(width: 16),
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

                  if (product['stock'] == 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("This product is out of stock")),
                    );
                    return;
                  }

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

                    final querySnapshot = await cartRef
                        .where('productId', isEqualTo: widget.productId)
                        .limit(1)
                        .get();

                    if (querySnapshot.docs.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text("Product is already in your cart")),
                      );
                      return;
                    }

                    await cartRef.add({
                      'productId': widget.productId,
                      'productName': widget.productData['productName'],
                      'price': widget.productData['price'],
                      'imageUrl': widget.productData['imageUrl'],
                      'quantity': 1,
                      'timestamp': FieldValue.serverTimestamp(),
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Product added to cart")),
                    );
                  } catch (e) {
                    print("Error adding to cart: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Failed to add product to cart")),
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

            Text(
              product['productName'] ?? 'No Name',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Product by: $storeName",
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              "₱${product['price']?.toString() ?? '0'}",
              style: GoogleFonts.roboto(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

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

            Text(
              "Stock: ${product['stock']?.toString() ?? '0'}",
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            const SizedBox(height: 32),

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

            // Review Input Section
            if (canReview)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Write a Review",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      for (int i = 1; i <= 5; i++)
                        IconButton(
                          icon: Icon(
                            i <= userRating ? Icons.star : Icons.star_border,
                            color: Colors.orange,
                            size: 30,
                          ),
                          onPressed: () {
                            setState(() {
                              userRating = i.toDouble();
                            });
                          },
                        ),
                    ],
                  ),
                  TextField(
                    controller: reviewController,
                    decoration: InputDecoration(
                      hintText: "Share your thoughts about this product...",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: submitReview,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF651D32),
                    ),
                    child: Text(
                      "Submit Review",
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),

            // Reviews Section
            Text(
              "Reviews (${reviews.length})",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            reviews.isNotEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: reviews.length,
                    itemBuilder: (context, index) {
                      final review = reviews[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.grey.shade300,
                                  backgroundImage:
                                      review.profilePicUrl.isNotEmpty
                                          ? NetworkImage(review.profilePicUrl)
                                          : null,
                                  child: review.profilePicUrl.isEmpty
                                      ? Icon(Icons.person, color: Colors.white)
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      review.userName,
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Row(
                                      children: List.generate(
                                          5,
                                          (i) => Icon(
                                                i < review.rating
                                                    ? Icons.star
                                                    : Icons.star_border,
                                                size: 16,
                                                color: Colors.orange,
                                              )),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              review.comment,
                              style: GoogleFonts.poppins(fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              DateFormat('MMM dd, yyyy')
                                  .format(review.timestamp),
                              style: GoogleFonts.poppins(
                                color: Colors.grey,
                                fontSize: 12,
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

              WishlistButton.updateWishlistState(productId, true);
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

              WishlistButton.updateWishlistState(productId, false);
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
