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

    _phoneNumberController.addListener(_handlePhoneNumberInput);
  }

  void _handlePhoneNumberInput() {
    final text = _phoneNumberController.text;
    String digitsOnly = text.replaceAll(RegExp(r'[^0-9+]'), '');

    if (!digitsOnly.startsWith('+63') && digitsOnly.isNotEmpty) {
      digitsOnly = '+63${digitsOnly.replaceAll('+63', '')}';
    }

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
          'storeName': storeName,
          'barangay': _barangayController.text,
          'phone': _phoneNumberController.text,
          'province': _provinceController.text,
          'street': _streetController.text,
          'city': _cityMunicipalController.text,
        }, SetOptions(merge: true));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
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
      backgroundColor: Colors.grey[50],
      drawer: custom.NavigationDrawer(),
      appBar: AppBar(
        title: Text(
          'Seller Profile',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _toggleEdit,
              child: Text(
                _isEditing ? 'SAVE' : 'EDIT',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF651D32),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF651D32)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Store Information',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildProfileHeader(),
                            SizedBox(height: 16),
                            Divider(height: 1, color: Colors.grey[300]),
                            SizedBox(height: 16),
                            _buildProfileItem(
                              icon: Icons.store,
                              label: 'Store Name',
                              value: storeName,
                              isEditable: false,
                            ),
                            _buildProfileItem(
                              icon: Icons.location_on,
                              label: 'Street',
                              value: street,
                              isEditable: _isEditing,
                              controller: _streetController,
                            ),
                            _buildProfileItem(
                              icon: Icons.house,
                              label: 'Barangay',
                              value: barangay,
                              isEditable: _isEditing,
                              controller: _barangayController,
                            ),
                            _buildProfileItem(
                              icon: Icons.location_city,
                              label: 'City/Municipal',
                              value: cityMunicipal,
                              isEditable: _isEditing,
                              controller: _cityMunicipalController,
                            ),
                            _buildProfileItem(
                              icon: Icons.map,
                              label: 'Province',
                              value: province,
                              isEditable: _isEditing,
                              controller: _provinceController,
                            ),
                            _buildProfileItem(
                              icon: Icons.phone,
                              label: 'Phone Number',
                              value: phoneNumber,
                              isEditable: _isEditing,
                              controller: _phoneNumberController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter phone number';
                                }
                                if (!value.startsWith('+63')) {
                                  return 'Phone number must start with +63';
                                }
                                if (value.length != 13) {
                                  return 'Phone number must be 13 characters';
                                }
                                final numberPart = value.substring(3);
                                if (!RegExp(r'^[0-9]+$').hasMatch(numberPart)) {
                                  return 'Only numbers after +63';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_isEditing) ...[
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _isEditing = false;
                                  // Reset controllers to original values
                                  _barangayController.text = barangay;
                                  _phoneNumberController.text = phoneNumber;
                                  _provinceController.text = province;
                                  _streetController.text = street;
                                  _cityMunicipalController.text = cityMunicipal;
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                side: BorderSide(color: Color(0xFF651D32)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'CANCEL',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF651D32),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _toggleEdit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF651D32),
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'SAVE CHANGES',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Color(0xFF651D32).withOpacity(0.1),
          child: Icon(
            Icons.person,
            size: 30,
            color: Color(0xFF651D32),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                storeName.isEmpty ? 'Your Store' : storeName,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Seller Account',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String label,
    required String value,
    required bool isEditable,
    TextEditingController? controller,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: Color(0xFF651D32),
              ),
              SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          if (!isEditable)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                value.isEmpty ? 'Not provided' : value,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: value.isEmpty ? Colors.grey[500] : Colors.black87,
                ),
              ),
            ),
          if (isEditable)
            TextFormField(
              controller: controller,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.black87,
              ),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(12),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.red),
                ),
                errorStyle: TextStyle(fontSize: 12),
              ),
              validator: validator,
              keyboardType: label == 'Phone Number'
                  ? TextInputType.phone
                  : TextInputType.text,
              inputFormatters: label == 'Phone Number'
                  ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9+]'))]
                  : null,
            ),
        ],
      ),
    );
  }
}
