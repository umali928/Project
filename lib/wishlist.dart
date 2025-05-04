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

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(child: Text('Please log in to view your wishlist.'));
    }

    final wishlistCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('wishlist');
    final wishlistQuery =
        wishlistCollection.orderBy('timestamp', descending: true);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text('Wishlist',
            style: GoogleFonts.poppins(
                color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: wishlistQuery.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
            return Center(
              child: Text(
                'Your wishlist is empty.',
                style:
                    GoogleFonts.poppins(fontSize: 18, color: Colors.grey[600]),
              ),
            );

          final wishlistDocs = snapshot.data!.docs;

          return FutureBuilder(
            future: _cleanAndGetValidWishlistItems(wishlistDocs),
            builder: (context,
                AsyncSnapshot<List<QueryDocumentSnapshot>> validSnapshot) {
              if (!validSnapshot.hasData)
                return Center(child: CircularProgressIndicator());

              final validItems = validSnapshot.data!;
              if (validItems.isEmpty) {
                return Center(
                  child: Text(
                    'Your wishlist   is empty.',
                    style: GoogleFonts.poppins(
                        fontSize: 18, color: Colors.grey[600]),
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: validItems.length,
                itemBuilder: (context, index) {
                  final data = validItems[index].data() as Map<String, dynamic>;
                  final docId = validItems[index].id;
                  final productId = data['productId'];

                  return StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('products')
                        .doc(productId)
                        .snapshots(),
                    builder: (context, productSnapshot) {
                      if (!productSnapshot.hasData ||
                          !productSnapshot.data!.exists) {
                        return SizedBox(); // Optionally show "product deleted"
                      }

                      final productData =
                          productSnapshot.data!.data() as Map<String, dynamic>;

                      return GestureDetector(
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
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 3,
                          margin: EdgeInsets.only(bottom: 12),
                          color: Colors.white,
                          child: ListTile(
                            contentPadding: EdgeInsets.all(12),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                productData['imageUrl'] ?? '',
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(Icons.broken_image, size: 40),
                              ),
                            ),
                            title: Text(productData['productName'] ?? '',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(
                              '₱${(productData['price'] ?? 0).toStringAsFixed(2)}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.add_shopping_cart,
                                      color: Color(0xFF651D32)),
                                  onPressed: () async {
                                    final cartRef = FirebaseFirestore.instance
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
                                        'productName': productData['name'],
                                        'price': productData['price'],
                                        'imageUrl': productData['imageUrl'],
                                        'quantity': 1,
                                        'timestamp':
                                            FieldValue.serverTimestamp(),
                                      });

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content: Text("Added to cart."),
                                      ));
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content: Text(
                                            "Item is already in your cart."),
                                      ));
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    await wishlistCollection
                                        .doc(docId)
                                        .delete();
                                    WishlistButton.updateWishlistState(
                                        productId, false);
                                    if (WishlistButton.refreshCallback !=
                                        null) {
                                      WishlistButton.refreshCallback!();
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF651D32),
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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

            final cartRef = FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('cart');

            int addedCount = 0;

            for (var doc in validItems) {
              final data = doc.data() as Map<String, dynamic>;
              final productId = data['productId'];

              if (productId == null) continue;

              final existing =
                  await cartRef.where('productId', isEqualTo: productId).get();

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
              content: Text(
                addedCount == 0
                    ? "All wishlist items are already in your cart."
                    : "$addedCount item(s) added to cart.",
              ),
            ));
          },
          child: Text('Add All To Cart',
              style: GoogleFonts.poppins(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
