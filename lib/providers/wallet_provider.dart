import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/booking_model.dart';
import 'package:flutter/material.dart';

class WalletProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  List<Payment> _payments = [];
  double _totalEarnings = 0.0;
  double _pendingEarnings = 0.0;
  bool _isLoading = false;
  String? _errorMessage;

  List<Payment> get payments => _payments;
  double get totalEarnings => _totalEarnings;
  double get pendingEarnings => _pendingEarnings;
  double get availableEarnings => _totalEarnings - _pendingEarnings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  WalletProvider() {
    if (_auth.currentUser != null) {
      _loadWalletData();
    }
  }

  Future<void> _loadWalletData() async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final user = _auth.currentUser;
      if (user == null) return;

      final paymentsSnapshot = await _firestore
          .collection('providers')
          .doc(user.uid)
          .collection('payments')
          .orderBy('createdAt', descending: true)
          .get();

      _payments = paymentsSnapshot.docs
          .map((doc) => Payment.fromMap(doc.data()))
          .toList();

      _calculateEarnings();

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load wallet data';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  void _calculateEarnings() {
    _totalEarnings = 0.0;
    _pendingEarnings = 0.0;

    for (final payment in _payments) {
      if (payment.status == PaymentStatus.completed) {
        _totalEarnings += payment.amount;
      } else if (payment.status == PaymentStatus.pending) {
        _pendingEarnings += payment.amount;
      }
    }
  }

  Stream<List<Payment>> get paymentsStream {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('providers')
        .doc(user.uid)
        .collection('payments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Payment.fromMap(doc.data()))
            .toList());
  }

  Future<bool> addPaymentFromBooking(Booking booking) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final user = _auth.currentUser;
      if (user == null) return false;

      final payment = Payment(
        id: _firestore.collection('providers').doc(user.uid).collection('payments').doc().id,
        bookingId: booking.id,
        amount: booking.amount,
        type: PaymentType.earning,
        status: PaymentStatus.pending,
        createdAt: DateTime.now(),
        description: 'Payment for ${booking.service}',
        patientName: booking.patientName,
        scheduledDate: booking.scheduledDate,
      );

      await _firestore
          .collection('providers')
          .doc(user.uid)
          .collection('payments')
          .doc(payment.id)
          .set(payment.toMap());

      await _loadWalletData();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add payment';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updatePaymentStatus(String paymentId, PaymentStatus status) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final user = _auth.currentUser;
      if (user == null) return false;

      await _firestore
          .collection('providers')
          .doc(user.uid)
          .collection('payments')
          .doc(paymentId)
          .update({
        'status': status.toString().split('.').last,
        'processedAt': status == PaymentStatus.completed ? Timestamp.now() : null,
      });

      await _loadWalletData();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update payment status';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  List<Payment> getPaymentsByStatus(PaymentStatus status) {
    return _payments.where((payment) => payment.status == status).toList();
  }

  List<Payment> getPaymentsInDateRange(DateTime start, DateTime end) {
    return _payments.where((payment) {
      final paymentDate = payment.createdAt;
      return paymentDate.isAfter(start.subtract(const Duration(days: 1))) &&
             paymentDate.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  double getEarningsInDateRange(DateTime start, DateTime end) {
    final paymentsInRange = getPaymentsInDateRange(start, end);
    return paymentsInRange
        .where((p) => p.status == PaymentStatus.completed)
        .fold(0.0, (sum, payment) => sum + payment.amount);
  }

  Map<String, double> getMonthlyEarnings() {
    final Map<String, double> monthlyEarnings = {};
    
    for (final payment in _payments) {
      if (payment.status == PaymentStatus.completed) {
        final monthKey = '${payment.createdAt.year}-${payment.createdAt.month.toString().padLeft(2, '0')}';
        monthlyEarnings[monthKey] = (monthlyEarnings[monthKey] ?? 0.0) + payment.amount;
      }
    }
    
    return monthlyEarnings;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void refreshWallet() {
    if (_auth.currentUser != null) {
      _loadWalletData();
    }
  }
}

class Payment {
  final String id;
  final String bookingId;
  final double amount;
  final PaymentType type;
  final PaymentStatus status;
  final DateTime createdAt;
  final String description;
  final String patientName;
  final DateTime scheduledDate;
  final DateTime? processedAt;

  Payment({
    required this.id,
    required this.bookingId,
    required this.amount,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.description,
    required this.patientName,
    required this.scheduledDate,
    this.processedAt,
  });

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'] ?? '',
      bookingId: map['bookingId'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      type: PaymentType.values.firstWhere(
        (e) => e.toString() == 'PaymentType.${map['type']}',
        orElse: () => PaymentType.earning,
      ),
      status: PaymentStatus.values.firstWhere(
        (e) => e.toString() == 'PaymentStatus.${map['status']}',
        orElse: () => PaymentStatus.pending,
      ),
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      description: map['description'] ?? '',
      patientName: map['patientName'] ?? '',
      scheduledDate: map['scheduledDate']?.toDate() ?? DateTime.now(),
      processedAt: map['processedAt']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookingId': bookingId,
      'amount': amount,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'createdAt': createdAt,
      'description': description,
      'patientName': patientName,
      'scheduledDate': scheduledDate,
      'processedAt': processedAt,
    };
  }
}

enum PaymentType {
  earning,
  withdrawal,
  refund,
}

enum PaymentStatus {
  pending,
  completed,
  failed,
}

extension PaymentStatusExtension on PaymentStatus {
  String get displayName {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.completed:
        return 'Completed';
      case PaymentStatus.failed:
        return 'Failed';
    }
  }

  Color get color {
    switch (this) {
      case PaymentStatus.pending:
        return Color(0xFFFFA726);
      case PaymentStatus.completed:
        return Color(0xFF66BB6A);
      case PaymentStatus.failed:
        return Color(0xFFEF5350);
    }
  }
}
