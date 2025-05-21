import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'cart.dart';
import 'OrderConfirmation.dart';

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
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ),
      home: CartScreen(),
    );
  }
}

class CheckoutPage extends StatefulWidget {
  final double totalPrice;
  final String userId;

  CheckoutPage({required this.totalPrice, required this.userId});

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String? selectedAddressId;
  String selectedPaymentMethod = 'Credit/Debit Card';
  String? selectedGcashMethodId;
  String? selectedCardMethodId;

  List<Map<String, dynamic>> userAddresses = [];
  List<Map<String, dynamic>> paymentMethods = [];
  bool isLoading = true;
  bool isPaymentMethodsLoading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final paymentOptions = {
    'Credit/Debit Card': Icons.credit_card,
    'G-Cash': 'assets/gcash_logo.png',
    'Cash On Delivery': Icons.money,
  };

  @override
  void initState() {
    super.initState();
    fetchUserAddresses();
    fetchPaymentMethods();
  }

  Future<void> fetchUserAddresses() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('addresses')
          .get();

      setState(() {
        userAddresses = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          data['name'] = data['name'] ?? 'Unnamed';
          return data;
        }).toList();
      });
    } catch (e) {
      print("Error fetching addresses: $e");
    }
  }

  Future<void> fetchPaymentMethods() async {
    setState(() => isPaymentMethodsLoading = true);
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('paymentMethods')
          .get();

      setState(() {
        paymentMethods = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;

          // Handle missing fields with default values
          data['amount'] = data['amount'] ?? 0.0;
          data['number'] = data['number'] ?? '';
          data['name'] = data['name'] ?? '';
          data['type'] = data['type'] ?? '';

          // Only set expiry if it exists (for credit cards)
          if (data['type'] == 'credit_card' && data['expiry'] == null) {
            data['expiry'] = '01/30'; // Default expiry if missing
          }

          return data;
        }).toList();
        isLoading = false;
        isPaymentMethodsLoading = false;
      });
    } catch (e) {
      print("Error fetching payment methods: $e");
      setState(() {
        isLoading = false;
        isPaymentMethodsLoading = false;
      });
    }
  }

  Future<void> _processCheckout() async {
    if (!_formKey.currentState!.validate()) return;

    if (userAddresses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please add a delivery address before checkout.'),
      ));
      return;
    }

    if (selectedPaymentMethod == 'G-Cash' && selectedGcashMethodId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please select a GCash payment method.'),
      ));
      return;
    }

    if (selectedPaymentMethod == 'Credit/Debit Card' &&
        selectedCardMethodId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please select a card payment method.'),
      ));
      return;
    }

    // Validate payment method balance/expiry
    try {
      if (selectedPaymentMethod == 'G-Cash') {
        final gcashMethod = paymentMethods.firstWhere(
          (method) => method['id'] == selectedGcashMethodId,
        );

        if (gcashMethod['amount'] < widget.totalPrice) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Insufficient GCash balance. Please add funds.'),
          ));
          return;
        }
      } else if (selectedPaymentMethod == 'Credit/Debit Card') {
        final cardMethod = paymentMethods.firstWhere(
          (method) => method['id'] == selectedCardMethodId,
        );

        // Check card expiry
        final expiryParts = (cardMethod['expiry'] as String).split('/');
        final month = int.parse(expiryParts[0]);
        final year = 2000 + int.parse(expiryParts[1]);
        final now = DateTime.now();

        if (year < now.year || (year == now.year && month < now.month)) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Card has expired. Please use a different card.'),
          ));
          return;
        }

        // Check card balance
        if (cardMethod['amount'] < widget.totalPrice) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Insufficient card balance. Please use a different payment method.'),
          ));
          return;
        }
      }
// Determine the payment method ID based on the selected payment method
      // ignore: unused_local_variable
      String? paymentMethodId;
      if (selectedPaymentMethod == 'G-Cash') {
        if (selectedGcashMethodId == null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Please select a GCash payment method'),
          ));
          return;
        }
        paymentMethodId = selectedGcashMethodId;
      } else if (selectedPaymentMethod == 'Credit/Debit Card') {
        if (selectedCardMethodId == null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Please select a card payment method'),
          ));
          return;
        }
        paymentMethodId = selectedCardMethodId;
      } else {
        // For Cash On Delivery, paymentMethodId can be null
        paymentMethodId = null;
      }
      // Proceed to confirmation if all validations pass
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrderConfirmationScreen(
            addressId: selectedAddressId!,
            paymentMethod: selectedPaymentMethod,
            // Add this line to pass the payment method ID:
            paymentMethodId: selectedPaymentMethod == 'G-Cash'
                ? selectedGcashMethodId
                : selectedPaymentMethod == 'Credit/Debit Card'
                    ? selectedCardMethodId
                    : null,
            gcashPhone: selectedPaymentMethod == 'G-Cash'
                ? paymentMethods.firstWhere(
                    (m) => m['id'] == selectedGcashMethodId)['number']
                : null,
            cardLast4: selectedPaymentMethod == 'Credit/Debit Card'
                ? (paymentMethods.firstWhere(
                            (m) => m['id'] == selectedCardMethodId)['number']
                        as String)
                    .substring((paymentMethods.firstWhere((m) =>
                                    m['id'] == selectedCardMethodId)['number']
                                as String)
                            .length -
                        4)
                : null,
            totalAmount: widget.totalPrice,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error processing payment: $e'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Checkout',
          style: GoogleFonts.poppins(
              fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Address Selection
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Select Address',
                        labelStyle:
                            GoogleFonts.poppins(fontWeight: FontWeight.bold),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      icon: Icon(Icons.arrow_drop_down, color: Colors.black54),
                      value: selectedAddressId,
                      validator: (value) =>
                          value == null ? 'Please select address' : null,
                      items: userAddresses.map((address) {
                        return DropdownMenuItem(
                          value: address['id'] as String,
                          child: Text(address['name'] ?? 'name'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedAddressId = value;
                        });
                      },
                    ),
                    SizedBox(height: 12),
                    if (selectedAddressId != null)
                      buildAddressCard(
                        userAddresses.firstWhere(
                            (addr) => addr['id'] == selectedAddressId),
                      ),
                    SizedBox(height: 10),

                    // Payment Method Selection
                    Text('Payment Method',
                        style: GoogleFonts.poppins(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 6),
                    ...paymentOptions.entries.map((entry) {
                      final isSelected = selectedPaymentMethod == entry.key;
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              leading: entry.key == 'G-Cash'
                                  ? Image.asset(entry.value as String,
                                      width: 30, height: 30)
                                  : Icon(entry.value as IconData,
                                      color: Color(0xFF651D32)),
                              title: Text(entry.key,
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              trailing: Radio<String>(
                                value: entry.key,
                                groupValue: selectedPaymentMethod,
                                onChanged: (value) {
                                  setState(() {
                                    selectedPaymentMethod = value!;
                                  });
                                },
                              ),
                            ),
                            if (isSelected)
                              buildPaymentMethodSelection(entry.key),
                          ],
                        ),
                      );
                    }).toList(),
                    SizedBox(height: 80),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border:
              Border(top: BorderSide(color: Colors.grey.shade300, width: 1)),
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Amount',
                    style: GoogleFonts.poppins(
                        color: Colors.black54, fontSize: 14)),
                SizedBox(height: 4),
                Text('₱${widget.totalPrice.toStringAsFixed(2)}',
                    style: GoogleFonts.roboto(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
              ],
            ),
            SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _processCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF651D32),
                  minimumSize: Size(0, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Checkout',
                    style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPaymentMethodSelection(String method) {
    if (method == 'Cash On Delivery') {
      return SizedBox(); // No payment method selection for COD
    }
    if (isPaymentMethodsLoading) {
      return Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final typeToMatch = method == 'G-Cash' ? 'gcash' : 'credit_card';
    final filteredMethods = paymentMethods
        .where((m) => m['type']?.toLowerCase() == typeToMatch.toLowerCase())
        .toList();

    if (filteredMethods.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'No ${method == 'G-Cash' ? 'GCash' : 'card'} methods saved. '
          'Please add one in your payment methods.',
          style: GoogleFonts.poppins(color: Colors.grey),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Select ${method == 'G-Cash' ? 'GCash' : 'Card'}',
              border: OutlineInputBorder(),
            ),
            value: method == 'G-Cash'
                ? selectedGcashMethodId
                : selectedCardMethodId,
            validator: (value) => value == null
                ? 'Please select a ${method == 'G-Cash' ? 'GCash' : 'card'} method'
                : null,
            items: filteredMethods.map((paymentMethod) {
              try {
                final number = paymentMethod['number']?.toString() ?? '';
                final amount =
                    (paymentMethod['amount'] as num?)?.toDouble() ?? 0.0;
                final name = paymentMethod['name']?.toString() ?? '';
                final expiry = paymentMethod['expiry']?.toString();

                final displayText = method == 'G-Cash'
                    ? '$number (₱${amount.toStringAsFixed(2)})'
                    : '$name •••• ${number.length >= 4 ? number.substring(number.length - 4) : number} '
                        '${expiry != null ? 'Exp $expiry' : ''} '
                        '(₱${amount.toStringAsFixed(2)})';

                return DropdownMenuItem<String>(
                  value: paymentMethod['id']?.toString(),
                  child: Text(displayText),
                );
              } catch (e) {
                print('Error formatting payment method: $e');
                return DropdownMenuItem<String>(
                  value: paymentMethod['id']?.toString(),
                  child: Text('Invalid payment method'),
                );
              }
            }).toList(),
            onChanged: (value) {
              setState(() {
                if (method == 'G-Cash') {
                  selectedGcashMethodId = value;
                } else {
                  selectedCardMethodId = value;
                }
              });
            },
          ),
          SizedBox(height: 8),
          if (method == 'G-Cash' && selectedGcashMethodId != null)
            _buildBalanceWarning(
                widget.totalPrice,
                filteredMethods.firstWhere(
                    (m) => m['id'] == selectedGcashMethodId)['amount']),
          if (method == 'Credit/Debit Card' && selectedCardMethodId != null)
            _buildCardWarning(
                widget.totalPrice,
                filteredMethods
                    .firstWhere((m) => m['id'] == selectedCardMethodId)),
          if (method == 'Credit/Debit Card' && selectedCardMethodId != null)
            _buildBalanceWarning(
                widget.totalPrice,
                filteredMethods.firstWhere(
                    (m) => m['id'] == selectedCardMethodId)['amount']),
        ],
      ),
    );
  }

  Widget _buildBalanceWarning(double total, double balance) {
    if (balance >= total) return SizedBox();

    return Padding(
      padding: EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(Icons.warning, color: Colors.orange),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Insufficient balance (₱${(total - balance).toStringAsFixed(2)} needed)',
              style: GoogleFonts.roboto(color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardWarning(double total, Map<String, dynamic> card) {
    final expiryParts = (card['expiry'] as String).split('/');
    final month = int.parse(expiryParts[0]);
    final year = 2000 + int.parse(expiryParts[1]);
    final now = DateTime.now();
    final isExpired =
        year < now.year || (year == now.year && month < now.month);
    final hasInsufficientFunds = card['amount'] < total;

    if (!isExpired && !hasInsufficientFunds) return SizedBox();

    return Padding(
      padding: EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isExpired)
            Row(
              children: [
                Icon(Icons.warning, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Card expired',
                  style: GoogleFonts.poppins(color: Colors.orange),
                ),
              ],
            ),
          if (hasInsufficientFunds)
            Row(
                // children: [
                //   Icon(Icons.warning, color: Colors.orange),
                //   SizedBox(width: 8),
                //   // Text(
                //   //   'Insufficient funds (₱${(total - card['amount']).toStringAsFixed(2)} needed)',
                //   //   style: GoogleFonts.poppins(color: Colors.orange),
                //   // ),
                // ],
                ),
        ],
      ),
    );
  }

  // Keep your existing buildAddressCard and addressFieldRow methods
  Widget buildAddressCard(Map<String, dynamic> address) {
    return Card(
      color: Colors.white,
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            addressFieldRow(
                Icons.home, 'Address Type: ${address['addressType']}'),
            SizedBox(height: 8),
            addressFieldRow(
                Icons.location_city, 'Barangay: ${address['barangay']}'),
            SizedBox(height: 8),
            addressFieldRow(Icons.location_on,
                'City/Municipality: ${address['cityOrMunicipality']}'),
            SizedBox(height: 8),
            addressFieldRow(Icons.phone, 'Phone: ${address['phone']}'),
            SizedBox(height: 8),
            addressFieldRow(Icons.map, 'Province: ${address['province']}'),
            SizedBox(height: 8),
            addressFieldRow(Icons.streetview, 'Street: ${address['street']}'),
          ],
        ),
      ),
    );
  }

  Widget addressFieldRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade700),
        SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }
}
