import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ManageProduct.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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
          appId: "1:533992551897:web:d04a482ad131a0700815c8"),
    );
  } else {
    await Firebase.initializeApp(); // Mobile config
  }
  await Supabase.initialize(
    url:
        'https://haoiqctsijynxwfoaspm.supabase.co', // Replace with your Supabase URL
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhhb2lxY3RzaWp5bnh3Zm9hc3BtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQxNzU3MDMsImV4cCI6MjA1OTc1MTcwM30.7kilmu9kxrABgg4ZMz9GIHm5Jv4LHLAIYR1_8q1eDEI', // Replace with your Supabase anon key
  );
  runApp(MyApp());
}

Future<String?> uploadProductImageToSupabase(
    Uint8List fileBytes, String productId) async {
  final supabase = Supabase.instance.client;

  // Detect file type
  String? fileExtension;
  if (fileBytes.length >= 8) {
    if (fileBytes[0] == 0x89 &&
        fileBytes[1] == 0x50 &&
        fileBytes[2] == 0x4E &&
        fileBytes[3] == 0x47) {
      fileExtension = 'png';
    } else if (fileBytes[0] == 0xFF && fileBytes[1] == 0xD8) {
      fileExtension = 'jpg';
    }
  }
  fileExtension ??= 'jpg';

  final fileName = 'products/$productId.$fileExtension';
  final contentType = fileExtension == 'png' ? 'image/png' : 'image/jpeg';

  try {
    final response = await supabase.storage.from('uploads').uploadBinary(
          fileName,
          fileBytes,
          fileOptions: FileOptions(contentType: contentType),
        );

    if (response.isEmpty) throw Exception('Upload failed with empty response');

    final publicUrl = supabase.storage.from('uploads').getPublicUrl(fileName);
    return publicUrl;
  } catch (e) {
    print('Error uploading product image: $e');
    return null;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LSPUMART',
      theme: ThemeData(
        primarySwatch: Colors.red,
        primaryColor: const Color(0xFF800000),
        fontFamily: 'Poppins',
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF800000),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const AddProductScreen(),
    );
  }
}

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  // ignore: unused_field
  String _productName = '';
  // ignore: unused_field
  String _productDescription = '';
  // ignore: unused_field
  double _productPrice = 0;
  // ignore: unused_field
  int _productStock = 0;
  String _selectedCategory = 'Clothes';
  final List<String> _categories = ['Clothes', 'School', 'Sports', 'Foods'];

  String? _productImage;
  Uint8List? _webImage;

  Future<void> _pickImage() async {
    try {
      final pickedImage = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxHeight: 1024,
        maxWidth: 1024,
        imageQuality: 80,
      );

      if (pickedImage != null) {
        if (kIsWeb) {
          final bytes = await pickedImage.readAsBytes();
          setState(() {
            _webImage = bytes;
            _productImage = pickedImage.name;
          });
        } else {
          setState(() {
            _productImage = pickedImage.path;
          });
        }
      }
    } catch (e) {
      debugPrint("Image pick error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to pick image: $e")),
      );
    }
  }

  void _showImagePreview(BuildContext context) {
    if (_productImage == null) return;

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: InteractiveViewer(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: kIsWeb
                  ? Image.memory(_webImage!, fit: BoxFit.contain)
                  : Image.file(File(_productImage!), fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Add New Product',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Manageproduct(),
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Text('Product Image',
                      style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF800000))),
                  const SizedBox(height: 8),
                  Text(
                    'Add image of your product. (PNG/JPG)',
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 180,
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey[100],
                    ),
                    child: _productImage == null
                        ? Center(
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.cloud_upload,
                                      size: 40, color: Colors.grey.shade400),
                                  const SizedBox(height: 8),
                                  Text('Click to upload image',
                                      style: GoogleFonts.poppins(
                                          color: Colors.grey.shade500,
                                          fontSize: 12)),
                                ],
                              ),
                            ),
                          )
                        : Stack(
                            children: [
                              GestureDetector(
                                onTap: () => _showImagePreview(context),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: kIsWeb
                                      ? Image.memory(
                                          _webImage!,
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.file(
                                          File(_productImage!),
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _productImage = null;
                                      _webImage = null;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close,
                                        size: 14, color: Colors.red),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                  _buildFormField(
                    label: 'Product Name',
                    hint: 'Enter product name',
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter product name'
                        : null,
                    onSaved: (value) => _productName = value!,
                  ),
                  _buildFormField(
                    label: 'Description',
                    hint: 'Enter product description',
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter product description';
                      }
                      if (value.length < 20) {
                        return 'Description should be at least 20 characters';
                      }
                      return null;
                    },
                    onSaved: (value) => _productDescription = value!,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFormField(
                          label: 'Price (PHP)',
                          hint: '0.00',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter price';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Invalid price';
                            }
                            return null;
                          },
                          onSaved: (value) =>
                              _productPrice = double.parse(value!),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildFormField(
                          label: 'Stock',
                          hint: '0',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter stock';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Invalid number';
                            }
                            return null;
                          },
                          onSaved: (value) => _productStock = int.parse(value!),
                        ),
                      ),
                    ],
                  ),
                  _buildDropdownField(
                    label: 'Category',
                    value: _selectedCategory,
                    items: _categories,
                    onChanged: (value) =>
                        setState(() => _selectedCategory = value!),
                  ),
                ]),
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: [
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 4,
                          backgroundColor: const Color(0xFF800000),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();

                            if (_productImage == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Please upload a product image')),
                              );
                              return;
                            }

                            try {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (_) => const Center(
                                    child: CircularProgressIndicator()),
                              );

                              // 1. Convert image to bytes
                              final bytes = kIsWeb
                                  ? _webImage!
                                  : await File(_productImage!).readAsBytes();

                              // 2. Upload image to Supabase
                              final productId = DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString(); // Unique ID for filename
                              final imageUrl =
                                  await uploadProductImageToSupabase(
                                      bytes, productId);

                              if (imageUrl == null) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Image upload failed')),
                                );
                                return;
                              }

                              // 3. Get seller info from Firestore
                              final userId =
                                  FirebaseAuth.instance.currentUser!.uid;
                              final sellerDoc = await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(userId)
                                  .collection('sellerInfo')
                                  .get();

                              if (sellerDoc.docs.isEmpty) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Seller information not found')),
                                );
                                return;
                              }

                              final sellerId = sellerDoc.docs.first.id;

                              // 4. Save product to Firestore
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(userId)
                                  .collection('sellerInfo')
                                  .doc(sellerId)
                                  .collection('products')
                                  .doc(productId) // ✅ set document ID manually
                                  .set({
                                'productName': _productName,
                                'description': _productDescription,
                                'price': _productPrice,
                                'stock': _productStock,
                                'category': _selectedCategory,
                                'imageUrl': imageUrl,
                                'sellerId': sellerId,
                                'createdAt': FieldValue.serverTimestamp(),
                              });

                              Navigator.of(context)
                                  .pop(); // Close loading dialog

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Product added successfully!')),
                              );

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>Manageproduct()),
                              );
                            } catch (e) {
                              Navigator.of(context).pop(); // Close loading
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed: $e')),
                              );
                            }
                          }
                        },
                        child: Text('Add Product',
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(label,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF800000))),
        const SizedBox(height: 8),
        TextFormField(
          decoration: _inputDecoration(hint: hint),
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          onSaved: onSaved,
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          label,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF800000)),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: _inputDecoration(hint: 'Select $label'),
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          borderRadius: BorderRadius.circular(10),
          style: const TextStyle(fontSize: 14, color: Colors.black),
          validator: (val) =>
              val == null || val.isEmpty ? 'Please select $label' : null,
          items: items
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF800000)),
      ),
    );
  }
}
