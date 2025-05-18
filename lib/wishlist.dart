import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dashboard.dart';
import 'profile.dart';
import 'searchPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'product.dart';

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
        storageBucket: "lspumart.appspot.com",
        messagingSenderId: "533992551897",
        appId: "1:533992551897:web:d04a482ad131a0700815c8",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  await Supabase.initialize(
    url: 'https://haoiqctsijynxwfoaspm.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhhb2lxY3RzaWp5bnh3Zm9hc3BtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQxNzU3MDMsImV4cCI6MjA1OTc1MTcwM30.7kilmu9kxrABgg4ZMz9GIHm5Jv4LHLAIYR1_8q1eDEI',
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Wishlist(),
    );
  }
}

class Wishlist extends StatefulWidget {
  @override
  _WishlistScreenState createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<Wishlist> {
  int _selectedIndex = 1;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeScreen(),
      WishlistScreen(),
      SearchPage(),
      SettingsPage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF651D32),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border), label: "Wishlist"),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag), label: "Shop"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

class WishlistScreen extends StatelessWidget {
  Future<List<QueryDocumentSnapshot>> _cleanAndGetValidWishlistItems(
      List<QueryDocumentSnapshot> wishlistDocs) async {
    List<QueryDocumentSnapshot> validItems = [];

    for (var doc in wishlistDocs) {
      final data = doc.data() as Map<String, dynamic>;
      final productId = data['productId'];

      if (productId == null) continue;

      final productDoc = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get();
      if (productDoc.exists) {
        validItems.add(doc);
      } else {
        await doc.reference.delete();
      }
    }
    return validItems;
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context, String docId,
      String productId, CollectionReference wishlistCollection) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Remove from wishlist', style: GoogleFonts.poppins()),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Are you sure you want to remove this item from your wishlist?',
                    style: GoogleFonts.poppins()),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel',
                  style: GoogleFonts.poppins(color: Colors.grey[600])),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Remove',
                  style: GoogleFonts.poppins(color: Color(0xFF651D32))),
              onPressed: () async {
                Navigator.of(context).pop();
                await wishlistCollection.doc(docId).delete();
                WishlistButton.updateWishlistState(productId, false);
                if (WishlistButton.refreshCallback != null) {
                  WishlistButton.refreshCallback!();
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Item removed from wishlist"),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite_border, size: 60, color: Colors.grey[400]),
              SizedBox(height: 20),
              Text('Please log in to view your wishlist',
                  style: GoogleFonts.poppins(
                      fontSize: 18, color: Colors.grey[600])),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF651D32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () {
                  // Add login navigation here
                },
                child: Text('Login',
                    style: GoogleFonts.poppins(
                        color: Colors.white, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ),
      );
    }

    final wishlistCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('wishlist');
    final wishlistQuery =
        wishlistCollection.orderBy('timestamp', descending: true);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: Text('My Wishlist',
            style: GoogleFonts.poppins(
                color: Color(0xFF651D32),
                fontWeight: FontWeight.w600,
                fontSize: 20)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: wishlistQuery.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF651D32)),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border,
                      size: 60, color: Colors.grey[400]),
                  SizedBox(height: 20),
                  Text('Your wishlist is empty',
                      style: GoogleFonts.poppins(
                          fontSize: 18, color: Colors.grey[600])),
                  SizedBox(height: 10),
                  Text('Start adding items you love!',
                      style: GoogleFonts.poppins(
                          fontSize: 14, color: Colors.grey[500])),
                ],
              ),
            );
          }

          final wishlistDocs = snapshot.data!.docs;

          return FutureBuilder(
            future: _cleanAndGetValidWishlistItems(wishlistDocs),
            builder: (context,
                AsyncSnapshot<List<QueryDocumentSnapshot>> validSnapshot) {
              if (!validSnapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF651D32)),
                  ),
                );
              }

              final validItems = validSnapshot.data!;
              if (validItems.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border,
                          size: 60, color: Colors.grey[400]),
                      SizedBox(height: 20),
                      Text('Your wishlist is empty',
                          style: GoogleFonts.poppins(
                              fontSize: 18, color: Colors.grey[600])),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 16.0, right: 16.0, top: 16.0, bottom: 8.0),
                    child: Row(
                      children: [
                        Text('${validItems.length} items',
                            style: GoogleFonts.poppins(
                                color: Colors.grey[600], fontSize: 14)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      itemCount: validItems.length,
                      itemBuilder: (context, index) {
                        final data =
                            validItems[index].data() as Map<String, dynamic>;
                        final docId = validItems[index].id;
                        final productId = data['productId'];

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          child: StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('products')
                                .doc(productId)
                                .snapshots(),
                            builder: (context, productSnapshot) {
                              if (!productSnapshot.hasData ||
                                  !productSnapshot.data!.exists) {
                                return SizedBox.shrink();
                              }

                              final productData = productSnapshot.data!.data()
                                  as Map<String, dynamic>;

                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                                margin: EdgeInsets.zero,
                                color: Colors.white,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProductDetailPage(
                                          productId: productId,
                                          productData: productData,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Container(
                                            width: 80,
                                            height: 80,
                                            color: Colors.grey[100],
                                            child: Image.network(
                                              productData['imageUrl'] ?? '',
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  Center(
                                                      child: Icon(
                                                          Icons.broken_image,
                                                          size: 30,
                                                          color: Colors
                                                              .grey[300])),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  productData['productName'] ??
                                                      '',
                                                  style: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 15)),
                                              SizedBox(height: 4),
                                              Text(
                                                productData['category'] ?? '',
                                                style: GoogleFonts.poppins(
                                                    color: Colors.grey[600],
                                                    fontSize: 12),
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                '₱${(productData['price'] ?? 0).toStringAsFixed(2)}',
                                                style: GoogleFonts.roboto(
                                                    color: Color(0xFF651D32),
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 16),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.favorite,
                                                  color: Color(0xFF651D32)),
                                              onPressed: () async {
                                                await _showDeleteConfirmationDialog(
                                                    context,
                                                    docId,
                                                    productId,
                                                    wishlistCollection);
                                              },
                                            ),
                                            SizedBox(height: 20),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Color(0xFF651D32),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: IconButton(
                                                icon: Icon(
                                                    Icons.add_shopping_cart,
                                                    color: Colors.white,
                                                    size: 20),
                                                onPressed: () async {
                                                  final cartRef =
                                                      FirebaseFirestore.instance
                                                          .collection('users')
                                                          .doc(user.uid)
                                                          .collection('cart');

                                                  final existing = await cartRef
                                                      .where('productId',
                                                          isEqualTo: productId)
                                                      .get();

                                                  if (existing.docs.isEmpty) {
                                                    await cartRef.add({
                                                      'productId': productId,
                                                      'productName':
                                                          productData[
                                                              'productName'],
                                                      'price':
                                                          productData['price'],
                                                      'imageUrl': productData[
                                                          'imageUrl'],
                                                      'quantity': 1,
                                                      'timestamp': FieldValue
                                                          .serverTimestamp(),
                                                    });

                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(SnackBar(
                                                      content:
                                                          Text("Added to cart"),
                                                      behavior: SnackBarBehavior
                                                          .floating,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                    ));
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(SnackBar(
                                                      content: Text(
                                                          "Item is already in your cart"),
                                                      behavior: SnackBarBehavior
                                                          .floating,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                    ));
                                                  }
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF651D32),
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              shadowColor: Color(0xFF651D32).withOpacity(0.3),
            ),
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              if (user == null) return;

              final wishlistSnapshot = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('wishlist')
                  .get();

              final wishlistDocs = wishlistSnapshot.docs;
              final validItems =
                  await _cleanAndGetValidWishlistItems(wishlistDocs);

              // Check if there are no wishlist items
              if (validItems.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    content: Text(
                      "You have no wishlist items to add to cart",
                      style: GoogleFonts.poppins(),
                    ),
                  ),
                );
                return;
              }

              final cartRef = FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('cart');

              int addedCount = 0;

              for (var doc in validItems) {
                final data = doc.data() as Map<String, dynamic>;
                final productId = data['productId'];

                if (productId == null) continue;

                final existing = await cartRef
                    .where('productId', isEqualTo: productId)
                    .get();

                if (existing.docs.isEmpty) {
                  await cartRef.add({
                    'productId': productId,
                    'productName': data['productName'],
                    'price': data['price'],
                    'imageUrl': data['imageUrl'],
                    'quantity': 1,
                    'timestamp': FieldValue.serverTimestamp(),
                  });
                  addedCount++;
                }
              }

              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                content: Text(
                  addedCount == 0
                      ? "All wishlist items are already in your cart"
                      : "$addedCount item(s) added to cart",
                  style: GoogleFonts.poppins(),
                ),
              ));
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart, color: Colors.white),
                SizedBox(width: 10),
                Text('Add All To Cart',
                    style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
