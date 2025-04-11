import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
void main() {
  runApp(const MyApp());
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
  bool useAsDefault = false;

  final _controllers = {
    'Name': TextEditingController(text: 'David Guetta'),
    'Mobile Number': TextEditingController(text: '+1-202 555 0143'),
    'Flat No. Street Details':
        TextEditingController(text: '3891 Ranchview Dr.\nRichardson, California 62639'),
    'Barangay': TextEditingController(text: 'Walmart'),
    'Province': TextEditingController(text: 'California'),
    'City/District': TextEditingController(text: 'Los Angeles'),
  };
  final Map<String, IconData> _icons = {
    'Name': Icons.person,
    'Mobile Number': Icons.phone,
    'Flat No. Street Details': Icons.home_work,
    'Barangay': Icons.location_on,
    'Province': Icons.map,
    'City/District': Icons.location_city,
  };
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title:  Text('Add New Address', 
            style: GoogleFonts.poppins(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
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
                              maxLines: entry.key == 'Flat No. Street Details' ? null : 1,
                              decoration: InputDecoration(
                                labelText: entry.key,
                                filled: true,
                                fillColor: Colors.white,
                                 prefixIcon: Icon(_icons[entry.key], color: Color(0xFF651D32)),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 18),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade300, width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: Colors.blue, width: 1.5),
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
                                margin: const EdgeInsets.symmetric(horizontal: 6),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: isSelected ? Color(0xFF651D32) : Colors.grey.shade100,
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
                                      color: isSelected ? Colors.white : Colors.black,
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
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF651D32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            "Save Address",
                            style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
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
