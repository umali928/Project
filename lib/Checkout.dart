import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'cart.dart';

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

  List<Map<String, dynamic>> userAddresses = [];
  bool isLoading = true;

  final cardNumberController = TextEditingController();
  final expiryController = TextEditingController();
  final cvvController = TextEditingController();
  final phonenumberController = TextEditingController();
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
     phonenumberController.text = '09'; // Set default GCash prefix
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
          data['name'] = data['name'] ?? 'Unnamed'; // ensure fallback
          return data;
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching addresses: $e");
      setState(() {
        isLoading = false;
      });
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
                            if (isSelected) buildPaymentInputForm(entry.key),
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
                onPressed: () {
                  if (userAddresses.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          'Please add a delivery address before checkout.'),
                    ));
                    return;
                  }

                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Processing Payment...')));
                  }
                },
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

  Widget buildPaymentInputForm(String method) {
    switch (method) {
      case 'Credit/Debit Card':
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Column(
            children: [
              TextFormField(
                controller: cardNumberController,
                keyboardType: TextInputType.number,
                maxLength: 16,
                decoration: InputDecoration(labelText: 'Card Number'),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Enter card number';
                  if (value.length != 16)
                    return 'Card number must be 16 digits';
                  return null;
                },
              ),
              TextFormField(
                controller: expiryController,
                decoration: InputDecoration(labelText: 'Expiry Date (MM/YY)'),
                keyboardType: TextInputType.datetime,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Enter expiry date';
                  if (!RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$').hasMatch(value))
                    return 'Invalid date format';
                  return null;
                },
              ),
              TextFormField(
                controller: cvvController,
                keyboardType: TextInputType.number,
                maxLength: 3,
                decoration: InputDecoration(labelText: 'CVV'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter CVV';
                  if (value.length != 3) return 'CVV must be 3 digits';
                  return null;
                },
              ),
            ],
          ),
        );
      case 'G-Cash':
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: TextFormField(
            controller: phonenumberController,
            keyboardType: TextInputType.phone,
            maxLength: 11,
            decoration: InputDecoration(labelText: 'Phone number'),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Enter GCash number';
              if (!RegExp(r'^09\d{9}$').hasMatch(value))
                return 'Invalid phone number';
              return null;
            },
            onChanged: (value) {
              // Automatically prepend 09 if not already present
              if (!value.startsWith('09')) {
                phonenumberController.text = '09';
                phonenumberController.selection = TextSelection.fromPosition(
                  TextPosition(offset: phonenumberController.text.length),
                );
              }
            },
          ),
        );
      default:
        return Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('No additional info required.'),
        );
    }
  }
}
