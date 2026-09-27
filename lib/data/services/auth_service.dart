import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';

/// Handles all Firebase Authentication operations.
class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Returns the current logged-in user, or null if not logged in.
  User? get currentUser => _firebaseAuth.currentUser;

  // Stream that notifies the app whenever login state changes.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Permanently deletes the current user's auth account.
  /// Must be called right after re-authentication for security.
  Future<void> deleteAccount() async {
    await _firebaseAuth.currentUser?.delete();
  }

  /// Starts phone number verification. Firebase sends an OTP via SMS.
  Future<void> startPhoneVerification({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String error) onError,
  }) async {
    await _firebaseAuth.setSettings(appVerificationDisabledForTesting: true);

    final completer = Completer<void>();

    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _firebaseAuth.signInWithCredential(credential);
        if (!completer.isCompleted) completer.complete();
      },
      verificationFailed: (FirebaseAuthException e) {
        onError(_mapAuthError(e));
        if (!completer.isCompleted) completer.complete();
      },
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
        if (!completer.isCompleted) completer.complete();
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Don't complete here — codeSent should already have fired by now.
      },
    );

    // Wait here until one of the callbacks above actually fires.
    await completer.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () => onError('Request timed out. Please try again.'),
    );
  }

  /// Completes phone sign-in using the OTP code the user entered.
  Future<User?> signInWithSmsCode({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final result = await _firebaseAuth.signInWithCredential(credential);
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e));
    }
  }

  /// Signs up a new user with email and password.
  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      final result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e));
    }
  }

  /// Logs in an existing user with email and password.
  Future<User?> loginWithEmail(String email, String password) async {
    try {
      final result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e));
    }
  }

  /// Signs in using a Google account.
  Future<User?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null; // user cancelled

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final result = await _firebaseAuth.signInWithCredential(credential);
    return result.user;
  }

  /// Signs in anonymously as a guest.
  Future<User?> signInAsGuest() async {
    final result = await _firebaseAuth.signInAnonymously();
    return result.user;
  }

  /// Logs the current user out.
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  // Converts Firebase's error codes into readable messages.
  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'invalid-verification-code':
        return 'Incorrect OTP. Please try again.';
      case 'invalid-phone-number':
        return 'Please enter a valid phone number.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
