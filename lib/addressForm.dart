import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add this import
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/services.dart';

Future<void> main() async {
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
          appId: "1:533992551897:web:d04a482ad131a0700815c8"),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Add Address',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red, // Replace with a predefined MaterialColor
      ),
      home: AddAddressPage(),
    );
  }
}

class AddAddressPage extends StatefulWidget {
  const AddAddressPage({super.key});

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  String addressType = 'Home';

  final _controllers = {
    'Name': TextEditingController(),
    'Mobile Number': TextEditingController(),
    'Flat No. Street Details': TextEditingController(),
    'Barangay': TextEditingController(),
    'City/Municipality': TextEditingController(),
    'Province': TextEditingController(),
  };
  final Map<String, IconData> _icons = {
    'Name': Icons.person,
    'Mobile Number': Icons.phone,
    'Flat No. Street Details': Icons.home_work,
    'Barangay': Icons.location_on,
    'City/Municipality': Icons.location_city,
    'Province': Icons.map,
  };
  final _hintTexts = {
    'Name': 'Enter Name',
    'Mobile Number': 'e.g. +639123456789',
    'Flat No. Street Details': 'Enter house/building/street',
    'Barangay': 'Enter barangay',
    'City/Municipality': 'Enter city or municipality',
    'Province': 'Enter province',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Add New Address',
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
                                hintText: _hintTexts[entry.key],
                                filled: true,
                                fillColor: Colors.white,
                                prefixIcon: Icon(_icons[entry.key],
                                    color: Color(0xFF651D32)),
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
                                      ? Color(0xFF651D32)
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
                            final currentUser =
                                firebase_auth.FirebaseAuth.instance.currentUser;
                            if (currentUser == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('User not logged in')),
                              );
                              return;
                            }
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

                            // Validations
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

                            if (street.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('Please enter street details.')),
                              );
                              return;
                            }

                            if (barangay.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('Please enter your barangay.')),
                              );
                              return;
                            }

                            if (city.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Please enter your city or municipality.')),
                              );
                              return;
                            }

                            if (province.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('Please enter your province.')),
                              );
                              return;
                            }
                            try {
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(currentUser.uid)
                                  .collection('addresses')
                                  .add({
                                'name': _controllers['Name']!.text,
                                'phone': _controllers['Mobile Number']!.text,
                                'street':
                                    _controllers['Flat No. Street Details']!
                                        .text,
                                'barangay': _controllers['Barangay']!.text,
                                'cityOrMunicipality':
                                    _controllers['City/Municipality']!.text,
                                'province': _controllers['Province']!.text,
                                'addressType': addressType,
                                'timestamp': FieldValue.serverTimestamp(),
                              });

                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 30, horizontal: 20),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.check_circle,
                                            color: Color(0xFF651D32), size: 60),
                                        const SizedBox(height: 20),
                                        Text(
                                          'Address Added\nSuccessfully!',
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
                                              Navigator.pop(
                                                  context); // Close dialog
                                              Navigator.pop(context); // Go back
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Color(0xFF651D32),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
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
                                SnackBar(
                                    content: Text('Error saving address: $e')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF651D32),
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

    // Ensure it starts with +63
    if (!text.startsWith('+63')) {
      text = '+63' + text.replaceAll(RegExp(r'^\+?63?'), '');
    }

    // Only allow digits after +63
    if (text.length > 3) {
      String prefix = text.substring(0, 3);
      String digits = text.substring(3).replaceAll(RegExp(r'\D'), '');
      text = prefix + digits;
    }

    // Limit to 13 characters
    if (text.length > 13) {
      text = text.substring(0, 13);
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
