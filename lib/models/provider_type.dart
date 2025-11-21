 import 'package:flutter/material.dart';

enum ProviderType {
  doctor(Color(0xFF42A5F5)),
  nurse(Color(0xFF66BB6A)),
  physiotherapist(Color(0xFFFFA726)),
  caregiver(Color(0xFFEF5350)),
  counselor(Color(0xFF26C6DA)),
  other(Color(0xFF9E9E9E));

  final Color color;
  const ProviderType(this.color);
}