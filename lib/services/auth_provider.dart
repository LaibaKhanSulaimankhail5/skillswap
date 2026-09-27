import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/services/auth_service.dart';

/// Holds authentication state for the whole app.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null;

  String? _verificationId;

  Future<bool> startPhoneVerification(String phoneNumber) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    bool codeSent = false;
    await _authService.startPhoneVerification(
      phoneNumber: phoneNumber,
      onCodeSent: (verificationId) {
        _verificationId = verificationId;
        codeSent = true;
      },
      onError: (error) {
        _errorMessage = error;
      },
    );

    _isLoading = false;
    notifyListeners();
    return codeSent;
  }

  Future<bool> verifyOtp(String smsCode) => _runAuthAction(() async {
    if (_verificationId == null) {
      throw Exception('Verification expired. Please try again.');
    }
    return _authService.signInWithSmsCode(
      verificationId: _verificationId!,
      smsCode: smsCode,
    );
  });

  AuthProvider() {
    // Keeps _user in sync automatically whenever Firebase's login state changes.
    _authService.authStateChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<bool> signUp(String email, String password) =>
      _runAuthAction(() => _authService.signUpWithEmail(email, password));

  Future<bool> login(String email, String password) =>
      _runAuthAction(() => _authService.loginWithEmail(email, password));

  Future<bool> loginWithGoogle() =>
      _runAuthAction(() => _authService.signInWithGoogle());

  Future<bool> loginAsGuest() =>
      _runAuthAction(() => _authService.signInAsGuest());

  Future<void> logout() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }

  // Shared wrapper: handles loading state and error capturing for every auth action.
  Future<bool> _runAuthAction(Future<User?> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await action();
      _user = result;
      _isLoading = false;
      notifyListeners();
      return result != null;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
