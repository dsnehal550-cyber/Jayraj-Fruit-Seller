class CustomerAddress {
  const CustomerAddress({
    required this.name,
    required this.mobile,
    required this.house,
    required this.street,
    required this.city,
    required this.pin,
    this.landmark,
    this.latitude,
    this.longitude,
  });

  final String name;
  final String mobile;
  final String house;
  final String street;
  final String city;
  final String pin;
  final String? landmark;
  final double? latitude;
  final double? longitude;

  Map<String, dynamic> toJson() => {
        'name': name,
        'mobile': mobile,
        'house': house,
        'street': street,
        'city': city,
        'pin': pin,
        'landmark': landmark,
        'latitude': latitude,
        'longitude': longitude,
      };

  factory CustomerAddress.fromJson(Map<String, dynamic> json) {
    return CustomerAddress(
      name: (json['name'] ?? '').toString(),
      mobile: (json['mobile'] ?? '').toString(),
      house: (json['house'] ?? '').toString(),
      street: (json['street'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      pin: (json['pin'] ?? '').toString(),
      landmark: json['landmark']?.toString(),
      latitude: json['latitude'] is num ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] is num ? (json['longitude'] as num).toDouble() : null,
    );
  }

  String toFormattedString() {
    return '$name, $house, $street${landmark != null && landmark!.isNotEmpty ? ', $landmark' : ''}, $city - $pin ($mobile)';
  }
}
