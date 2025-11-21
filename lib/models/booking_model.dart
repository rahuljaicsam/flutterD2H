class Booking {
  final String id;
  final String patientId;
  final String patientName;
  final String patientPhone;
  final String providerId;
  final ProviderType providerType;
  final String service;
  final DateTime scheduledDate;
  final String address;
  final Map<String, dynamic> patientLocation;
  final BookingStatus status;
  final double amount;
  final DateTime createdAt;
  final String? notes;
  final DateTime? acceptedAt;
  final DateTime? declinedAt;
  final DateTime? completedAt;
  final String? declineReason;

  Booking({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.patientPhone,
    required this.providerId,
    required this.providerType,
    required this.service,
    required this.scheduledDate,
    required this.address,
    required this.patientLocation,
    required this.status,
    required this.amount,
    required this.createdAt,
    this.notes,
    this.acceptedAt,
    this.declinedAt,
    this.completedAt,
    this.declineReason,
  });

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'] ?? '',
      patientId: map['patientId'] ?? '',
      patientName: map['patientName'] ?? '',
      patientPhone: map['patientPhone'] ?? '',
      providerId: map['providerId'] ?? '',
      providerType: ProviderType.values.firstWhere(
        (e) => e.toString() == 'ProviderType.${map['providerType']}',
        orElse: () => ProviderType.doctor,
      ),
      service: map['service'] ?? '',
      scheduledDate: map['scheduledDate']?.toDate() ?? DateTime.now(),
      address: map['address'] ?? '',
      patientLocation: Map<String, dynamic>.from(map['patientLocation'] ?? {}),
      status: BookingStatus.values.firstWhere(
        (e) => e.toString() == 'BookingStatus.${map['status']}',
        orElse: () => BookingStatus.pending,
      ),
      amount: (map['amount'] ?? 0.0).toDouble(),
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      notes: map['notes'],
      acceptedAt: map['acceptedAt']?.toDate(),
      declinedAt: map['declinedAt']?.toDate(),
      completedAt: map['completedAt']?.toDate(),
      declineReason: map['declineReason'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'patientName': patientName,
      'patientPhone': patientPhone,
      'providerId': providerId,
      'providerType': providerType.toString().split('.').last,
      'service': service,
      'scheduledDate': scheduledDate,
      'address': address,
      'patientLocation': patientLocation,
      'status': status.toString().split('.').last,
      'amount': amount,
      'createdAt': createdAt,
      'notes': notes,
      'acceptedAt': acceptedAt,
      'declinedAt': declinedAt,
      'completedAt': completedAt,
      'declineReason': declineReason,
    };
  }

  Booking copyWith({
    String? id,
    String? patientId,
    String? patientName,
    String? patientPhone,
    String? providerId,
    ProviderType? providerType,
    String? service,
    DateTime? scheduledDate,
    String? address,
    Map<String, dynamic>? patientLocation,
    BookingStatus? status,
    double? amount,
    DateTime? createdAt,
    String? notes,
    DateTime? acceptedAt,
    DateTime? declinedAt,
    DateTime? completedAt,
    String? declineReason,
  }) {
    return Booking(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      patientPhone: patientPhone ?? this.patientPhone,
      providerId: providerId ?? this.providerId,
      providerType: providerType ?? this.providerType,
      service: service ?? this.service,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      address: address ?? this.address,
      patientLocation: patientLocation ?? this.patientLocation,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      declinedAt: declinedAt ?? this.declinedAt,
      completedAt: completedAt ?? this.completedAt,
      declineReason: declineReason ?? this.declineReason,
    );
  }
}

enum BookingStatus {
  pending,
  accepted,
  declined,
  inProgress,
  completed,
  cancelled,
}

extension BookingStatusExtension on BookingStatus {
  String get displayName {
    switch (this) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.accepted:
        return 'Accepted';
      case BookingStatus.declined:
        return 'Declined';
      case BookingStatus.inProgress:
        return 'In Progress';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case BookingStatus.pending:
        return const Color(0xFFFFA726);
      case BookingStatus.accepted:
        return const Color(0xFF66BB6A);
      case BookingStatus.declined:
        return const Color(0xFFEF5350);
      case BookingStatus.inProgress:
        return const Color(0xFF42A5F5);
      case BookingStatus.completed:
        return const Color(0xFF26C6DA);
      case BookingStatus.cancelled:
        return const Color(0xFF9E9E9E);
    }
  }
}
