import 'package:flutter/material.dart';

enum ProviderType {
  doctor,
  nurse,
  physiotherapist,
  caregiver,
  counselor,
  other;

  // Add display name
  String get displayName {
    switch (this) {
      case ProviderType.doctor:
        return 'Doctor';
      case ProviderType.nurse:
        return 'Nurse';
      case ProviderType.physiotherapist:
        return 'Physiotherapist';
      case ProviderType.caregiver:
        return 'Caregiver';
      case ProviderType.counselor:
        return 'Counselor';
      case ProviderType.other:
        return 'Other';
    }
  }

  // Add color (if needed)
  Color get color {
    switch (this) {
      case ProviderType.doctor:
        return Color(0xFF42A5F5);
      case ProviderType.nurse:
        return Color(0xFF66BB6A);
      case ProviderType.physiotherapist:
        return Color(0xFFFFA726);
      case ProviderType.caregiver:
        return Color(0xFFEF5350);
      case ProviderType.counselor:
        return Color(0xFF26C6DA);
      case ProviderType.other:
        return Color(0xFF9E9E9E);
    }
  }
}