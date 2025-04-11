import 'package:flutter/material.dart';
import 'profile.dart';
import 'package:google_fonts/google_fonts.dart';
import 'addressForm.dart';
import 'EditAddressForm.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Delivery Address',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const AddressListScreen(),
    );
  }
}

class AddressListScreen extends StatelessWidget {
  const AddressListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        elevation: 0.5,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            );
          },
        ),
        title: Text(
          "Delivery Address",
          style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold, fontSize: isSmallScreen ? 20 : 24),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF651D32)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddAddressPage()),
                );
              },
              child: Text(
                "+ New Address",
                style: GoogleFonts.poppins(color: Color(0xFF651D32), fontWeight: FontWeight.w500),
              ),
            ),
          )
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Addresses",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: isSmallScreen ? 18 : 20,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1A000000),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text(
                            "Home",
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500, fontSize: isSmallScreen ? 16 : 18),
                          ),
                          const SizedBox(height: 4),
                           Text(
                            "David Guetta",
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700, fontSize: isSmallScreen ? 16 : 18),
                          ),
                          const SizedBox(height: 2),
                           Text(
                            "2972 Westheimer Rd. Santa Ana, Illinois 85486",
                            style:
                                GoogleFonts.poppins(color: Colors.grey, fontSize: isSmallScreen ? 14 : 16),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            EditAddressPage()),
                                  );
                                },
                                icon: const Icon(Icons.edit,
                                    size: 16, color: Colors.blue),
                                label:  Text("Edit",
                                    style: GoogleFonts.poppins(color: Colors.blue)),
                                style: TextButton.styleFrom(
                                  minimumSize: Size.zero,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.delete_outline,
                                    size: 16, color: Colors.red),
                                label: Text("Remove",
                                    style: GoogleFonts.poppins(color: Colors.red)),
                                style: TextButton.styleFrom(
                                  minimumSize: Size.zero,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
