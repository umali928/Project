import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dashboard.dart';

class OrderConfirmationScreen extends StatefulWidget {
  final String addressId;
  final String paymentMethod;
  final String? gcashPhone;
  final String? cardLast4;
  final double totalAmount;
  final String? paymentMethodId;

  const OrderConfirmationScreen({
    super.key,
    required this.addressId,
    required this.paymentMethod,
    this.gcashPhone,
    this.cardLast4,
    required this.totalAmount,
    this.paymentMethodId,
  });

  @override
  State<OrderConfirmationScreen> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  final user = FirebaseAuth.instance.currentUser;
  late Future<List<Map<String, dynamic>>> cartItemsFuture;
  late Future<Map<String, dynamic>> addressFuture;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    cartItemsFuture = fetchCartItems();
    addressFuture = fetchAddress();
  }

  double calculateSubtotal(List<Map<String, dynamic>> cartItems) {
    return cartItems.fold(
        0.0, (sum, item) => sum + (item['price'] * item['quantity']));
  }

  Future<List<Map<String, dynamic>>> fetchCartItems() async {
    final cartSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('cart')
        .get();

    List<Map<String, dynamic>> items = [];

    for (var doc in cartSnapshot.docs) {
      final data = doc.data();
      final productSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(data['productId'])
          .get();

      if (productSnapshot.exists) {
        final productData = productSnapshot.data()!;
        items.add({
          'name': productData['productName'],
          'image': productData['imageUrl'],
          'quantity': data['quantity'],
          'price': productData['price'],
        });
      }
    }
    return items;
  }

  Future<Map<String, dynamic>> fetchAddress() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('addresses')
        .doc(widget.addressId)
        .get();

    return doc.data()!;
  }

  Future<void> _processPaymentDeduction(String orderId) async {
    if (widget.paymentMethod == 'Cash On Delivery') {
      print('No deduction needed for Cash on Delivery');
      return;
    }
    if (widget.paymentMethodId == null) {
      print('Payment method ID is null - cannot process deduction');
      throw Exception('Payment method not selected properly');
    }
    print('Starting payment deduction for method: ${widget.paymentMethodId}');
    print('Amount to deduct: ${widget.totalAmount}');
    try {
      final paymentMethodRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('paymentMethods')
          .doc(widget.paymentMethodId);
      print('Payment method path: ${paymentMethodRef.path}');

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // Get the current document
        print('Transaction started');
        final doc = await transaction.get(paymentMethodRef);
        if (!doc.exists) {
          print('Payment method document not found');
          throw Exception('Payment method not found');
        }
        print('Document data: ${doc.data()}');
        final currentAmount =
            (doc.data()?['amount'] as num?)?.toDouble() ?? 0.0;
        final newAmount = currentAmount - widget.totalAmount;
        print('Current amount: $currentAmount');
        print('New amount after deduction: $newAmount');
        if (newAmount < 0) {
          print('Insufficient funds');
          throw Exception('Insufficient funds in payment method');
        }

        // Update the payment method amount
        transaction.update(paymentMethodRef, {
          'amount': newAmount.toDouble(),
          'lastUsed': FieldValue.serverTimestamp(),
        });

        // Record transaction
        final transactionRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .collection('transactions')
            .doc();

        transaction.set(transactionRef, {
          'type': 'payment',
          'amount': widget.totalAmount,
          'paymentMethod': widget.paymentMethod,
          'paymentMethodId': widget.paymentMethodId,
          'date': FieldValue.serverTimestamp(),
          'orderId': orderId,
          'description': 'Payment for order',
          'balanceAfter': newAmount,
        });
        print('Current amount: $currentAmount');
        print('Deducting: ${widget.totalAmount}');
        print('New amount: $newAmount');
        return newAmount;
      });
    } catch (e) {
      print('Error deducting payment: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Order Confirmation",
            style:
                GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: FutureBuilder(
        future: Future.wait([cartItemsFuture, addressFuture]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final cartItems = snapshot.data![0] as List<Map<String, dynamic>>;
          final address = snapshot.data![1] as Map<String, dynamic>;

          final subtotal = calculateSubtotal(cartItems);
          final deliveryFee = subtotal * 0.05;

          return Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Cart Items",
                            style: GoogleFonts.poppins(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        ...cartItems.map((item) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Image.network(item['image'],
                                  width: 50, height: 50, fit: BoxFit.cover),
                              title: Text(item['name'],
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                              subtitle: Text("Qty: ${item['quantity']}",
                                  style: GoogleFonts.poppins(fontSize: 13)),
                              trailing: Text(
                                "₱${(item['price'] as num).toStringAsFixed(2)}",
                                style: GoogleFonts.roboto(fontSize: 14),
                              ),
                            )),
                        SizedBox(height: 16),
                        Text("Shipping Address",
                            style: GoogleFonts.poppins(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          child: Card(
                            color: Colors.grey[100],
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      "Address Type: ${address['addressType']}",
                                      style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(height: 4),
                                  Text("Street: ${address['street']}",
                                      style: GoogleFonts.poppins(fontSize: 15)),
                                  Text("Barangay: ${address['barangay']}",
                                      style: GoogleFonts.poppins(fontSize: 15)),
                                  Text(
                                      "City/Municipality: ${address['cityOrMunicipality']}",
                                      style: GoogleFonts.poppins(fontSize: 15)),
                                  Text("Province: ${address['province']}",
                                      style: GoogleFonts.poppins(fontSize: 15)),
                                  Text("Phone: ${address['phone']}",
                                      style: GoogleFonts.poppins(fontSize: 15)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text("Payment Method",
                            style: GoogleFonts.poppins(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 6),
                        Card(
                          color: Colors.grey[100],
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          child: ListTile(
                            leading: Icon(Icons.payment, color: Colors.black87),
                            title: Text(widget.paymentMethod,
                                style: GoogleFonts.poppins(fontSize: 14)),
                            subtitle: widget.paymentMethod == "G-Cash"
                                ? Text("Number: ${widget.gcashPhone}")
                                : widget.paymentMethod == "Credit/Debit Card"
                                    ? Text(
                                        "Card ending in: ${widget.cardLast4}")
                                    : null,
                          ),
                        ),
                        Divider(height: 32),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                "Delivery Fee: ₱${deliveryFee.toStringAsFixed(2)}",
                                style: GoogleFonts.roboto(
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.grey[700],
                                )),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Total Amount:",
                                    style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                Text(
                                    "₱${widget.totalAmount.toStringAsFixed(2)}",
                                    style: GoogleFonts.roboto(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.check_circle_outline, color: Colors.white),
                    label: _isProcessing
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text("Place Order",
                            style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF651D32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isProcessing
                        ? null
                        : () async {
                            setState(() => _isProcessing = true);
                            final uid = user!.uid;
                            final timestamp = Timestamp.now();

                            try {
                              // Get cart items first
                              final cartSnapshot = await FirebaseFirestore
                                  .instance
                                  .collection('users')
                                  .doc(uid)
                                  .collection('cart')
                                  .get();

                              if (cartSnapshot.docs.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text("Your cart is empty.")),
                                );
                                return;
                              }

                              // Create order
                              final orderRef = FirebaseFirestore.instance
                                  .collection('orders')
                                  .doc();
                              final orderId = orderRef.id;
                              // Process payment if needed
                              if (widget.paymentMethod != 'Cash On Delivery') {
                                await _processPaymentDeduction(orderId);
                              }

                              // Prepare order items and check stock
                              List<Map<String, dynamic>> orderItems = [];
                              for (var doc in cartSnapshot.docs) {
                                final cartData = doc.data();
                                final productId = cartData['productId'];
                                final productSnapshot = await FirebaseFirestore
                                    .instance
                                    .collection('products')
                                    .doc(productId)
                                    .get();

                                if (productSnapshot.exists) {
                                  final productData = productSnapshot.data()!;
                                  final currentStock =
                                      productData['stock'] ?? 0;
                                  final quantityOrdered = cartData['quantity'];

                                  if (currentStock < quantityOrdered) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              "Not enough stock for ${productData['productName']}.")),
                                    );
                                    return;
                                  }

                                  // Decrease stock
                                  await FirebaseFirestore.instance
                                      .collection('products')
                                      .doc(productId)
                                      .update({
                                    'stock': currentStock - quantityOrdered
                                  });

                                  orderItems.add({
                                    'productId': productId,
                                    'productName': productData['productName'],
                                    'imageUrl': productData['imageUrl'],
                                    'price': productData['price'],
                                    'quantity': quantityOrdered,
                                    'sellerId': productData['sellerId'],
                                    'status': 'Pending',
                                  });
                                }
                              }

                              await orderRef.set({
                                'orderId': orderId,
                                'userId': uid,
                                'items': orderItems,
                                'totalAmount': widget.totalAmount,
                                'orderDate': timestamp,
                                'shippingAddress': {
                                  'addressType': address['addressType'],
                                  'street': address['street'],
                                  'barangay': address['barangay'],
                                  'cityOrMunicipality':
                                      address['cityOrMunicipality'],
                                  'province': address['province'],
                                  'phone': address['phone'],
                                },
                                'payment': {
                                  'method': widget.paymentMethod,
                                  'paymentMethodId': widget.paymentMethodId,
                                  if (widget.paymentMethod == "G-Cash")
                                    'gcashPhone': widget.gcashPhone,
                                  if (widget.paymentMethod ==
                                      "Credit/Debit Card")
                                    'cardLast4': widget.cardLast4,
                                }
                              });

                              // Update transaction with order ID if not COD
                              if (widget.paymentMethod != 'Cash On Delivery') {
                                try {
                                  final transactions = await FirebaseFirestore
                                      .instance
                                      .collection('users')
                                      .doc(uid)
                                      .collection('transactions')
                                      .where('paymentMethodId',
                                          isEqualTo: widget.paymentMethodId)
                                      .where('orderId', isEqualTo: '')
                                      .orderBy('date', descending: true)
                                      .limit(1)
                                      .get();

                                  if (transactions.docs.isNotEmpty) {
                                    await transactions.docs.first.reference
                                        .update({
                                      'orderId': orderId,
                                    });
                                  }
                                } catch (e) {
                                  print(
                                      'Error updating transaction with orderId: $e');
                                  // Don't fail the whole order if this fails
                                }
                              }

                              // Clear cart
                              for (var doc in cartSnapshot.docs) {
                                await doc.reference.delete();
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text("Order placed successfully!")),
                              );

                              // Navigate to dashboard and remove all previous routes
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Dashboard()),
                                (route) => false,
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        "Error processing order: ${e.toString()}")),
                              );
                            } finally {
                              if (mounted) {
                                setState(() => _isProcessing = false);
                              }
                            }
                          },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
