import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lspu/wishlist.dart';
import 'dashboard.dart'; // Import DashboardScreen
import 'profile.dart'; // Import ProfileScreen
import 'product.dart';
import 'package:google_fonts/google_fonts.dart';
import 'cart.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';

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
  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainNavigation(),
    );
  }
}

// Main Navigation with BottomNavigationBar
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 2;
  late final List<Widget> _pages; // ✅ Persistent tabs
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
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF651D32),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
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

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: Colors.white,
                title: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search for products...",
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search, size: 28),
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.filter_list, size: 28),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true, // ✅ allows full height scroll
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        builder: (context) {
                          return SafeArea(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  bottom:
                                      MediaQuery.of(context).viewInsets.bottom),
                              child: SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Center(
                                        child: Container(
                                          width: 40,
                                          height: 4,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius:
                                                BorderRadius.circular(2),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 16),
                                      Text('Filter Options',
                                          style: GoogleFonts.poppins(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold)),
                                      SizedBox(height: 16),
                                      Text('Category',
                                          style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500)),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          FilterChip(
                                              label: Text('Clothes'),
                                              onSelected: (_) {}),
                                          FilterChip(
                                              label: Text('School'),
                                              onSelected: (_) {}),
                                          FilterChip(
                                              label: Text('Sports'),
                                              onSelected: (_) {}),
                                          FilterChip(
                                              label: Text('Food'),
                                              onSelected: (_) {}),
                                          FilterChip(
                                              label: Text('All'),
                                              onSelected: (_) {}),
                                        ],
                                      ),
                                      SizedBox(height: 16),
                                      Text('Price Range',
                                          style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500)),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              decoration: InputDecoration(
                                                labelText: 'Min Price',
                                                border: OutlineInputBorder(),
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: TextField(
                                              decoration: InputDecoration(
                                                labelText: 'Max Price',
                                                border: OutlineInputBorder(),
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 16),
                                      Text('Ratings',
                                          style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500)),
                                      Row(
                                        children: List.generate(5, (index) {
                                          return IconButton(
                                            icon: Icon(
                                              Icons.star,
                                              color: index < 4
                                                  ? Colors.amber
                                                  : Colors.grey,
                                            ),
                                            onPressed: () {},
                                          );
                                        }),
                                      ),
                                      SizedBox(height: 16),
                                      Center(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0xFF651D32),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 32, vertical: 12),
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text('Apply Filters',
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              )),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseAuth.instance.currentUser == null
                        ? null
                        : FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .collection('cart')
                            .snapshots(),
                    builder: (context, snapshot) {
                      int cartCount = 0;
                      if (snapshot.hasData) {
                        cartCount = snapshot.data!.docs.length;
                      }

                      return Stack(
                        children: [
                          IconButton(
                            icon: Icon(Icons.shopping_cart, size: 28),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CartScreen()),
                              );
                            },
                          ),
                          if (cartCount > 0)
                            Positioned(
                              right: 6,
                              top: 6,
                              child: Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '$cartCount',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
              Container(width: double.infinity, height: 1, color: Colors.grey),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: ProductVerticalList(),
      ),
    );
  }
}

class ProductVerticalList extends StatefulWidget {
  const ProductVerticalList({Key? key}) : super(key: key);

  @override
  State<ProductVerticalList> createState() => _ProductVerticalListState();
}

class _ProductVerticalListState extends State<ProductVerticalList> {
  @override
  void initState() {
    super.initState();
    WishlistButton.refreshCallback = () {
      if (mounted) setState(() {});
    };
  }

  @override
  void dispose() {
    WishlistButton.refreshCallback = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    // ignore: unused_local_variable
    int crossAxisCount = 2;
    if (screenWidth >= 600 && screenWidth < 900) {
      crossAxisCount = 3;
    } else if (screenWidth >= 900) {
      crossAxisCount = 4;
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('products').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No products found.'));
        }

        final products = snapshot.data!.docs;

        return LayoutBuilder(
          builder: (context, constraints) {
            double screenWidth = constraints.maxWidth;
            int crossAxisCount = 2;
            if (screenWidth >= 600 && screenWidth < 900) {
              crossAxisCount = 3;
            } else if (screenWidth >= 900) {
              crossAxisCount = 4;
            }

            double childAspectRatio = screenWidth < 400 ? 0.55 : 0.66;

            return GridView.builder(
              itemCount: products.length,
              padding: const EdgeInsets.all(12),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 16,
                crossAxisSpacing: 12,
                childAspectRatio: childAspectRatio,
              ),
              itemBuilder: (context, index) {
                final product = products[index];
                final data = product.data() as Map<String, dynamic>;
                data['productId'] = product.id;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailPage(
                          productData: data,
                          productId: product.id,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.15),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: screenWidth / crossAxisCount * 0.6,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            image: data['imageUrl'] != null
                                ? DecorationImage(
                                    image: NetworkImage(data['imageUrl']),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: data['imageUrl'] == null
                              ? const Center(
                                  child: Text('No Image',
                                      style: TextStyle(color: Colors.grey)),
                                )
                              : null,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['productName'] ?? 'No name',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  '₱${data['price'].toString()}',
                                  style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Row(
                                  children: [
                                    const Icon(Icons.star,
                                        color: Colors.amber, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      '0.0',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '(0)',
                                      style: GoogleFonts.poppins(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                SizedBox(
                                  width: double.infinity,
                                  child: WishlistButton(data: data),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

// 🛠 Wishlist Button directly inside ProductVerticalList
class WishlistButton extends StatefulWidget {
  final Map<String, dynamic> data;

  const WishlistButton({Key? key, required this.data}) : super(key: key);

  static final Map<String, bool> _wishlistStates = {};
  static Function()? refreshCallback;

  static void updateWishlistState(String productId, bool value) {
    _wishlistStates[productId] = value;
    refreshCallback?.call();
  }

  @override
  _WishlistButtonState createState() => _WishlistButtonState();
}

class _WishlistButtonState extends State<WishlistButton> {
  bool? isWishlisted; // nullable at start
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _checkIfWishlisted();
  }

  Future<void> _checkIfWishlisted() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final wishlistRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('wishlist');

    final productId = widget.data['productId'];

    final snapshot = await wishlistRef
        .where('productId', isEqualTo: productId)
        .limit(1)
        .get();

    final result = snapshot.docs.isNotEmpty;

    setState(() {
      isWishlisted = result;
      loading = false;
      WishlistButton._wishlistStates[productId] = result;
    });
  }

  void toggleWishlist() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final productId = widget.data['productId'];
    final wishlistRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('wishlist');

    if (isWishlisted == false) {
      await wishlistRef.add({
        'productId': productId,
        'productName': widget.data['productName'],
        'price': widget.data['price'],
        'imageUrl': widget.data['imageUrl'],
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      final snapshot =
          await wishlistRef.where('productId', isEqualTo: productId).get();

      for (var doc in snapshot.docs) {
        await wishlistRef.doc(doc.id).delete();
      }
    }

    setState(() {
      isWishlisted = !isWishlisted!;
      WishlistButton.updateWishlistState(productId, isWishlisted!);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading || isWishlisted == null) {
      return const CircularProgressIndicator(); // or a placeholder button
    }

    return ElevatedButton(
      onPressed: toggleWishlist,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isWishlisted! ? Colors.grey[300] : const Color(0xFF651D32),
        foregroundColor: isWishlisted! ? Colors.black : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        isWishlisted! ? 'Remove from Wishlist' : 'Add to Wishlist',
        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }
}
