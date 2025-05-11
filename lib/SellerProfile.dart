import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lspu/navigation_drawer.dart' as custom;
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SellerProfile extends StatefulWidget {
  @override
  _SellerProfileState createState() => _SellerProfileState();
}

class _SellerProfileState extends State<SellerProfile> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _isLoading = true;

  // Profile data
  String storeName = '';
  String barangay = '';
  String phoneNumber = '';
  String province = '';
  String street = '';
  String cityMunicipal = '';

  // Controllers
  late TextEditingController _barangayController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _provinceController;
  late TextEditingController _streetController;
  late TextEditingController _cityMunicipalController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _fetchSellerData();
  }

  void _initializeControllers() {
    _barangayController = TextEditingController(text: barangay);
    _phoneNumberController = TextEditingController(text: phoneNumber);
    _provinceController = TextEditingController(text: province);
    _streetController = TextEditingController(text: street);
    _cityMunicipalController = TextEditingController(text: cityMunicipal);

    // Add listener to phone number controller
    _phoneNumberController.addListener(_handlePhoneNumberInput);
  }

  void _handlePhoneNumberInput() {
    final text = _phoneNumberController.text;

    // Remove any non-digit characters except the + at the start
    String digitsOnly = text.replaceAll(RegExp(r'[^0-9+]'), '');

    // Ensure it starts with +63
    if (!digitsOnly.startsWith('+63') && digitsOnly.isNotEmpty) {
      digitsOnly = '+63${digitsOnly.replaceAll('+63', '')}';
    }

    // Limit to 13 characters (including +63)
    if (digitsOnly.length > 13) {
      digitsOnly = digitsOnly.substring(0, 13);
    }

    if (text != digitsOnly) {
      _phoneNumberController.value = _phoneNumberController.value.copyWith(
        text: digitsOnly,
        selection: TextSelection.collapsed(offset: digitsOnly.length),
      );
    }
  }

  Future<void> _fetchSellerData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('sellerInfo')
            .limit(1)
            .get();

        if (doc.docs.isNotEmpty) {
          final data = doc.docs.first.data();
          setState(() {
            storeName = data['storeName'] ?? '';
            barangay = data['barangay'] ?? '';
            phoneNumber = data['phone'] ?? '';
            province = data['province'] ?? '';
            street = data['street'] ?? '';
            cityMunicipal = data['city'] ?? '';

            // Update controllers with fetched data
            _barangayController.text = barangay;
            _phoneNumberController.text = phoneNumber;
            _provinceController.text = province;
            _streetController.text = street;
            _cityMunicipalController.text = cityMunicipal;

            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error fetching seller data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateSellerData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Get the existing document ID or create new if needed
        final query = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('sellerInfo')
            .limit(1)
            .get();

        final docRef = query.docs.isNotEmpty
            ? query.docs.first.reference
            : FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('sellerInfo')
                .doc();

        await docRef.set({
          'storeName': storeName, // Preserve existing store name
          'barangay': _barangayController.text,
          'phone': _phoneNumberController.text,
          'province': _provinceController.text,
          'street': _streetController.text,
          'city': _cityMunicipalController.text,
        }, SetOptions(merge: true));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    }
  }

  void _toggleEdit() {
    if (_isEditing) {
      if (_formKey.currentState!.validate()) {
        _updateSellerData().then((_) {
          setState(() {
            barangay = _barangayController.text;
            phoneNumber = _phoneNumberController.text;
            province = _provinceController.text;
            street = _streetController.text;
            cityMunicipal = _cityMunicipalController.text;
            _isEditing = !_isEditing;
          });
        });
      }
    } else {
      setState(() {
        _isEditing = !_isEditing;
      });
    }
  }

  @override
  void dispose() {
    _phoneNumberController.removeListener(_handlePhoneNumberInput);
    _barangayController.dispose();
    _phoneNumberController.dispose();
    _provinceController.dispose();
    _streetController.dispose();
    _cityMunicipalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: custom.NavigationDrawer(),
      appBar: AppBar(
        title: Text(
          'Seller Profile',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        backgroundColor: Colors.white,
        actions: [
          if (!_isLoading)
            IconButton(
              icon: Icon(_isEditing ? Icons.save : Icons.edit),
              onPressed: _toggleEdit,
              color: Colors.black,
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          'Home / Profile',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildProfileItem('Store Name', storeName, false),
                              _buildProfileItem(
                                  'Barangay', barangay, _isEditing,
                                  controller: _barangayController),
                              _buildProfileItem(
                                'Phone Number',
                                phoneNumber,
                                _isEditing,
                                controller: _phoneNumberController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter phone number';
                                  }
                                  if (!value.startsWith('+63')) {
                                    return 'Phone number must start with +63';
                                  }
                                  if (value.length != 13) {
                                    return 'Phone number must be 13 characters (including +63)';
                                  }
                                  // Additional validation to ensure only numbers after +63
                                  final numberPart = value.substring(3);
                                  if (!RegExp(r'^[0-9]+$')
                                      .hasMatch(numberPart)) {
                                    return 'Phone number can only contain numbers after +63';
                                  }
                                  return null;
                                },
                              ),
                              _buildProfileItem(
                                  'Province', province, _isEditing,
                                  controller: _provinceController),
                              _buildProfileItem('Street', street, _isEditing,
                                  controller: _streetController),
                              _buildProfileItem(
                                  'City/Municipal', cityMunicipal, _isEditing,
                                  controller: _cityMunicipalController),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildProfileItem(
    String label,
    String value,
    bool isEditable, {
    TextEditingController? controller,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 0, 0, 0),
            ),
          ),
          SizedBox(height: 4),
          if (!isEditable)
            Text(
              value.isEmpty ? 'Not set' : value,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF651D32),
              ),
            ),
          if (isEditable)
            TextFormField(
              controller: controller,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
              ],
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF651D32),
              ),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                errorStyle: TextStyle(fontSize: 12),
              ),
              validator: validator,
            ),
          Divider(thickness: 1),
        ],
      ),
    );
  }
}
