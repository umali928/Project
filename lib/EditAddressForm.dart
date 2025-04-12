import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditAddressPage extends StatefulWidget {
  final String userId;
  final String addressId;
  final Map<String, dynamic> existingData;

  const EditAddressPage({
    super.key,
    required this.userId,
    required this.addressId,
    required this.existingData,
  });

  @override
  State<EditAddressPage> createState() => _EditAddressPageState();
}

class _EditAddressPageState extends State<EditAddressPage> {
  late String addressType;
  final Map<String, TextEditingController> _controllers = {};

  final Map<String, IconData> _icons = {
    'Name': Icons.person,
    'Mobile Number': Icons.phone,
    'Flat No. Street Details': Icons.home_work,
    'Barangay': Icons.location_on,
    'City/Municipality': Icons.location_city,
    'Province': Icons.map,
  };

  @override
  void initState() {
    super.initState();
    addressType = widget.existingData['addressType'] ?? 'Home';
    _controllers['Name'] =
        TextEditingController(text: widget.existingData['name']);
    _controllers['Mobile Number'] =
        TextEditingController(text: widget.existingData['phone']);
    _controllers['Flat No. Street Details'] =
        TextEditingController(text: widget.existingData['street']);
    _controllers['Barangay'] =
        TextEditingController(text: widget.existingData['barangay']);
    _controllers['City/Municipality'] =
        TextEditingController(text: widget.existingData['cityOrMunicipality']);
    _controllers['Province'] =
        TextEditingController(text: widget.existingData['province']);
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Edit Address',
            style: GoogleFonts.poppins(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ..._controllers.entries.map((entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 38),
                            child: TextField(
                              controller: entry.value,
                              maxLines: entry.key == 'Flat No. Street Details'
                                  ? null
                                  : 1,
                              inputFormatters: entry.key == 'Mobile Number'
                                  ? [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'^\+?\d*')),
                                      LengthLimitingTextInputFormatter(13),
                                      _PhoneNumberFormatter(),
                                    ]
                                  : [],
                              decoration: InputDecoration(
                                labelText: entry.key,
                                filled: true,
                                fillColor: Colors.white,
                                prefixIcon: Icon(_icons[entry.key],
                                    color: const Color(0xFF651D32)),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 18),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: Colors.grey.shade300, width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Colors.blue, width: 1.5),
                                ),
                              ),
                            ),
                          )),
                      const SizedBox(height: 2),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Address Type",
                          style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[800]),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: ['Home', 'Office', 'School'].map((type) {
                          final isSelected = addressType == type;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => addressType = type),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 6),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF651D32)
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: isSelected
                                          ? Colors.blue
                                          : Colors.grey.shade300,
                                      width: 1),
                                ),
                                child: Center(
                                  child: Text(
                                    type,
                                    style: GoogleFonts.poppins(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            final name = _controllers['Name']!.text.trim();
                            final phone =
                                _controllers['Mobile Number']!.text.trim();
                            final street =
                                _controllers['Flat No. Street Details']!
                                    .text
                                    .trim();
                            final barangay =
                                _controllers['Barangay']!.text.trim();
                            final city =
                                _controllers['City/Municipality']!.text.trim();
                            final province =
                                _controllers['Province']!.text.trim();

                            if (name.isEmpty || name.length < 3) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Please enter a valid name (at least 3 characters).')),
                              );
                              return;
                            }

                            final phoneRegex = RegExp(r'^\+63\d{10}$');
                            if (!phoneRegex.hasMatch(phone)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Invalid phone number. Use +63 followed by 10 digits (e.g. +639123456789).')),
                              );
                              return;
                            }

                            if (street.isEmpty ||
                                barangay.isEmpty ||
                                city.isEmpty ||
                                province.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Please fill out all address fields.')),
                              );
                              return;
                            }
                            final updatedData = {
                              'name': _controllers['Name']!.text,
                              'phone': _controllers['Mobile Number']!.text,
                              'street':
                                  _controllers['Flat No. Street Details']!.text,
                              'barangay': _controllers['Barangay']!.text,
                              'cityOrMunicipality':
                                  _controllers['City/Municipality']!.text,
                              'province': _controllers['Province']!.text,
                              'addressType': addressType,
                            };
                               try {
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(widget.userId)
                                  .collection('addresses')
                                  .doc(widget.addressId)
                                  .update(updatedData);

                              if (!context.mounted) return;

                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20)),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 30, horizontal: 20),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.check_circle,
                                            color: Color(0xFF651D32), size: 60),
                                        const SizedBox(height: 20),
                                        Text(
                                          'Address Updated\nSuccessfully!',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 30),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              Navigator.pop(context);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Color(0xFF651D32),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10)),
                                            ),
                                            child: Text("Done",
                                                style: GoogleFonts.poppins(
                                                    fontSize: 16,
                                                    color: Colors.white)),
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                },
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error updating address: $e')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF651D32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            "Save Address",
                            style: GoogleFonts.poppins(
                                fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;

    if (!text.startsWith('+63')) {
      text = '+63' + text.replaceAll(RegExp(r'^\+?63?'), '');
    }

    if (text.length > 3) {
      String prefix = text.substring(0, 3);
      String digits = text.substring(3).replaceAll(RegExp(r'\D'), '');
      text = prefix + digits;
    }

    if (text.length > 13) {
      text = text.substring(0, 13);
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
