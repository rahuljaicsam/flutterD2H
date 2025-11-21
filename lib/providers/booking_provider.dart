import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/booking_model.dart';
import 'package:flutter/material.dart';

class BookingProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  List<Booking> _bookings = [];
  List<Booking> _pendingBookings = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Booking> get bookings => _bookings;
  List<Booking> get pendingBookings => _pendingBookings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  BookingProvider() {
    if (_auth.currentUser != null) {
      _loadBookings();
    }
  }

  Future<void> _loadBookings() async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final user = _auth.currentUser;
      if (user == null) return;

      final snapshot = await _firestore
          .collection('bookings')
          .where('providerId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();

      _bookings = snapshot.docs
          .map((doc) => Booking.fromMap(doc.data()))
          .toList();

      _pendingBookings = _bookings
          .where((booking) => booking.status == BookingStatus.pending)
          .toList();

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load bookings';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Stream<List<Booking>> get bookingsStream {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('bookings')
        .where('providerId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Booking.fromMap(doc.data()))
            .toList());
  }

  Stream<List<Booking>> get pendingBookingsStream {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('bookings')
        .where('providerId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Booking.fromMap(doc.data()))
            .toList());
  }

  Future<bool> acceptBooking(String bookingId) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      await _firestore.collection('bookings').doc(bookingId).update({
        'status': 'accepted',
        'acceptedAt': Timestamp.now(),
      });

      await _loadBookings();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to accept booking';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> declineBooking(String bookingId, {String? reason}) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final updateData = {
        'status': 'declined',
        'declinedAt': Timestamp.now(),
      };

      if (reason != null && reason.isNotEmpty) {
        updateData['declineReason'] = reason;
      }

      await _firestore.collection('bookings').doc(bookingId).update(updateData);

      await _loadBookings();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to decline booking';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> startBooking(String bookingId) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      await _firestore.collection('bookings').doc(bookingId).update({
        'status': 'inProgress',
      });

      await _loadBookings();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to start booking';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> completeBooking(String bookingId) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      await _firestore.collection('bookings').doc(bookingId).update({
        'status': 'completed',
        'completedAt': Timestamp.now(),
      });

      await _loadBookings();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to complete booking';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<Booking?> getBookingById(String bookingId) async {
    try {
      final doc = await _firestore.collection('bookings').doc(bookingId).get();
      if (doc.exists) {
        return Booking.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      _errorMessage = 'Failed to get booking details';
      return null;
    }
  }

  List<Booking> getBookingsByStatus(BookingStatus status) {
    return _bookings.where((booking) => booking.status == status).toList();
  }

  List<Booking> getTodayBookings() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return _bookings.where((booking) {
      final bookingDate = booking.scheduledDate;
      return bookingDate.isAfter(today) && bookingDate.isBefore(tomorrow);
    }).toList();
  }

  List<Booking> getUpcomingBookings() {
    final now = DateTime.now();
    return _bookings.where((booking) {
      return booking.scheduledDate.isAfter(now) &&
             (booking.status == BookingStatus.accepted ||
              booking.status == BookingStatus.pending);
    }).toList();
  }

  int get pendingCount => _pendingBookings.length;
  int get todayCount => getTodayBookings().length;
  int get upcomingCount => getUpcomingBookings().length;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void refreshBookings() {
    if (_auth.currentUser != null) {
      _loadBookings();
    }
  }
}
