import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/customer_address.dart';
import '../services/location_service.dart';

class AddressFormScreen extends StatefulWidget {
  const AddressFormScreen({super.key});

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _houseController = TextEditingController();
  final _streetController = TextEditingController();
  final _landmarkController = TextEditingController();
  String _selectedCity = 'CSN';
  final _pinController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _houseController.dispose();
    _streetController.dispose();
    _landmarkController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);

    final addressStr = '${_houseController.text}, ${_streetController.text}, $_selectedCity, ${_pinController.text}';
    final coords = await LocationService.getCoordinatesFromAddress(addressStr);

    final address = CustomerAddress(
      name: _nameController.text.trim(),
      mobile: _mobileController.text.trim(),
      house: _houseController.text.trim(),
      street: _streetController.text.trim(),
      city: _selectedCity,
      pin: _pinController.text.trim(),
      landmark: _landmarkController.text.trim(),
      latitude: coords?.latitude,
      longitude: coords?.longitude,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('customer_saved_address', jsonEncode(address.toJson()));

    if (!mounted) return;
    Navigator.of(context).pop(address);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Address'),
        backgroundColor: const Color(0xFF2E8B57),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF5F7F2),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Delivery Details',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF1F2A1F)),
                ),
                const SizedBox(height: 20),
                _buildTextField('Full Name', _nameController, Icons.person_outline_rounded),
                const SizedBox(height: 16),
                _buildTextField('Mobile Number', _mobileController, Icons.phone_android_rounded, keyboardType: TextInputType.phone),
                const SizedBox(height: 16),
                _buildTextField('House/Flat/Building', _houseController, Icons.home_work_outlined),
                const SizedBox(height: 16),
                _buildTextField('Street/Area', _streetController, Icons.add_road_rounded),
                const SizedBox(height: 16),
                _buildTextField('Landmark (Optional)', _landmarkController, Icons.landscape_rounded, isRequired: false),
                const SizedBox(height: 16),
                const Text('City', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1F2A1F))),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedCity,
                      items: const [
                        DropdownMenuItem(value: 'CSN', child: Text('CSN')),
                        DropdownMenuItem(value: 'Aurangabad', child: Text('Aurangabad')),
                        DropdownMenuItem(value: 'Pune', child: Text('Pune')),
                        DropdownMenuItem(value: 'Nagpur', child: Text('Nagpur')),
                        DropdownMenuItem(value: 'Mumbai', child: Text('Mumbai')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCity = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildTextField('Pincode', _pinController, Icons.pin_drop_outlined, keyboardType: TextInputType.number),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveAddress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E8B57),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isSaving
                        ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Save Address', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {TextInputType keyboardType = TextInputType.text, bool isRequired = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1F2A1F))),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: isRequired ? (val) => val == null || val.trim().isEmpty ? 'Please enter $label' : null : null,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF2E8B57)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}
