import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ManageProduct.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class EditProductScreen extends StatefulWidget {
  final String productId;
  final Map<String, dynamic> productData;
  final String sellerId;
  final String userId;

  const EditProductScreen({
    super.key,
    required this.productId,
    required this.productData,
    required this.sellerId,
    required this.userId,
  });

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _productName;
  late String _productDescription;
  late double _productPrice;
  late int _productStock;
  late String _selectedCategory;
  late String? _productImageUrl;

  Uint8List? _webImage;

  final List<String> _categories = ['Clothes', 'School', 'Sports', 'Foods'];

  @override
  void initState() {
    super.initState();
    _productName = widget.productData['productName'];
    _productDescription = widget.productData['description'];
    _productPrice = (widget.productData['price']).toDouble();
    _productStock = (widget.productData['stock']);
    _selectedCategory = widget.productData['category'];
    _productImageUrl = widget.productData['imageUrl'];
  }

  // ignore: unused_element
  Future<void> _pickAndUploadNewImage() async {
    final supabase = Supabase.instance.client;

    try {
      final pickedImage = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxHeight: 1024,
        maxWidth: 1024,
        imageQuality: 80,
      );

      if (pickedImage == null) return;

      final bytes = await pickedImage.readAsBytes();

      // Detect file extension
      String? fileExtension;
      if (bytes.length >= 8) {
        if (bytes[0] == 0x89 && bytes[1] == 0x50) {
          fileExtension = 'png';
        } else if (bytes[0] == 0xFF && bytes[1] == 0xD8) {
          fileExtension = 'jpg';
        }
      }
      fileExtension ??= 'jpg';

      final newFileName =
          'products/${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      final contentType = fileExtension == 'png' ? 'image/png' : 'image/jpeg';

      // 🛠 Correct Delete Old Image
      if (_productImageUrl != null && _productImageUrl!.isNotEmpty) {
        final uri = Uri.parse(_productImageUrl!);
        final uploadsIndex = uri.pathSegments.indexOf('uploads');
        if (uploadsIndex != -1 && uploadsIndex + 1 < uri.pathSegments.length) {
          final oldImagePath =
              uri.pathSegments.sublist(uploadsIndex + 1).join('/');
          await supabase.storage.from('uploads').remove([oldImagePath]);
          print("Deleted old image: $oldImagePath");
        }
      }

      // Upload new image
      await supabase.storage.from('uploads').uploadBinary(
            newFileName,
            bytes,
            fileOptions: FileOptions(
              contentType: contentType,
              upsert: true,
            ),
          );

      // Get public URL
      String rawUrl =
          supabase.storage.from('uploads').getPublicUrl(newFileName);
      final publicUrl =
          '$rawUrl?t=${DateTime.now().millisecondsSinceEpoch}'; // avoid cache

      setState(() {
        _productImageUrl = publicUrl;
        if (kIsWeb) {
          _webImage = bytes;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product image updated')),
      );
    } catch (e) {
      print("Image upload error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    }
  }

  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxHeight: 1024,
      maxWidth: 1024,
      imageQuality: 80,
    );

    if (pickedImage == null) return;

    final bytes = await pickedImage.readAsBytes();
    setState(() {
      _webImage = bytes;
    });
  }

  Future<void> _updateProduct() async {
    try {
      final supabase = Supabase.instance.client;
      String? newImageUrl = _productImageUrl;
      String? oldImagePath;

      // Upload the new image if user picked one
      if (_webImage != null) {
        // Delete the old image if exists
        if (_productImageUrl != null && _productImageUrl!.isNotEmpty) {
          final uri = Uri.parse(_productImageUrl!);
          final uploadsIndex = uri.pathSegments.indexOf('uploads');
          if (uploadsIndex != -1 &&
              uploadsIndex + 1 < uri.pathSegments.length) {
            oldImagePath = uri.pathSegments.sublist(uploadsIndex + 1).join('/');
            await supabase.storage.from('uploads').remove([oldImagePath]);
            print("Deleted old image: $oldImagePath");
          }
        }

        // Determine the file type
        String fileExtension = 'jpg';
        if (_webImage!.length >= 8) {
          if (_webImage![0] == 0x89 && _webImage![1] == 0x50) {
            fileExtension = 'png';
          }
        }

        final newFileName =
            'products/${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
        final contentType = fileExtension == 'png' ? 'image/png' : 'image/jpeg';

        await supabase.storage.from('uploads').uploadBinary(
              newFileName,
              _webImage!,
              fileOptions: FileOptions(
                contentType: contentType,
                upsert: true,
              ),
            );

        String rawUrl =
            supabase.storage.from('uploads').getPublicUrl(newFileName);
        newImageUrl =
            '$rawUrl?t=${DateTime.now().millisecondsSinceEpoch}'; // to avoid cache
      }

      // 🔥 Update Firestore with new product data
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('sellerInfo')
          .doc(widget.sellerId)
          .collection('products')
          .doc(widget.productId)
          .update({
        'productName': _productName,
        'description': _productDescription,
        'price': _productPrice,
        'stock': _productStock,
        'category': _selectedCategory,
        'imageUrl': newImageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product updated successfully!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => Manageproduct()),
      );
    } catch (e) {
      debugPrint("Update error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update product: $e')),
      );
    }
  }

  // ignore: unused_element
  void _showImagePreview(BuildContext context) {
    if (_productImageUrl == null && _webImage == null) return;

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: InteractiveViewer(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _webImage != null
                  ? Image.memory(_webImage!, fit: BoxFit.contain)
                  : Image.network(_productImageUrl!, fit: BoxFit.contain),
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
        title: const Text('Edit Product'),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildImageSection(),
                  _buildFormFields(),
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
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            _updateProduct();
                          }
                        },
                        child: Text('Save Changes',
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

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Product Image',
            style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF800000))),
        const SizedBox(height: 8),
        Text('Click to replace the product image',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 12),
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey[100],
          ),
          child: GestureDetector(
            onTap: () async {
              await _pickImage(); // pick only
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Image ready. Save to upload.')),
              );
            },
            child: _webImage != null || _productImageUrl != null
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _webImage != null
                            ? Image.memory(_webImage!, fit: BoxFit.cover)
                            : Image.network(_productImageUrl!,
                                fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit,
                              size: 16, color: Colors.red),
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload,
                            size: 40, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text('Upload Product Image',
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: Colors.grey.shade500)),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        _buildFormField(
          label: 'Product Name',
          initialValue: _productName,
          onSaved: (val) => _productName = val!,
        ),
        _buildFormField(
          label: 'Description',
          initialValue: _productDescription,
          maxLines: 3,
          onSaved: (val) => _productDescription = val!,
        ),
        Row(
          children: [
            Expanded(
              child: _buildFormField(
                label: 'Price (PHP)',
                initialValue: _productPrice.toString(),
                keyboardType: TextInputType.number,
                onSaved: (val) => _productPrice = double.parse(val!),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildFormField(
                label: 'Stock',
                initialValue: _productStock.toString(),
                keyboardType: TextInputType.number,
                onSaved: (val) => _productStock = int.parse(val!),
              ),
            ),
          ],
        ),
        _buildDropdownField(),
      ],
    );
  }

  Widget _buildFormField({
    required String label,
    String? initialValue,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
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
          initialValue: initialValue,
          decoration: _inputDecoration(hint: 'Enter $label'),
          maxLines: maxLines,
          keyboardType: keyboardType,
          onSaved: onSaved,
        ),
      ],
    );
  }

  Widget _buildDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text('Category',
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF800000))),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          decoration: _inputDecoration(hint: 'Select Category'),
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          borderRadius: BorderRadius.circular(10),
          style: const TextStyle(fontSize: 14, color: Colors.black),
          items: _categories
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (value) => setState(() => _selectedCategory = value!),
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
