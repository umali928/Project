import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login.dart';
import 'product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GuestDashboard(),
    );
  }
}

class GuestDashboard extends StatefulWidget {
  @override
  _GuestDashboardState createState() => _GuestDashboardState();
}

class _GuestDashboardState extends State<GuestDashboard> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [
      GuestHomeScreen(),
      GuestPlaceholderScreen(title: "Wishlist"),
      GuestPlaceholderScreen(title: "Shop"), // Changed to require login
      GuestPlaceholderScreen(title: "Login"),
    ];
  }

  void _onItemTapped(int index) {
    if (index != 0) {
      // Only Home is accessible without login
      _showLoginPrompt(context);
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _showLoginPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Login Required"),
        content: Text("Please login to access this feature."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            child: Text("Login"),
          ),
        ],
      ),
    );
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
          BottomNavigationBarItem(icon: Icon(Icons.login), label: "Login"),
        ],
      ),
    );
  }
}

class GuestHomeScreen extends StatefulWidget {
  @override
  _GuestHomeScreenState createState() => _GuestHomeScreenState();
}

class _GuestHomeScreenState extends State<GuestHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _searchQuery = '';
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
            Text("LSPU-MART (Guest)",
                style: GoogleFonts.poppins(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                )),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.bell, color: Colors.black),
            onPressed: () {
              _showLoginPrompt(context);
            },
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart, size: 28),
            onPressed: () {
              _showLoginPrompt(context);
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
                  GuestProductHorizontalList(
                    category:
                        _selectedCategory == 'All' ? null : _selectedCategory,
                    searchQuery: _searchQuery,
                    onActionRequiresLogin: () => _showLoginPrompt(context),
                  ),

                  SizedBox(height: 30),
                  Text("You May Also Like",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),

                  /// You May Also Like
                  GuestProductHorizontalList(
                    customStream: getRandomProducts(),
                    onActionRequiresLogin: () => _showLoginPrompt(context),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showLoginPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Login Required"),
        content: Text("Please login to access this feature."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            child: Text("Login"),
          ),
        ],
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

class GuestProductHorizontalList extends StatelessWidget {
  final Stream<List<QueryDocumentSnapshot>>? customStream;
  final String? category;
  final String? searchQuery;
  final VoidCallback onActionRequiresLogin;

  const GuestProductHorizontalList({
    Key? key,
    this.customStream,
    this.category,
    this.searchQuery,
    required this.onActionRequiresLogin,
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
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: onActionRequiresLogin,
                              ),
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

class GuestPlaceholderScreen extends StatelessWidget {
  final String title;

  const GuestPlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock, size: 50, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              "Login Required",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Please login to access $title",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: Text("Login"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF651D32),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
            ),
          ],
        ),
      ),
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
