import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CheckoutPage(),
    ));

class CheckoutPage extends StatefulWidget {
  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String? selectedAddressName;
  String selectedPaymentMethod = 'Credit/Debit Card';

  final cardNumberController = TextEditingController();
  final expiryController = TextEditingController();
  final cvvController = TextEditingController();
  final phonenumberController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final Map<String, Map<String, String>> addressDetails = {
    'Home': {
      'addressType': 'Residential',
      'barangay': 'Barangay 123',
      'cityOrMunicipality': 'Quezon City',
      'phoneNumber': '09171234567',
      'province': 'Metro Manila',
      'street': '123 Example St.',
    },
    'Work': {
      'addressType': 'Commercial',
      'barangay': 'Barangay 456',
      'cityOrMunicipality': 'Makati',
      'phoneNumber': '09981234567',
      'province': 'Metro Manila',
      'street': '456 Office Rd.',
    },
  };

  final paymentOptions = {
    'Credit/Debit Card': Icons.credit_card,
    'G-Cash': 'assets/gcash_logo.png',
    'Cash On Delivery': Icons.money,
  };

  @override
  Widget build(BuildContext context) {
    final selectedDetails = selectedAddressName != null
        ? addressDetails[selectedAddressName]
        : null;

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Select Address Name',
                  labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                icon: Icon(Icons.arrow_drop_down, color: Colors.black54),
                dropdownColor: Colors.white,
                value: selectedAddressName,
                validator: (value) =>
                    value == null ? 'Please select address' : null,
                items: addressDetails.keys.map((name) {
                  return DropdownMenuItem(
                    value: name,
                    child: Text(name, style: TextStyle(fontSize: 16)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedAddressName = value;
                  });
                },
              ),
              SizedBox(height: 12),
              if (selectedDetails != null)
                Card(
                  color: Colors.white,
                  elevation: 2,
                  margin: EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        addressFieldRow(Icons.home,
                            'Address Type: ${selectedDetails['addressType']}'),
                        SizedBox(height: 8),
                        addressFieldRow(Icons.location_city,
                            'Barangay: ${selectedDetails['barangay']}'),
                        SizedBox(height: 8),
                        addressFieldRow(Icons.location_on,
                            'City/Municipality: ${selectedDetails['cityOrMunicipality']}'),
                        SizedBox(height: 8),
                        addressFieldRow(Icons.phone,
                            'Phone: ${selectedDetails['phoneNumber']}'),
                        SizedBox(height: 8),
                        addressFieldRow(Icons.map,
                            'Province: ${selectedDetails['province']}'),
                        SizedBox(height: 8),
                        addressFieldRow(Icons.streetview,
                            'Street: ${selectedDetails['street']}'),
                      ],
                    ),
                  ),
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
                            ? Image.asset(
                                entry.value as String,
                                width: 30,
                                height: 30,
                              )
                            : Icon(entry.value as IconData,
                                color: Color(0xFF651D32)),
                        title: Text(entry.key,
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold, fontSize: 16)),
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
              SizedBox(height: 80), // For bottom bar space
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
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
                Text('₱28.6',
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
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Processing Payment...')),
                    );
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
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Column(
            children: [
              TextFormField(
                controller: cardNumberController,
                keyboardType: TextInputType.number,
                maxLength: 16,
                decoration: InputDecoration(labelText: 'Card Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter card number';
                  } else if (value.length != 16 ||
                      !RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'Card number must be 16 digits';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: expiryController,
                decoration: InputDecoration(labelText: 'Expiry Date (MM/YY)'),
                keyboardType: TextInputType.datetime,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter expiry date';
                  } else if (!RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$')
                      .hasMatch(value)) {
                    return 'Enter a valid date (MM/YY)';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: cvvController,
                keyboardType: TextInputType.number,
                maxLength: 3,
                decoration: InputDecoration(labelText: 'CVV'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter CVV';
                  } else if (value.length != 3 ||
                      !RegExp(r'^[0-9]{3}$').hasMatch(value)) {
                    return 'CVV must be 3 digits';
                  }
                  return null;
                },
              ),
            ],
          ),
        );

      case 'G-Cash':
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: TextFormField(
            controller: phonenumberController,
            keyboardType: TextInputType.phone,
            maxLength: 11,
            decoration: InputDecoration(labelText: 'Phone number'),
            onChanged: (value) {
              if (value.isNotEmpty && !value.startsWith('09')) {
                phonenumberController.text = '09';
                phonenumberController.selection = TextSelection.fromPosition(
                  TextPosition(offset: phonenumberController.text.length),
                );
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Enter GCash number';
              } else if (!RegExp(r'^09\d{9}$').hasMatch(value)) {
                return 'Phone number must start with 09 and be 11 digits';
              }
              return null;
            },
          ),
        );
      default:
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('No additional info required.'),
        );
    }
  }
}
