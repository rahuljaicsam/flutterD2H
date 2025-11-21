import 'package:cloud_firestore/cloud_firestore.dart';
import 'provider_type.dart';

class HealthcareProvider {
  final String id;
  final String name;
  final String email;
  final String phone;
  final ProviderType type;
  final String licenseNumber;
  final bool isVerified;
  final String? profileImageUrl;
  final double rating;
  final int completedBookings;
  final String? specialization;
  final List<String> services;
  final DateTime createdAt;
  final Map<String, dynamic> location;

  HealthcareProvider({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.type,
    required this.licenseNumber,
    required this.isVerified,
    this.profileImageUrl,
    required this.rating,
    required this.completedBookings,
    this.specialization,
    required this.services,
    required this.createdAt,
    required this.location,
  });

  factory HealthcareProvider.fromMap(Map<String, dynamic> map) {
    return HealthcareProvider(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      type: ProviderType.values.firstWhere(
        (e) => e.toString() == 'ProviderType.${map['type']}',
        orElse: () => ProviderType.doctor,
      ),
      licenseNumber: map['licenseNumber'] ?? '',
      isVerified: map['isVerified'] ?? false,
      profileImageUrl: map['profileImageUrl'],
      rating: (map['rating'] ?? 0.0).toDouble(),
      completedBookings: map['completedBookings'] ?? 0,
      specialization: map['specialization'],
      services: List<String>.from(map['services'] ?? []),
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : (map['createdAt'] ?? DateTime.now()),
      location: Map<String, dynamic>.from(map['location'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'type': type.toString().split('.').last,
      'licenseNumber': licenseNumber,
      'isVerified': isVerified,
      'profileImageUrl': profileImageUrl,
      'rating': rating,
      'completedBookings': completedBookings,
      'specialization': specialization,
      'services': services,
      'createdAt': createdAt,
      'location': location,
    };
  }
}
