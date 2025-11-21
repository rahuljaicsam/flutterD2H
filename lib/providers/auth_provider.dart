import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/provider_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  HealthcareProvider? _provider;
  bool _isLoading = false;
  String? _errorMessage;

  HealthcareProvider? get provider => _provider;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _auth.currentUser != null;

  AuthProvider() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _loadProviderData();
      } else {
        _provider = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadProviderData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('providers').doc(user.uid).get();
        if (doc.exists) {
          _provider = HealthcareProvider.fromMap(doc.data()!);
          notifyListeners();
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _setLoading(true);
      _errorMessage = null;
      
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getErrorMessage(e);
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String phone,
    required ProviderType type,
    required String licenseNumber,
    required String password,
    String? specialization,
    List<String>? services,
  }) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final provider = HealthcareProvider(
        id: userCredential.user!.uid,
        name: name,
        email: email,
        phone: phone,
        type: type,
        licenseNumber: licenseNumber,
        isVerified: false,
        rating: 0.0,
        completedBookings: 0,
        specialization: specialization,
        services: services ?? [],
        createdAt: DateTime.now(),
        location: {},
      );

      await _firestore
          .collection('providers')
          .doc(userCredential.user!.uid)
          .set(provider.toMap());

      _provider = provider;
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getErrorMessage(e);
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? specialization,
    List<String>? services,
    Map<String, dynamic>? location,
  }) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      if (_provider == null) return false;

      final updatedProvider = _provider!.copyWith(
        name: name,
        phone: phone,
        specialization: specialization,
        services: services,
        location: location,
      );

      await _firestore
          .collection('providers')
          .doc(_provider!.id)
          .update(updatedProvider.toMap());

      _provider = updatedProvider;
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update profile';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> uploadProfileImage(String imageUrl) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      if (_provider == null) return false;

      final updatedProvider = _provider!.copyWith(profileImageUrl: imageUrl);

      await _firestore
          .collection('providers')
          .doc(_provider!.id)
          .update({'profileImageUrl': imageUrl});

      _provider = updatedProvider;
      return true;
    } catch (e) {
      _errorMessage = 'Failed to upload profile image';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'user-not-found':
        return 'No user found for this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is not valid.';
      default:
        return 'An authentication error occurred.';
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

extension HealthcareProviderCopyWith on HealthcareProvider {
  HealthcareProvider copyWith({
    String? name,
    String? phone,
    String? specialization,
    List<String>? services,
    Map<String, dynamic>? location,
    String? profileImageUrl,
  }) {
    return HealthcareProvider(
      id: id,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      type: type,
      licenseNumber: licenseNumber,
      isVerified: isVerified,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      rating: rating,
      completedBookings: completedBookings,
      specialization: specialization ?? this.specialization,
      services: services ?? this.services,
      createdAt: createdAt,
      location: location ?? this.location,
    );
  }
}
