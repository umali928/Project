import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentMethodScreen extends StatefulWidget {
  @override
  _PaymentMethodScreenState createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  int _selectedTab = 0; // 0 for GCash, 1 for Credit Card
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _gcashNumberController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  // Fields
  String _gcashName = '';
  String _cardHolderName = '';
  String _expiryDate = '';
  String _cvv = '';
  double _gcashAmount = 0.0;
  double _cardAmount = 0.0;

  bool _isLoading = false;

  @override
  void dispose() {
    _gcashNumberController.dispose();
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Payment Methods',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tabs for GCash and Credit Card
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _selectedTab = 0),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedTab == 0
                              ? Color(0xFF651D32)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            'GCash',
                            style: GoogleFonts.poppins(
                              color: _selectedTab == 0
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _selectedTab = 1),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedTab == 1
                              ? Color(0xFF651D32)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            'Credit Card',
                            style: GoogleFonts.poppins(
                              color: _selectedTab == 1
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            Form(
              key: _formKey,
              child: _selectedTab == 0
                  ? _buildGCashForm()
                  : _buildCreditCardForm(),
            ),

            SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF651D32),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _savePaymentMethod,
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Save Payment Method',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),

            SizedBox(height: 20),

            Text(
              'Saved Payment Methods',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            _buildSavedPaymentMethods(),
          ],
        ),
      ),
    );
  }

  Widget _buildGCashForm() {
    return Column(
      children: [
        TextFormField(
          controller: _gcashNumberController,
          decoration: InputDecoration(
            labelText: 'GCash Number',
            hintText: '09XXXXXXXXX',
            prefixStyle:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            prefixIcon: Icon(Icons.phone_android),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(11),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your GCash number';
            }
            if (!RegExp(r'^09\d{9}$').hasMatch(value)) {
              return 'Please enter a valid 9-digit number after 09';
            }
            return null;
          },
          onChanged: (value) {
            if (!value.startsWith('09') && value.isNotEmpty) {
              _gcashNumberController.text = '09' + value;
              _gcashNumberController.selection = TextSelection.fromPosition(
                TextPosition(offset: _gcashNumberController.text.length),
              );
            }
          },
        ),
        SizedBox(height: 16),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Account Name',
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the account name';
            }
            if (value.length < 2) {
              return 'Name must be at least 2 characters';
            }
            return null;
          },
          onSaved: (value) => _gcashName = value!,
        ),
        SizedBox(height: 16),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Amount (PHP)',
            prefixIcon: Icon(Icons.money),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter an amount';
            }
            if (double.tryParse(value) == null) {
              return 'Please enter a valid amount';
            }
            if (double.parse(value) <= 0) {
              return 'Amount must be greater than 0';
            }
            return null;
          },
          onSaved: (value) => _gcashAmount = double.parse(value!),
        ),
      ],
    );
  }

  Widget _buildCreditCardForm() {
    return Column(
      children: [
        TextFormField(
          controller: _cardNumberController,
          decoration: InputDecoration(
            labelText: 'Card Number',
            hintText: 'XXXX XXXX XXXX XXXX',
            prefixIcon: Icon(Icons.credit_card),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(16),
            CardNumberFormatter(),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter card number';
            }
            final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
            if (digits.length != 16) {
              return 'Please enter a valid 16-digit card number';
            }
            return null;
          },
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _expiryDateController,
                decoration: InputDecoration(
                  labelText: 'Expiry Date (MM/YY)',
                  hintText: 'MM/YY',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                  ExpiryDateFormatter(),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter expiry date';
                  }
                  if (!RegExp(r'^(0[1-9]|1[0-2])\/?([0-9]{2})$')
                      .hasMatch(value)) {
                    return 'Format: MM/YY';
                  }
                  final parts = value.split('/');
                  if (parts.length == 2) {
                    final month = int.tryParse(parts[0]);
                    final year = int.tryParse(parts[1]);
                    final now = DateTime.now();
                    final currentYear = now.year % 100;

                    if (month == null || year == null) return 'Invalid date';
                    if (month < 1 || month > 12) return 'Invalid month';
                    if (year < currentYear || year > currentYear + 20)
                      return 'Invalid year';
                    if (year == currentYear && month < now.month)
                      return 'Card expired';
                  }
                  return null;
                },
                onSaved: (value) => _expiryDate = value!,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _cvvController,
                decoration: InputDecoration(
                  labelText: 'CVV',
                  hintText: 'XXX',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                obscureText: true,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter CVV';
                  }
                  if (!RegExp(r'^[0-9]{3}$').hasMatch(value)) {
                    return '3 digits required';
                  }
                  return null;
                },
                onSaved: (value) => _cvv = value!,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Cardholder Name',
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter cardholder name';
            }
            if (value.length < 2) {
              return 'Name must be at least 2 characters';
            }
            return null;
          },
          onSaved: (value) => _cardHolderName = value!,
        ),
        SizedBox(height: 16),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Amount (PHP)',
            prefixIcon: Icon(Icons.money),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter an amount';
            }
            if (double.tryParse(value) == null) {
              return 'Please enter a valid amount';
            }
            if (double.parse(value) <= 0) {
              return 'Amount must be greater than 0';
            }
            return null;
          },
          onSaved: (value) => _cardAmount = double.parse(value!),
        ),
      ],
    );
  }

  Widget _buildSavedPaymentMethods() {
    final user = firebase_auth.FirebaseAuth.instance.currentUser;
    if (user == null) return Container();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('paymentMethods')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final paymentMethods = snapshot.data?.docs ?? [];
        if (paymentMethods.isEmpty) {
          return Center(
            child: Text(
              'No saved payment methods',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: paymentMethods.length,
          itemBuilder: (context, index) {
            final method = paymentMethods[index].data() as Map<String, dynamic>;
            return Card(
              margin: EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: Icon(
                  method['type'] == 'gcash'
                      ? Icons.phone_android
                      : Icons.credit_card,
                  color: Color(0xFF651D32),
                ),
                title: Text(
                  method['type'] == 'gcash'
                      ? 'GCash: ${method['number']}'
                      : 'Card: •••• ${(method['number'] as String).substring((method['number'] as String).length - 4)}',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method['type'] == 'gcash'
                          ? method['name'] as String
                          : 'Expires ${method['expiry']}',
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Balance: ₱${(method['amount'] as num).toStringAsFixed(2)}',
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.add, color: Colors.blue),
                      onPressed: () =>
                          _addAmountToMethod(paymentMethods[index].id),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () =>
                          _deletePaymentMethod(paymentMethods[index].id),
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

  Future<void> _savePaymentMethod() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    try {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final paymentMethodsRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('paymentMethods');

      if (_selectedTab == 0) {
        // GCash
        await paymentMethodsRef.add({
          'type': 'gcash',
          'number':
              '09${_gcashNumberController.text.substring(2)}', // Ensure proper format
          'name': _gcashName,
          'amount': _gcashAmount,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Credit Card
        await paymentMethodsRef.add({
          'type': 'credit_card',
          'number': _cardNumberController.text.replaceAll(' ', ''),
          'expiry': _expiryDate,
          'cvv': _cvv,
          'name': _cardHolderName,
          'amount': _cardAmount,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment method saved successfully')),
      );

      _formKey.currentState!.reset();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save payment method: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addAmountToMethod(String methodId) async {
    final user = firebase_auth.FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.money, color: Color(0xFF651D32)),
              SizedBox(width: 8),
              Text('Add Amount',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 8),
                TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Amount (PHP)',
                    prefixIcon: Icon(Icons.money, color: Color(0xFF651D32)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                  ),
                  style: GoogleFonts.poppins(
                      fontSize: 18, fontWeight: FontWeight.w500),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid amount';
                    }
                    if (double.parse(value) <= 0) {
                      return 'Amount must be greater than 0';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actionsPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: GoogleFonts.poppins(color: Colors.grey[700])),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF651D32),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () async {
                if (formKey.currentState?.validate() != true) return;

                try {
                  final amountToAdd = double.parse(amountController.text);
                  final paymentMethodRef = FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .collection('paymentMethods')
                      .doc(methodId);

                  await FirebaseFirestore.instance
                      .runTransaction((transaction) async {
                    final snapshot = await transaction.get(paymentMethodRef);
                    final currentAmount = snapshot.get('amount') as double;
                    transaction.update(paymentMethodRef, {
                      'amount': currentAmount + amountToAdd,
                    });
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Amount added successfully')),
                  );
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to add amount: $e')),
                  );
                }
              },
              child: Text('Add',
                  style: GoogleFonts.poppins(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePaymentMethod(String methodId) async {
    final user = firebase_auth.FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Show confirmation dialog before deleting
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Payment Method'),
        content: Text('Are you sure you want to delete this payment method?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF651D32),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('paymentMethods')
          .doc(methodId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment method removed')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove payment method: $e')),
      );
    }
  }
}

class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    var formattedText = '';

    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) formattedText += ' ';
      formattedText += text[i];
    }

    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

class ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text.replaceAll('/', '');

    if (text.length >= 2) {
      text = text.substring(0, 2) + '/' + text.substring(2);
    }

    return newValue.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
