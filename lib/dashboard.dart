import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'wishlist.dart';
import 'profile.dart';
import 'cart.dart';
import 'searchPage.dart';
import 'product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
  runApp(EcommerceApp());
}

class EcommerceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Dashboard(),
    );
  }
}

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;
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

  @override
  void dispose() {
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All'; // Default selected category
  String _searchQuery = ''; // Add this to track the search query
  final List<String> _categories = [
    'All',
    'Clothes',
    'School',
    'Sports',
    'Foods'
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("LSPU-MART",
                style: GoogleFonts.poppins(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                )),
          ],
        ),
        actions: [
          IconButton(
            icon: StreamBuilder<QuerySnapshot>(
              stream: FirebaseAuth.instance.currentUser == null
                  ? null
                  : FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .collection('notifications')
                      .where('read', isEqualTo: false)
                      .snapshots(),
              builder: (context, snapshot) {
                int unreadCount =
                    snapshot.hasData ? snapshot.data!.docs.length : 0;
                return Stack(
                  children: [
                    Icon(LucideIcons.bell, color: Colors.black),
                    if (unreadCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$unreadCount',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            onPressed: () {
              if (FirebaseAuth.instance.currentUser != null) {
                _showNotificationsDialog(context);
              }
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
                        MaterialPageRoute(builder: (context) => CartScreen()),
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;
          bool isLargeScreen = screenWidth > 600;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search here ...",
                      prefixIcon: Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                  SizedBox(height: 20),

                  /// Ad Banner
                  SizedBox(
                    height: isLargeScreen ? 300 : 120,
                    child: PageView(
                      controller: PageController(viewportFraction: 0.9),
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: AdBanner(
                              imagePath: "assets/ad1.jpg", width: screenWidth),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: AdBanner(
                              imagePath: "assets/ad2.png", width: screenWidth),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),
                  Text("Category",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),

                  if (isLargeScreen)
                    GridView.count(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 5,
                      childAspectRatio: 1,
                      children: _categories.map((category) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                          child: CategoryItem(
                            icon: _getIconForCategory(category),
                            label: category,
                            isSelected: _selectedCategory == category,
                          ),
                        );
                      }).toList(),
                    )
                  else
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _categories.map((category) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategory = category;
                              });
                            },
                            child: Padding(
                              padding: EdgeInsets.only(right: 32),
                              child: CategoryItem(
                                icon: _getIconForCategory(category),
                                label: category,
                                isSelected: _selectedCategory == category,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                  SizedBox(height: 20),
                  Text("Products",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),

                  /// Top Products
                  ProductHorizontalList(
                    category:
                        _selectedCategory == 'All' ? null : _selectedCategory,
                    searchQuery: _searchQuery,
                  ),

                  SizedBox(height: 30),
                  Text("You May Also Like",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),

                  /// You May Also Like
                  ProductHorizontalList(
                    customStream: getRandomProducts(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Clothes':
        return Icons.checkroom;
      case 'School':
        return Icons.school;
      case 'Sports':
        return Icons.sports;
      case 'Foods':
        return Icons.fastfood;
      case 'All':
      default:
        return Icons.grid_view;
    }
  }
}

// Add this method to fetch random products
Stream<List<QueryDocumentSnapshot>> getRandomProducts() {
  return FirebaseFirestore.instance
      .collection('products')
      .snapshots()
      .map((querySnapshot) {
    final allProducts = querySnapshot.docs;
    allProducts.shuffle(); // Shuffle to get random order
    return allProducts.take(10).toList(); // Take first 10 after shuffle
  });
}

class ProductHorizontalList extends StatelessWidget {
  final Stream<List<QueryDocumentSnapshot>>? customStream;
  final String? category;
  final String? searchQuery;
  const ProductHorizontalList({
    Key? key,
    this.customStream,
    this.category,
    this.searchQuery,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double cardWidth = MediaQuery.of(context).size.width /
        (MediaQuery.of(context).size.width > 600 ? 4 : 2.5);

    Stream<List<QueryDocumentSnapshot>> stream;

    if (customStream != null) {
      stream = customStream!;
    } else if (category != null) {
      stream = FirebaseFirestore.instance
          .collection('products')
          .where('category', isEqualTo: category)
          .limit(10)
          .snapshots()
          .map((querySnapshot) => querySnapshot.docs);
    } else {
      stream = FirebaseFirestore.instance
          .collection('products')
          .limit(10)
          .snapshots()
          .map((querySnapshot) => querySnapshot.docs);
    }

    return StreamBuilder<List<QueryDocumentSnapshot>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No products found.'));
        }

        final products = snapshot.data!.where((product) {
          final data = product.data() as Map<String, dynamic>;

          // First check stock
          if (data['stock'] <= 0) return false;

          // Then check search query if it exists
          if (searchQuery != null && searchQuery!.isNotEmpty) {
            final productName =
                data['productName']?.toString().toLowerCase() ?? '';
            return productName.contains(searchQuery!);
          }
          return true;
        }).toList();
        if (products.isEmpty) {
          return Center(child: Text('No products match your search.'));
        }
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: products.map((product) {
              final data = product.data() as Map<String, dynamic>;
              data['productId'] = product.id;

              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: GestureDetector(
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
                    width: cardWidth,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.15),
                          blurRadius: 3,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Container(
                              height: 100,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(12)),
                                image: data['imageUrl'] != null
                                    ? DecorationImage(
                                        image: NetworkImage(data['imageUrl']),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: data['imageUrl'] == null
                                  ? Center(
                                      child: Text(
                                        'No Image',
                                        style: GoogleFonts.poppins(
                                            color: Colors.grey),
                                      ),
                                    )
                                  : null,
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            data['productName'] ?? 'No name',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            '₱${data['price'].toString()}',
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                          child: Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 14),
                              SizedBox(width: 4),
                              Text((data['rating'] ?? 0.0).toStringAsFixed(1),
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold)),
                              SizedBox(width: 4),
                              Text('(${data['reviewsCount'] ?? 0})',
                                  style:
                                      GoogleFonts.poppins(color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;

  CategoryItem(
      {required this.icon, required this.label, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: isSelected ? Color(0xFF651D32) : Colors.grey[200],
          child: Icon(icon, color: isSelected ? Colors.white : Colors.black),
        ),
        SizedBox(height: 5),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }
}

class AdBanner extends StatelessWidget {
  final String imagePath;
  final double width;

  AdBanner({required this.imagePath, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width * 0.8,
      height: width > 600 ? 200 : 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

Future<void> _showNotificationsDialog(BuildContext context) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  // First mark all as read
  final notificationsQuery = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('notifications')
      .where('read', isEqualTo: false)
      .get();

  final batch = FirebaseFirestore.instance.batch();
  for (final doc in notificationsQuery.docs) {
    batch.update(doc.reference, {'read': true});
  }
  await batch.commit();

  // Then get all notifications
  final allNotificationsSnapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('notifications')
      .orderBy('timestamp', descending: true)
      .get();

  // Create a mutable list
  final List<QueryDocumentSnapshot> notificationDocs =
      allNotificationsSnapshot.docs.toList();

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.notifications, color: Color(0xFF651D32)),
                SizedBox(width: 10),
                Text('Notifications'),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: notificationDocs.isEmpty
                  ? Center(child: Text('No notifications'))
                  : ListView(
                      shrinkWrap: true,
                      children: notificationDocs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return Dismissible(
                          key: Key(doc.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.only(right: 20),
                            color: Colors.red,
                            child: Icon(Icons.delete, color: Colors.white),
                          ),
                          confirmDismiss: (direction) async {
                            return await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Delete Notification'),
                                content: Text(
                                    'Are you sure you want to delete this notification?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                          },
                          onDismissed: (direction) async {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .collection('notifications')
                                .doc(doc.id)
                                .delete();
                            setState(() {
                              notificationDocs
                                  .removeWhere((d) => d.id == doc.id);
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey.shade200,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                data['title'] ?? 'Notification',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 4),
                                  Text(
                                    data['message'] ?? '',
                                    style: GoogleFonts.poppins(),
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.access_time,
                                          size: 14, color: Colors.grey),
                                      SizedBox(width: 4),
                                      Text(
                                        data['timestamp'] != null
                                            ? DateFormat('MMM dd, hh:mm a')
                                                .format((data['timestamp']
                                                        as Timestamp)
                                                    .toDate())
                                            : '',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (data['orderId'] != null) ...[
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.receipt,
                                            size: 14, color: Colors.grey),
                                        SizedBox(width: 4),
                                        Text(
                                          'Order #${data['orderId']}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
              if (notificationDocs.isNotEmpty)
                TextButton(
                  onPressed: () async {
                    final confirm = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Clear All Notifications'),
                        content: Text(
                            'Are you sure you want to delete all notifications?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text('Delete All'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      final batch = FirebaseFirestore.instance.batch();
                      for (final doc in notificationDocs) {
                        batch.delete(doc.reference);
                      }
                      await batch.commit();
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    }
                  },
                  child: Text('Clear All'),
                ),
            ],
          );
        },
      );
    },
  );
}
