import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class OrderDetailsPage extends StatelessWidget {
  final String orderId;
  final Map<String, dynamic> orderData;

  const OrderDetailsPage({
    Key? key,
    required this.orderId,
    required this.orderData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final padding = isSmallScreen ? screenWidth * 0.04 : screenWidth * 0.06;
    final textScale = isSmallScreen ? screenWidth / 400 : screenWidth / 700;

    final items = orderData['items'] as List<dynamic>;
    final total = items.fold<double>(
        0, (sum, item) => sum + (item['price'] * item['quantity']));
    final orderDate = (orderData['orderDate'] as Timestamp).toDate();
    final formattedDate =
        DateFormat('MMMM dd, yyyy - hh:mm a').format(orderDate);
    final shippingAddress =
        orderData['shippingAddress'] as Map<String, dynamic>?;
    final payment = orderData['payment'] as Map<String, dynamic>?;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Order Details",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            )),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary Card
            _buildSectionCard(
              context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Order #${orderId.substring(0, 8)}",
                    style: GoogleFonts.poppins(
                      fontSize: 18 * textScale,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF800000),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 12 * textScale),
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 16 * textScale,
                          color: theme.colorScheme.secondary),
                      SizedBox(width: 8 * textScale),
                      Text(
                        formattedDate,
                        style: GoogleFonts.poppins(
                            fontSize: 14 * textScale,
                            color:
                                theme.colorScheme.onSurface.withOpacity(0.7)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: padding),

            // Shipping Address
            if (shippingAddress != null) ...[
              _buildSectionTitle(context, 'Shipping Address'),
              SizedBox(height: 8 * textScale),
              _buildSectionCard(
                context,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(
                      context,
                      icon: Icons.location_on,
                      label: 'Address Type',
                      value: shippingAddress['addressType'] ?? '',
                    ),
                    _buildInfoRow(
                      context,
                      icon: Icons.home,
                      label: 'Street',
                      value: shippingAddress['street'] ?? '',
                    ),
                    _buildInfoRow(
                      context,
                      icon: Icons.map,
                      label: 'Barangay',
                      value: shippingAddress['barangay'] ?? '',
                    ),
                    _buildInfoRow(
                      context,
                      icon: Icons.location_city,
                      label: 'City/Municipality',
                      value: shippingAddress['cityOrMunicipality'] ?? '',
                    ),
                    _buildInfoRow(
                      context,
                      icon: Icons.terrain,
                      label: 'Province',
                      value: shippingAddress['province'] ?? '',
                    ),
                    _buildInfoRow(
                      context,
                      icon: Icons.phone,
                      label: 'Phone',
                      value: shippingAddress['phone'] ?? '',
                    ),
                  ],
                ),
              ),
              SizedBox(height: padding),
            ],

            // Payment Information
            if (payment != null) ...[
              _buildSectionTitle(context, 'Payment Information'),
              SizedBox(height: 8 * textScale),
              _buildSectionCard(
                context,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(
                      context,
                      icon: Icons.payment,
                      label: 'Method',
                      value: payment['method'] ?? 'N/A',
                    ),
                    if (payment['gcashPhone'] != null)
                      _buildInfoRow(
                        context,
                        icon: Icons.phone_android,
                        label: 'GCash Number',
                        value: payment['gcashPhone'],
                      ),
                    if (payment['cardLast4'] != null)
                      _buildInfoRow(
                        context,
                        icon: Icons.credit_card,
                        label: 'Card Ending',
                        value: '•••• ${payment['cardLast4']}',
                      ),
                  ],
                ),
              ),
              SizedBox(height: padding),
            ],

            // Order Items
            _buildSectionTitle(context, 'Order Items'),
            SizedBox(height: 8 * textScale),
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return _buildOrderItemCard(context, item, textScale);
              },
            ),
            SizedBox(height: padding),

            // Order Summary
            _buildSectionCard(
              context,
              child: Column(
                children: [
                  _buildSummaryRow(
                    context,
                    label: 'Subtotal',
                    value: '\u20B1${total.toStringAsFixed(2)}',
                  ),
                  SizedBox(height: 8 * textScale),
                  _buildSummaryRow(
                    context,
                    label: 'Shipping',
                    value:
                        '\u20B1${(total * 0.05).toStringAsFixed(2)}', // Changed to 5% of total
                  ),
                  Divider(
                    color: theme.dividerColor,
                    thickness: 1,
                    height: 24 * textScale,
                  ),
                  _buildSummaryRow(
                    context,
                    label: 'Total',
                    value:
                        '\u20B1${(total * 1.05).toStringAsFixed(2)}', // Changed to total + 5%
                    isTotal: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, {required Widget child}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.secondary),
          SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              SizedBox(height: 2),
              Text(
                value.isNotEmpty ? value : 'Not provided',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemCard(
      BuildContext context, dynamic item, double textScale) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.dividerColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: theme.colorScheme.surfaceVariant,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: item['imageUrl'] != null
                        ? Image.network(
                            item['imageUrl'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                                Icons.broken_image,
                                size: 30,
                                color: theme.colorScheme.error),
                          )
                        : Icon(Icons.image,
                            size: 30, color: theme.colorScheme.secondary),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['productName'] ?? 'Unknown Product',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Quantity: ${item['quantity']}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '\u20B1${item['price']}',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF800000),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            // Product status indicator
            if (item['status'] != null)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(item['status'] ?? 'Pending')
                      .withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getStatusColor(item['status'] ?? 'Pending'),
                    width: 1,
                  ),
                ),
                child: Text(
                  'Status: ${item['status'] ?? 'Pending'}',
                  style: GoogleFonts.poppins(
                    color: _getStatusColor(item['status'] ?? 'Pending'),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context, {
    required String label,
    required String value,
    bool isTotal = false,
  }) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            color: isTotal
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.roboto(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            color: isTotal
                ? Color(0xFF800000)
                : theme.colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "delivered":
        return Colors.green;
      case "shipped":
        return Colors.blue;
      case "pending":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
