import 'package:flutter/material.dart';

class FruitItem {
  const FruitItem({
    required this.id,
    required this.name,
    required this.image,
    required this.pricePerKg,
    required this.availability,
    required this.stockQuantity,
    required this.description,
    required this.category,
    this.accentColor = const Color(0xFF2E8B57),
    this.icon = Icons.apple_rounded,
  });

  final String id;
  final String name;
  final String image;
  final double pricePerKg;
  final bool availability;
  final double stockQuantity;
  final String description;
  final String category;
  final Color accentColor;
  final IconData icon;

  bool get isAvailable => availability && stockQuantity > 0;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'image': image,
        'pricePerKg': pricePerKg,
        'availability': availability,
        'stockQuantity': stockQuantity,
        'description': description,
        'category': category,
      };

  factory FruitItem.fromJson(Map<String, dynamic> json) {
    return FruitItem(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      image: (json['image'] ?? '').toString(),
      pricePerKg: (json['pricePerKg'] as num?)?.toDouble() ?? 0.0,
      availability: (json['availability'] as bool?) ?? true,
      stockQuantity: (json['stockQuantity'] as num?)?.toDouble() ?? 0.0,
      description: (json['description'] ?? '').toString(),
      category: (json['category'] ?? 'Fresh Fruits').toString(),
    );
  }
}
