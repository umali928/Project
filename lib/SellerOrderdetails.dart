import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'OrderManagement.dart';

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
  runApp(OrderManagementApp());
}

class OrderManagementApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Order Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.symmetric(vertical: 8),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: OrderManagementPage(),
    );
  }
}

class OrderDetailsPage extends StatefulWidget {
  final String orderId;
  final String sellerId; //
  final Map<String, dynamic>? orderData;

  const OrderDetailsPage({
    required this.orderId,
    required this.sellerId, // Add this
    this.orderData,
    Key? key,
  }) : super(key: key);

  @override
  _OrderDetailsPageState createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  String _selectedStatus = 'Pending';
  final List<String> _statusOptions = ['Pending', 'Shipped', 'Delivered'];
  Map<String, dynamic>? order;
  bool isLoading = true;
  // Add this method to fetch customer name
  Future<String> _getCustomerName() async {
    try {
      if (order?['customerName'] != null) {
        return order!['customerName'];
      }

      final userId = order?['userId'];
      if (userId == null) return 'Anonymous';

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      return userDoc.data()?['fullName'] ?? 'Anonymous';
    } catch (e) {
      print('Error fetching customer name: $e');
      return 'Anonymous';
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize with passed data if available
    if (widget.orderData != null) {
      order = widget.orderData;
      _selectedStatus = widget.orderData?['status'] ?? 'Pending';
      isLoading = false;
    }
    fetchOrderDetails();
  }

  Future<void> fetchOrderDetails() async {
    if (widget.orderData != null && !isLoading) return;

    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .get();

      if (docSnapshot.exists) {
        setState(() {
          order = docSnapshot.data();
          _selectedStatus = order?['status'] ?? 'Pending';
          isLoading = false;
        });
      } else {
        print('Order not found');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching order details: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Shipped':
        return Colors.blue;
      case 'Delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Order Details',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Center(
              child: Chip(
                label: Text(
                  _selectedStatus,
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                backgroundColor: _getStatusColor(_selectedStatus),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.save),
            tooltip: 'Save Changes',
            onPressed: () async {
              if (order == null) return;

              try {
                await FirebaseFirestore.instance
                    .collection('orders')
                    .doc(widget.orderId)
                    .update({'status': _selectedStatus});

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Order status updated to $_selectedStatus'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to update order status: $e'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: isLoading || order == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(isSmallScreen ? 12.0 : 24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 800,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOrderHeader(),
                    SizedBox(height: 16),
                    _buildStatusDropdown(),
                    SizedBox(height: 16),
                    _buildProductsSection(isSmallScreen),
                    SizedBox(height: 16),
                    _buildAddressSection(),
                    SizedBox(height: 16),
                    _buildPaymentSection(),
                    SizedBox(height: 16),
                    _buildOrderSummary(),
                  ],
                ),
              ),
            ),
    );
  }

  // Update the buildOrderHeader method as shown above
  Widget _buildOrderHeader() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Order #${order?['orderId'] ?? 'N/A'}',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.receipt, color: Color(0xFF651D32)),
              ],
            ),
            SizedBox(height: 8),
            Divider(),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  'Placed on ${_formatOrderDate(order?['orderDate'])}',
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.grey),
                SizedBox(width: 8),
                FutureBuilder<String>(
                  future: _getCustomerName(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text(
                        'Loading customer...',
                        style: GoogleFonts.poppins(fontSize: 16),
                      );
                    }
                    return Text(
                      'Customer: ${snapshot.data ?? 'Anonymous'}',
                      style: GoogleFonts.poppins(fontSize: 16),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'UPDATE ORDER STATUS',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              items: _statusOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _getStatusColor(value),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(value),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedStatus = newValue!;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              dropdownColor: Colors.white,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

 Widget _buildProductsSection(bool isSmallScreen) {
  // Filter products by sellerId
  final allProducts = (order?['items'] as List<dynamic>?) ?? [];
  final products = allProducts.where((product) => 
      product['sellerId'] == widget.sellerId).toList();

  return Card(
    child: Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YOUR PRODUCTS',  // Changed from 'PRODUCTS'
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 12),
          if (products.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'No products found for your store in this order',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
          ...products.map<Widget>((product) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product['imageUrl'] ?? '',
                      width: isSmallScreen ? 50 : 70,
                      height: isSmallScreen ? 50 : 70,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.image, size: isSmallScreen ? 50 : 70),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product['productName'] ?? 'Unknown product',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: isSmallScreen ? 14 : 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Qty: ${product['quantity'] ?? 0}',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[600],
                            fontSize: isSmallScreen ? 12 : 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₱${(product['price'] ?? 0).toStringAsFixed(2)}',
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    ),
  );
}

  Widget _buildAddressSection() {
    final address = order?['shippingAddress'] ?? {};
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DELIVERY ADDRESS',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 12),
            _buildAddressRow(Icons.home, 'Type', address['addressType'] ?? ''),
            _buildAddressRow(
                Icons.streetview, 'Street', address['street'] ?? ''),
            _buildAddressRow(
                Icons.location_city, 'Barangay', address['barangay'] ?? ''),
            _buildAddressRow(Icons.location_city, 'City/Municipality',
                address['cityOrMunicipality'] ?? ''),
            _buildAddressRow(Icons.map, 'Province', address['province'] ?? ''),
            _buildAddressRow(Icons.phone, 'Phone', address['phone'] ?? ''),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    final payment = order?['payment'] ?? {};
    final method = payment['method']?.toString().toLowerCase() ?? '';
    String details = '';
    IconData detailsIcon = Icons.info;

    if (method.contains('g-cash')) {
      details = payment['gcashPhone'] ?? payment['gcashPhone'] ?? 'N/A';
      detailsIcon = Icons.phone_android;
    } else if (method.contains('card')) {
      details = '•••• ${payment['cardLast4'] ?? '••••'}';
      detailsIcon = Icons.credit_card;
    } else if (method.contains('cash on delivery')) {
      details = 'No details available';
      detailsIcon = Icons.money;
    } else {
      details = payment['details'] ?? '';
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PAYMENT METHOD',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 12),
            _buildAddressRow(
                Icons.payment,
                'Method',
                method.isNotEmpty
                    ? method[0].toUpperCase() + method.substring(1)
                    : 'Unknown'),
            _buildAddressRow(detailsIcon, 'Details', details),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
  // Calculate totals only for seller's products
  final allProducts = (order?['items'] as List<dynamic>?) ?? [];
  final sellerProducts = allProducts.where((product) => 
      product['sellerId'] == widget.sellerId).toList();
  
  double subtotal = sellerProducts.fold(0, (sum, product) {
    return sum + ((product['price'] ?? 0) * (product['quantity'] ?? 1));
  });
  

  double total = subtotal;

  return Card(
    child: Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          SizedBox(height: 8),
          Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Total',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                '₱${total.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF651D32),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

String _formatOrderDate(dynamic date) {
  if (date == null) return 'Unknown date';

  try {
    DateTime dateTime;

    if (date is Timestamp) {
      dateTime = date.toDate();
    } else if (date is String) {
      // Try parsing if it's an ISO string
      dateTime = DateTime.parse(date);
    } else if (date is DateTime) {
      dateTime = date;
    } else {
      return 'Unknown date';
    }

    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
  } catch (e) {
    print('Error formatting date: $e');
    return 'Unknown date';
  }
}
}