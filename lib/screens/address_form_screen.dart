import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/customer_address.dart';
import '../services/location_service.dart';

typedef CustomerLocationProvider =
    Future<({double latitude, double longitude})> Function();

class AddressFormScreen extends StatefulWidget {
  const AddressFormScreen({
    this.initialAddress,
    this.locationProvider,
    super.key,
  });

  final CustomerAddress? initialAddress;
  final CustomerLocationProvider? locationProvider;

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
  String _selectedCity = defaultCustomerCity;
  final _pinController = TextEditingController();

  bool _isSaving = false;
  bool _isSelectingLocation = false;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    final address = widget.initialAddress;
    if (address == null) return;

    _nameController.text = address.name;
    _mobileController.text = address.mobile;
    _houseController.text = address.house;
    _streetController.text = address.street;
    _landmarkController.text = address.landmark ?? '';
    _pinController.text = address.pin;
    _latitude = address.latitude;
    _longitude = address.longitude;
  }

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
    if (!_hasValidLocation) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Select a valid delivery location before saving this address.',
          ),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final address = CustomerAddress(
      name: _nameController.text.trim(),
      mobile: _mobileController.text.trim(),
      house: _houseController.text.trim(),
      street: _streetController.text.trim(),
      city: _selectedCity,
      pin: _pinController.text.trim(),
      landmark: _landmarkController.text.trim(),
      latitude: _latitude,
      longitude: _longitude,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'customer_saved_address',
      jsonEncode(address.toJson()),
    );

    if (!mounted) return;
    Navigator.of(context).pop(address);
  }

  bool get _hasValidLocation {
    final latitude = _latitude;
    final longitude = _longitude;
    return latitude != null &&
        longitude != null &&
        latitude.isFinite &&
        longitude.isFinite &&
        latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }

  Future<void> _selectCurrentLocation() async {
    setState(() => _isSelectingLocation = true);
    try {
      final coordinates = widget.locationProvider == null
          ? await _requestCurrentCoordinates()
          : await widget.locationProvider!();
      if (!mounted) return;
      _setLocation(coordinates.latitude, coordinates.longitude);
    } on LocationException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _isSelectingLocation = false);
    }
  }

  Future<void> _findEnteredAddressLocation() async {
    final street = _streetController.text.trim();
    if (street.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a street or area before locating it.')),
      );
      return;
    }

    setState(() => _isSelectingLocation = true);
    try {
      final address =
          '${_houseController.text}, $street, $_selectedCity, '
          '${_pinController.text}';
      final location = await LocationService.getCoordinatesFromAddress(address);
      if (location == null) {
        throw const LocationException(
          'Could not find this address on the map. Check the street, city, and pincode, or select your current location.',
        );
      }
      if (!mounted) return;
      _setLocation(location.latitude, location.longitude);
    } on LocationException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _isSelectingLocation = false);
    }
  }

  void _setLocation(double latitude, double longitude) {
    if (!latitude.isFinite ||
        !longitude.isFinite ||
        latitude < -90 ||
        latitude > 90 ||
        longitude < -180 ||
        longitude > 180) {
      throw const LocationException(
        'The selected location has invalid coordinates. Try again.',
      );
    }
    setState(() {
      _latitude = latitude;
      _longitude = longitude;
    });
  }

  Future<({double latitude, double longitude})>
  _requestCurrentCoordinates() async {
    final position = await LocationService.requestPosition();
    return (latitude: position.latitude, longitude: position.longitude);
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
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F2A1F),
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  'Full Name',
                  _nameController,
                  Icons.person_outline_rounded,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'Mobile Number',
                  _mobileController,
                  Icons.phone_android_rounded,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'House/Flat/Building',
                  _houseController,
                  Icons.home_work_outlined,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'Street/Area',
                  _streetController,
                  Icons.add_road_rounded,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'Landmark (Optional)',
                  _landmarkController,
                  Icons.landscape_rounded,
                  isRequired: false,
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _isSelectingLocation
                      ? null
                      : _selectCurrentLocation,
                  icon: _isSelectingLocation
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location),
                  label: Text(
                    _hasValidLocation
                        ? 'Change delivery location'
                        : 'Select delivery location',
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _isSelectingLocation
                      ? null
                      : _findEnteredAddressLocation,
                  icon: const Icon(Icons.place_outlined),
                  label: const Text('Find entered address on map'),
                ),
                if (_hasValidLocation)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Location selected (${_latitude!.toStringAsFixed(5)}, '
                      '${_longitude!.toStringAsFixed(5)})',
                      style: const TextStyle(color: Color(0xFF2E8B57)),
                    ),
                  ),
                const SizedBox(height: 16),
                const Text(
                  'City',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2A1F),
                  ),
                ),
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
                        DropdownMenuItem(
                          value: defaultCustomerCity,
                          child: Text(defaultCustomerCity),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCity = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'Pincode',
                  _pinController,
                  Icons.pin_drop_outlined,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveAddress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E8B57),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Save Address',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
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

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    bool isRequired = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2A1F),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: isRequired
              ? (val) => val == null || val.trim().isEmpty
                    ? 'Please enter $label'
                    : null
              : null,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF2E8B57)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
