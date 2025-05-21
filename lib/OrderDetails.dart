import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class OrderDetailsPage extends StatefulWidget {
  final String orderId;
  final Map<String, dynamic> orderData;

  const OrderDetailsPage({
    Key? key,
    required this.orderId,
    required this.orderData,
  }) : super(key: key);

  @override
  _OrderDetailsPageState createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  late Map<String, dynamic> _orderData;

  @override
  void initState() {
    super.initState();
    _orderData = widget.orderData;
  }

  // Calculate subtotal from non-cancelled items
  double _calculateSubtotal(List<dynamic> items) {
    return items.fold<double>(0, (sum, item) {
      // Only include non-cancelled items in the subtotal
      if (item['status']?.toString().toLowerCase() != 'cancelled') {
        return sum + (item['price'] * item['quantity']);
      }
      return sum;
    });
  }

  // Calculate shipping as 5% of subtotal
  double _calculateShipping(double subtotal) {
    return subtotal * 0.05;
  }

  // Calculate total as subtotal + shipping
  double _calculateTotal(double subtotal, double shipping) {
    return subtotal + shipping;
  }

  Future<void> _cancelProduct(dynamic item, int index) async {
    final status = item['status']?.toString().toLowerCase() ?? '';

    // Check if product can be cancelled
    if (status == 'shipped' || status == 'delivered') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot cancel product that is already $status'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if already cancelled
    if (status == 'cancelled') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('This product is already cancelled'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Confirm cancellation with user
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Confirm Cancellation'),
            content: Text('Are you sure you want to cancel this product?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;

    try {
      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();

      // 1. Update the product status in the order
      final orderRef = firestore.collection('orders').doc(widget.orderId);
      final items = List<dynamic>.from(_orderData['items']);
      items[index] = {
        ...item,
        'status': 'cancelled',
      };

      batch.update(orderRef, {'items': items});

      // 2. Return quantity to stock
      final productRef =
          firestore.collection('products').doc(item['productId']);
      batch.update(productRef, {
        'stock': FieldValue.increment(item['quantity']),
      });
      // 3. Process refund if payment wasn't Cash on Delivery
      final payment = _orderData['payment'] as Map<String, dynamic>?;
      final paymentMethod = payment?['method'] as String?;
      final paymentMethodId = payment?['paymentMethodId'] as String?;
      final amountToRefund =
          (item['price'] as num).toDouble() * (item['quantity'] as int);
      final shippingFee = _calculateShipping(item['price'] * item['quantity']);
      final totalRefundAmount = amountToRefund + shippingFee;

      if (paymentMethod != null &&
          paymentMethod != 'Cash On Delivery' &&
          paymentMethodId != null) {
        // Refund to payment method
        final paymentMethodRef = firestore
            .collection('users')
            .doc(_orderData['userId'])
            .collection('paymentMethods')
            .doc(paymentMethodId);

        // Get current amount - use transaction to ensure atomic update
        await firestore.runTransaction((transaction) async {
          final paymentDoc = await transaction.get(paymentMethodRef);
          if (!paymentDoc.exists) {
            throw Exception('Payment method not found');
          }

          final currentAmount = (paymentDoc['amount'] as num).toDouble();
          final newAmount = currentAmount + totalRefundAmount;

          // Update payment method with refund
          transaction.update(paymentMethodRef, {
            'amount': newAmount,
            'lastUsed': FieldValue.serverTimestamp(),
          });

          // Record refund transaction for product
          final productTransactionRef = firestore
              .collection('users')
              .doc(_orderData['userId'])
              .collection('transactions')
              .doc();

          transaction.set(productTransactionRef, {
            'type': 'refund',
            'amount': amountToRefund,
            'paymentMethod': paymentMethod,
            'paymentMethodId': paymentMethodId,
            'date': FieldValue.serverTimestamp(),
            'orderId': widget.orderId,
            'productId': item['productId'],
            'description':
                'Refund for cancelled product: ${item['productName']}',
            'balanceAfter': newAmount,
          });

          // Record refund transaction for shipping fee
          final shippingTransactionRef = firestore
              .collection('users')
              .doc(_orderData['userId'])
              .collection('transactions')
              .doc();

          transaction.set(shippingTransactionRef, {
            'type': 'refund',
            'amount': shippingFee,
            'paymentMethod': paymentMethod,
            'paymentMethodId': paymentMethodId,
            'date': FieldValue.serverTimestamp(),
            'orderId': widget.orderId,
            'description':
                'Refund of shipping fee for cancelled product: ${item['productName']}',
            'balanceAfter': newAmount,
          });
        });
      }

      await batch.commit();

      // Update local state to trigger UI rebuild
      setState(() {
        _orderData = {
          ..._orderData,
          'items': items,
        };
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Product cancelled successfully${paymentMethod != 'Cash On Delivery' ? ' and amount refunded' : ''}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to cancel product: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final padding = isSmallScreen ? screenWidth * 0.04 : screenWidth * 0.06;
    final textScale = isSmallScreen ? screenWidth / 400 : screenWidth / 700;

    final items = _orderData['items'] as List<dynamic>;
    final subtotal = _calculateSubtotal(items);
    final shipping = _calculateShipping(subtotal);
    final total = _calculateTotal(subtotal, shipping);
    final orderDate = (_orderData['orderDate'] as Timestamp).toDate();
    final formattedDate =
        DateFormat('MMMM dd, yyyy - hh:mm a').format(orderDate);
    final shippingAddress =
        _orderData['shippingAddress'] as Map<String, dynamic>?;
    final payment = _orderData['payment'] as Map<String, dynamic>?;

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
                    "Order #${widget.orderId.substring(0, 8)}",
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
                return _buildOrderItemCard(context, item, textScale, index);
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
                    value: '\u20B1${subtotal.toStringAsFixed(2)}',
                  ),
                  SizedBox(height: 8 * textScale),
                  _buildSummaryRow(
                    context,
                    label: 'Shipping',
                    value: '\u20B1${shipping.toStringAsFixed(2)}',
                  ),
                  Divider(
                    color: theme.dividerColor,
                    thickness: 1,
                    height: 24 * textScale,
                  ),
                  _buildSummaryRow(
                    context,
                    label: 'Total',
                    value: '\u20B1${total.toStringAsFixed(2)}',
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
      BuildContext context, dynamic item, double textScale, int index) {
    final theme = Theme.of(context);
    final status = item['status']?.toString().toLowerCase() ?? '';

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
            SizedBox(height: 8),
            // Cancel button (only show if not shipped/delivered and not already cancelled)
            if (status != 'shipped' &&
                status != 'delivered' &&
                status != 'cancelled')
              SizedBox(
                width: double.infinity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.red.shade400, Colors.red.shade700],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.15),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side:
                            BorderSide(color: Colors.red.shade700, width: 1.2),
                      ),
                    ),
                    icon: Icon(Icons.cancel, color: Colors.white),
                    label: Text(
                      'Cancel Product',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 15 * textScale,
                        letterSpacing: 0.2,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () => _cancelProduct(item, index),
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
      case "cancelled":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
