import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lspu/wishlist.dart';
import 'dashboard.dart';
import 'profile.dart';
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
      home: MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 2;
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
  String _searchQuery = '';
  String _selectedCategory = 'All';
  double _minPrice = 0;
  double _maxPrice = double.infinity;
  int _minRating = 0;

  void _applyFilters({
    String? category,
    double? minPrice,
    double? maxPrice,
    int? minRating,
    bool reset = false, // Add this parameter
  }) {
    setState(() {
      if (reset) {
        _selectedCategory = 'All';
        _minPrice = 0;
        _maxPrice = double.infinity;
        _minRating = 0;
      } else {
        _selectedCategory = category ?? _selectedCategory;
        _minPrice = minPrice ?? _minPrice;
        _maxPrice = maxPrice ?? _maxPrice;
        _minRating = minRating ?? _minRating;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Add this to your SearchPage's Scaffold (alongside body)
      floatingActionButton: (_searchQuery.isNotEmpty ||
              _selectedCategory != 'All' ||
              _minPrice != 0 ||
              _maxPrice != double.infinity ||
              _minRating != 0)
          ? FloatingActionButton(
              backgroundColor: Color(0xFF651D32),
              child: Icon(Icons.refresh, color: Colors.white),
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _selectedCategory = 'All';
                  _minPrice = 0;
                  _maxPrice = double.infinity;
                  _minRating = 0;
                });
              },
            )
          : null,
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
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Search for products...",
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search, size: 28),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, size: 20),
                              onPressed: () {
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
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
                        isScrollControlled: true,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(16)),
                        ), // <-- Closing parenthesis for `shape` was misplaced
                        builder: (context) {
                          return FilterBottomSheet(
                            currentCategory: _selectedCategory,
                            currentMinPrice: _minPrice,
                            currentMaxPrice: _maxPrice,
                            currentMinRating: _minRating,
                            onApplyFilters: _applyFilters,
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
        child: ProductVerticalList(
          searchQuery: _searchQuery,
          category: _selectedCategory,
          minPrice: _minPrice,
          maxPrice: _maxPrice,
          minRating: _minRating,
        ),
      ),
    );
  }
}

class FilterBottomSheet extends StatefulWidget {
  final String currentCategory;
  final double currentMinPrice;
  final double currentMaxPrice;
  final int currentMinRating;
  final Function({
    String? category,
    double? minPrice,
    double? maxPrice,
    int? minRating,
  }) onApplyFilters;

  const FilterBottomSheet({
    required this.currentCategory,
    required this.currentMinPrice,
    required this.currentMaxPrice,
    required this.currentMinRating,
    required this.onApplyFilters,
  });

  @override
  _FilterBottomSheetState createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String _selectedCategory;
  late double _minPrice;
  late double _maxPrice;
  late int _selectedRating;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.currentCategory;
    _minPrice = widget.currentMinPrice;
    _maxPrice = widget.currentMaxPrice;
    _selectedRating = widget.currentMinRating;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text('Filter Options',
                    style: GoogleFonts.poppins(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                Text('Category',
                    style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.w500)),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChip(
                      label: Text('Clothes'),
                      selected: _selectedCategory == 'Clothes',
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = selected ? 'Clothes' : 'All';
                        });
                      },
                    ),
                    FilterChip(
                      label: Text('School'),
                      selected: _selectedCategory == 'School',
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = selected ? 'School' : 'All';
                        });
                      },
                    ),
                    FilterChip(
                      label: Text('Sports'),
                      selected: _selectedCategory == 'Sports',
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = selected ? 'Sports' : 'All';
                        });
                      },
                    ),
                    FilterChip(
                      label: Text('Foods'),
                      selected: _selectedCategory == 'Foods',
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = selected ? 'Foods' : 'All';
                        });
                      },
                    ),
                    FilterChip(
                      label: Text('All'),
                      selected: _selectedCategory == 'All',
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = 'All';
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text('Price Range',
                    style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.w500)),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Min Price',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          _minPrice = double.tryParse(value) ?? 0;
                        },
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Max Price',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          _maxPrice = double.tryParse(value) ?? double.infinity;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text('Minimum Rating',
                    style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.w500)),
                Row(
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        Icons.star,
                        color: index < _selectedRating
                            ? Colors.amber
                            : Colors.grey,
                        size: 30,
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedRating = index + 1;
                        });
                      },
                    );
                  }),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Reset Filters Button
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedCategory = 'All';
                          _minPrice = 0;
                          _maxPrice = double.infinity;
                          _selectedRating = 0;
                        });
                      },
                      style: TextButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: Colors.grey[100],
                      ),
                      child: Text(
                        'Reset Filters',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),

                    SizedBox(width: 24), // Spacing between buttons

                    // Apply Filters Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF651D32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                      onPressed: () {
                        widget.onApplyFilters(
                          category: _selectedCategory,
                          minPrice: _minPrice,
                          maxPrice: _maxPrice,
                          minRating: _selectedRating,
                        );
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Apply Filters',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProductVerticalList extends StatefulWidget {
  final String searchQuery;
  final String category;
  final double minPrice;
  final double maxPrice;
  final int minRating;

  const ProductVerticalList({
    Key? key,
    this.searchQuery = '',
    this.category = 'All',
    this.minPrice = 0,
    this.maxPrice = double.infinity,
    this.minRating = 0,
  }) : super(key: key);

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

        final products = snapshot.data!.docs.where((product) {
          final data = product.data() as Map<String, dynamic>;

          // Filter by stock
          if (data['stock'] <= 0) return false;

          // Filter by search query
          if (widget.searchQuery.isNotEmpty) {
            final productName =
                data['productName']?.toString().toLowerCase() ?? '';
            if (!productName.contains(widget.searchQuery)) {
              return false;
            }
          }

          // Filter by category
          if (widget.category != 'All') {
            final productCategory = data['category']?.toString() ?? '';
            if (productCategory != widget.category) {
              return false;
            }
          }

          // Filter by price range
          final price = data['price']?.toDouble() ?? 0.0;
          if (price < widget.minPrice || price > widget.maxPrice) {
            return false;
          }

          // Filter by rating
          final rating = data['rating']?.toDouble() ?? 0.0;
          if (rating < widget.minRating) {
            return false;
          }

          return true;
        }).toList();

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

            return products.isEmpty
                ? Center(child: Text('No products match your filters'))
                : GridView.builder(
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
                                            style:
                                                TextStyle(color: Colors.grey)),
                                      )
                                    : null,
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                            (data['rating'] ?? 0.0)
                                                .toStringAsFixed(1),
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '(${data['reviewsCount'] ?? 0})',
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
  bool? isWishlisted;
  bool loading = true;
  bool isAnimating = false;

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

  Future<void> toggleWishlist() async {
    if (loading) return;

    setState(() {
      isAnimating = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Show login prompt if user is not logged in
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please login to manage your wishlist'),
          action: SnackBarAction(
            label: 'Login',
            onPressed: () {
              // Add your login navigation here
            },
          ),
        ),
      );
      setState(() {
        isAnimating = false;
      });
      return;
    }

    final productId = widget.data['productId'];
    final wishlistRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('wishlist');

    try {
      if (isWishlisted == false) {
        await wishlistRef.add({
          'productId': productId,
          'productName': widget.data['productName'],
          'price': widget.data['price'],
          'imageUrl': widget.data['imageUrl'],
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Show success feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added to wishlist'),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else {
        final snapshot =
            await wishlistRef.where('productId', isEqualTo: productId).get();

        for (var doc in snapshot.docs) {
          await wishlistRef.doc(doc.id).delete();
        }

        // Show removal feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed from wishlist'),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }

      setState(() {
        isWishlisted = !isWishlisted!;
        WishlistButton.updateWishlistState(productId, isWishlisted!);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update wishlist'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isAnimating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading || isWishlisted == null) {
      return SizedBox(
        height: 36,
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF651D32)),
          ),
        ),
      );
    }

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isWishlisted! ? Colors.grey[100] : Color(0xFF651D32),
        border: Border.all(
          color: isWishlisted! ? Colors.grey[300]! : Color(0xFF651D32),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: toggleWishlist,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isAnimating)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          isWishlisted! ? Colors.black : Colors.white),
                    ),
                  )
                else
                  Icon(
                    isWishlisted! ? Icons.favorite : Icons.favorite_border,
                    size: 16,
                    color: isWishlisted! ? Colors.red : Colors.white,
                  ),
                SizedBox(width: 8),
                Text(
                  isWishlisted! ? 'Saved' : 'Save',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isWishlisted! ? Colors.black87 : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
