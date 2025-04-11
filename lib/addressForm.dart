import 'package:flutter/material.dart';

class AddressFormScreen extends StatefulWidget {
  final String? name;
  final String? address;
  final String? type;
  final bool? isDefault;

  const AddressFormScreen({
    super.key,
    this.name,
    this.address,
    this.type,
    this.isDefault,
  });

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  late String? selectedAddressType;
  late bool useAsDefault;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController addressLine1Controller = TextEditingController();
  final TextEditingController addressLine2Controller = TextEditingController();
  final TextEditingController landmarkController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedAddressType = widget.type ?? 'Home';
    useAsDefault = widget.isDefault ?? false;

    if (widget.name != null) {
      nameController.text = widget.name!;
    }
    if (widget.address != null) {
      final parts = widget.address!.split('\n');
      addressLine1Controller.text = parts[0];
      if (parts.length > 1) {
        final cityStateZip = parts[1].split(' ');
        if (cityStateZip.length >= 2) {
          cityController.text = cityStateZip[0];
          pincodeController.text = cityStateZip[1];
        }
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    addressLine1Controller.dispose();
    addressLine2Controller.dispose();
    landmarkController.dispose();
    pincodeController.dispose();
    stateController.dispose();
    cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.name == null ? 'Add New Address' : 'Edit Address',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF800000), // Maroon color
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTextField(
                                controller: nameController,
                                label: 'Name',
                                icon: Icons.person_outline,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: mobileController,
                                label: 'Mobile Number',
                                icon: Icons.phone_android_outlined,
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: addressLine1Controller,
                                label: 'Flat No. & Street Details',
                                icon: Icons.home_outlined,
                                maxLines: 2,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: landmarkController,
                                label: 'Barangay/Locality',
                                icon: Icons.location_on_outlined,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: cityController,
                                label: 'City/District',
                                icon: Icons.location_city_outlined,
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'Address Type',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: [
                                  _buildChoiceChip('Home'),
                                  _buildChoiceChip('Office'),
                                  _buildChoiceChip('School'),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF800000), // Maroon color
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              widget.name == null ? 'Save Address' : 'Update Address',
                              style: const TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF800000)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF800000)),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
    );
  }

  Widget _buildChoiceChip(String label) {
    return ChoiceChip(
      label: Text(label),
      selected: selectedAddressType == label,
      onSelected: (selected) {
        setState(() {
          selectedAddressType = selected ? label : null;
        });
      },
      selectedColor: const Color(0xFF800000),
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: selectedAddressType == label
            ? Colors.white
            : const Color(0xFF800000),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Color(0xFF800000)),
      ),
    );
  }
}
