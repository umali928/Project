import 'package:flutter/material.dart';
import 'package:lspu/wishlist.dart';
import 'dashboard.dart'; // Import DashboardScreen
import 'profile.dart'; // Import ProfileScreen
import 'product.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
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

// Main Navigation with BottomNavigationBar
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 2;

  final List<Widget> _pages = [
    HomeScreen(),
    WishlistScreen(),
    SearchPage(),
    SettingsPage(),
  ];

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
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(80),
          child: Column(
            children: [
              AppBar(
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
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        builder: (context) {
                          return Padding(
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
                                Text(
                                  'Filter Options',
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Category',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Wrap(
                                  spacing: 16, // Add more spacing between chips
                                  runSpacing:
                                      8, // Add vertical spacing between rows
                                  children: [
                                    FilterChip(
                                      label: Text('Clothes'),
                                      onSelected: (bool value) {},
                                    ),
                                    FilterChip(
                                      label: Text('School'),
                                      onSelected: (bool value) {},
                                    ),
                                    FilterChip(
                                      label: Text('Sports'),
                                      onSelected: (bool value) {},
                                    ),
                                    FilterChip(
                                      label: Text('Food'),
                                      onSelected: (bool value) {},
                                    ),
                                    FilterChip(
                                      label: Text('All'),
                                      onSelected: (bool value) {},
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Price Range',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
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
                                          // Handle min price input
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: TextField(
                                        decoration: InputDecoration(
                                          labelText: 'Max Price',
                                          border: OutlineInputBorder(),
                                        ),
                                        keyboardType: TextInputType.number,
                                        onChanged: (value) {
                                          // Handle max price input
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Ratings',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Row(
                                  children: List.generate(5, (index) {
                                    return IconButton(
                                      icon: Icon(
                                        Icons.star,
                                        color: index < 4
                                            ? Colors.amber
                                            : Colors.grey,
                                      ),
                                      onPressed: () {
                                        // Handle rating selection
                                      },
                                    );
                                  }),
                                ),
                                SizedBox(height: 16),
                                Center(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF651D32),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 32, vertical: 12),
                                    ),
                                    onPressed: () {
                                      // Apply filter logic
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
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                  Stack(
                    children: [
                      IconButton(
                        icon: Icon(Icons.shopping_cart, size: 28),
                        onPressed: () {
                          // Navigate to cart
                        },
                      ),
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
                            '2', // Placeholder for cart count
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                width: double.infinity,
                height: 1,
                color: Colors.grey,
              ),
            ],
          ),
        ),
        body: Expanded(
          child: ProductVerticalList(),
        ));
  }
}

class ProductVerticalList extends StatelessWidget {
  const ProductVerticalList({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    // Adjust crossAxisCount based on screen width
    int crossAxisCount = 2;
    if (screenWidth >= 600 && screenWidth < 900) {
      crossAxisCount = 3;
    } else if (screenWidth >= 900) {
      crossAxisCount = 4;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          itemCount: 10,
          padding: const EdgeInsets.all(12),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 12,
            childAspectRatio: 0.68,
          ),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProductDetailPage()),
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
                    Stack(
                      children: [
                        Container(
                          height: constraints.maxWidth < 600
                              ? constraints.maxWidth * 0.4
                              : constraints.maxWidth * 0.26,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                          ),
                          child: const Center(
                            child: Text('Image',
                                style: TextStyle(color: Colors.grey)),
                          ),
                        ),
                        const Positioned(
                          top: 8,
                          right: 8,
                          child:
                              Icon(Icons.favorite_border, color: Colors.red),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Product Name',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '₱68',
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.star,
                                    color: Colors.amber, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  '4.8',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '(692)',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
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
  }
}

