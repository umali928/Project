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
  final List<String> _statusOptions = ['Pending', 'Shipped', 'Delivered'];
  Map<String, dynamic>? order;
  bool isLoading = true;
  bool _isProductCancelled(Map<String, dynamic> product) {
    return product['status'] == 'cancelled' ||
        (product['cancelled'] != null && product['cancelled'] == true) ||
        (product['isCancelled'] != null && product['isCancelled'] == true);
  }

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
      case 'cancelled':
        return Colors.red;
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

  Widget _buildProductsSection(bool isSmallScreen) {
    final allProducts = (order?['items'] as List<dynamic>?) ?? [];
    final products = allProducts
        .where((product) => product['sellerId'] == widget.sellerId)
        .toList();

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'YOUR PRODUCTS',
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
              final productId = product['productId'];
              final currentStatus = product['status'] ?? 'Pending';
              final isDelivered = currentStatus == 'Delivered';
              final isCancelled = _isProductCancelled(product);

              // Force status to 'Cancelled' if product is cancelled
              final displayStatus = isCancelled ? 'cancelled' : currentStatus;
              final validStatus = _statusOptions.contains(displayStatus)
                  ? displayStatus
                  : 'Pending';

              return StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  String dropdownValue = validStatus;

                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                product['imageUrl'] ?? '',
                                width: isSmallScreen ? 50 : 70,
                                height: isSmallScreen ? 50 : 70,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(Icons.image,
                                        size: isSmallScreen ? 50 : 70),
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
                                      color: isCancelled ? Colors.grey : null,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Qty: ${product['quantity'] ?? 0}',
                                    style: GoogleFonts.poppins(
                                      color: isCancelled
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                      fontSize: isSmallScreen ? 12 : 14,
                                    ),
                                  ),
                                  if (isCancelled)
                                    Padding(
                                      padding: EdgeInsets.only(top: 4),
                                      child: Text(
                                        'Cancelled',
                                        style: GoogleFonts.poppins(
                                          color: Colors.red,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
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
                                color: isCancelled ? Colors.grey : null,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        // Show disabled text field if cancelled, otherwise show dropdown
                        if (isCancelled)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: Colors.grey,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Cancelled',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          AbsorbPointer(
                            absorbing: isDelivered,
                            child: DropdownButtonFormField<String>(
                              value: dropdownValue,
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
                              onChanged: (isDelivered || isCancelled)
                                  ? null
                                  : (newValue) async {
                                      if (newValue == null ||
                                          newValue == dropdownValue) {
                                        return;
                                      }

                                      final previousValue = dropdownValue;
                                      setState(() {
                                        dropdownValue = newValue;
                                      });

                                      final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text('Confirm Status Change'),
                                          content: Text(
                                              'Are you sure you want to change the status from $previousValue to $newValue?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(false),
                                              child: Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(true),
                                              child: Text('Confirm'),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirmed != true) {
                                        setState(() {
                                          dropdownValue = previousValue;
                                        });
                                        return;
                                      }

                                      try {
                                        final items =
                                            List.from(order?['items'] ?? []);
                                        final index = items.indexWhere((item) =>
                                            item['productId'] == productId &&
                                            item['sellerId'] ==
                                                widget.sellerId);

                                        if (index != -1) {
                                          if (items[index]['status'] ==
                                                  'Delivered' ||
                                              _isProductCancelled(
                                                  items[index])) {
                                            setState(() {
                                              dropdownValue =
                                                  items[index]['status'];
                                            });
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'This product cannot be modified'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                            return;
                                          }

                                          items[index]['status'] = newValue;
                                          await FirebaseFirestore.instance
                                              .collection('orders')
                                              .doc(widget.orderId)
                                              .update({'items': items});
                                          await _sendStatusChangeNotification(
                                            orderId: widget.orderId,
                                            productName:
                                                product['productName'] ??
                                                    'product',
                                            oldStatus: previousValue,
                                            newStatus: newValue,
                                            userId: order?['userId'],
                                          );

                                          if (mounted) {
                                            setState(() {
                                              order?['items'] = items;
                                            });
                                          }

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Status updated to $newValue'),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        setState(() {
                                          dropdownValue = previousValue;
                                        });
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Failed to update status: $e'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: Colors.grey[300]!),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                filled: true,
                                fillColor: (isDelivered || isCancelled)
                                    ? Colors.grey[200]
                                    : Colors.grey[50],
                                labelText: 'Product Status',
                                labelStyle: (isDelivered || isCancelled)
                                    ? TextStyle(color: Colors.grey[600])
                                    : null,
                              ),
                              dropdownColor: Colors.white,
                              style: TextStyle(
                                fontSize: 14,
                                color: (isDelivered || isCancelled)
                                    ? Colors.grey[600]
                                    : Colors.black,
                              ),
                            ),
                          ),
                        Divider(),
                      ],
                    ),
                  );
                },
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
    final sellerProducts = allProducts
        .where((product) => product['sellerId'] == widget.sellerId)
        .toList();

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
                  style: GoogleFonts.roboto(
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

Future<void> _sendStatusChangeNotification({
  required String orderId,
  required String productName,
  required String oldStatus,
  required String newStatus,
  required String? userId,
}) async {
  if (userId == null) return;

  try {
    // Create a notification document in the user's notifications collection
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .add({
      'type': 'order_status',
      'orderId': orderId,
      'productName': productName,
      'oldStatus': oldStatus,
      'newStatus': newStatus,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
      'title': 'Order Status Updated',
      'message':
          'Your order #$orderId for $productName has changed from $oldStatus to $newStatus',
    });
  } catch (e) {
    print('Error sending notification: $e');
  }
}
