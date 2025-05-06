import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
void main() {
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
      home: OrderDetailsPage(),
    );
  }
}

class OrderDetailsPage extends StatefulWidget {
  @override
  _OrderDetailsPageState createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  String _selectedStatus = 'Pending';
  final List<String> _statusOptions = ['Pending', 'Shipped', 'Delivered'];

  // Sample order data
  final Map<String, dynamic> order = {
    'orderId': '#ORD-12345',
    'date': 'May 15, 2023',
    'customerName': 'John Doe',
    'products': [
      {
        'image': 'https://via.placeholder.com/150',
        'name': 'Wireless Headphones',
        'price': 99.99,
        'quantity': 1,
      },
      {
        'image': 'https://via.placeholder.com/150',
        'name': 'Smart Watch',
        'price': 199.99,
        'quantity': 2,
      },
    ],
    'address': {
      'type': 'Home',
      'street': '123 Main Street',
      'barangay': 'Barangay 1',
      'city': 'Manila',
      'province': 'Metro Manila',
      'phone': '09123456789',
    },
    'payment': {
      'method': 'Credit Card',
      'details': 'Visa ending in 1234',
    },
    'total': 499.97,
  };

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
        title: Text('Order Details', style:  GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: const Color.fromARGB(255, 0, 0, 0),
        
        ),),
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
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Order status updated to $_selectedStatus'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                Text(
                  'Order ${order['orderId']}',
                  style:  GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
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
                  'Placed on ${order['date']}',
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  'Customer: ${order['customerName']}',
                  style: GoogleFonts.poppins(fontSize: 16),
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
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PRODUCTS',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 12),
            ...order['products'].map<Widget>((product) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        product['image'],
                        width: isSmallScreen ? 50 : 70,
                        height: isSmallScreen ? 50 : 70,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product['name'],
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: isSmallScreen ? 14 : 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Qty: ${product['quantity']}',
                            style: GoogleFonts.poppins(
                              color: Colors.grey[600],
                              fontSize: isSmallScreen ? 12 : 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '₱${product['price'].toStringAsFixed(2)}',
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
    final address = order['address'];
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
            _buildAddressRow(Icons.home, 'Type', address['type']),
            _buildAddressRow(Icons.streetview, 'Street', address['street']),
            _buildAddressRow(Icons.location_city, 'Barangay', address['barangay']),
            _buildAddressRow(Icons.location_city, 'City/Municipality', address['city']),
            _buildAddressRow(Icons.map, 'Province', address['province']),
            _buildAddressRow(Icons.phone, 'Phone', address['phone']),
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
    final payment = order['payment'];
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
            _buildAddressRow(Icons.credit_card, 'Method', payment['method']),
            _buildAddressRow(Icons.info, 'Details', payment['details']),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal',
                  style: GoogleFonts.poppins(color: Colors.grey[600]),
                ),
                Text(
                  '\$${(order['total'] * 0.9).toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Shipping',
                  style: GoogleFonts.poppins(color: Colors.grey[600]),
                ),
                Text(
                  '\$${(order['total'] * 0.1).toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '\$${order['total'].toStringAsFixed(2)}',
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
}