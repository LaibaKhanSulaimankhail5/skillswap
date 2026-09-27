import 'dart:io';
import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import '../data/services/firestore_service.dart';
import '../data/services/image_service.dart';
import '../data/services/db_service.dart';
import '../data/services/auth_service.dart';

/// Holds the current user's profile state for the whole app.
class ProfileProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final ImageService _imageService = ImageService();
  final DbService _dbService = DbService();

  UserModel? _profile;
  bool _isLoading = false;
  bool _hasChecked = false;
  bool _isFromCache = false;

  UserModel? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get hasProfile => _profile != null;
  bool get hasChecked => _hasChecked;
  bool get isFromCache => _isFromCache;

  /// Looks up whether the logged-in user already has a profile document.
  /// Falls back to the local SQLite cache if Firestore has no cached data
  /// at all yet (e.g. very first offline launch on a new device).
  Future<void> loadProfile(String uid) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _firestoreService.getProfileWithSource(uid);
      _profile = result.data;
      _isFromCache = result.isFromCache;

      if (_profile != null) {
        await _dbService.cacheProfile(_profile!);
      }
    } catch (e) {
      _profile = await _dbService.getCachedProfile(uid);
      _isFromCache = _profile != null;
    }

    _isLoading = false;
    _hasChecked = true;
    notifyListeners();
  }

  Future<bool> deleteAccount(String uid) async {
    try {
      await _firestoreService.deleteProfile(uid);
      await AuthService().deleteAccount();
      _profile = null;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Creates or updates the profile, optionally uploading a new image first.
  Future<bool> saveProfile({
    required String uid,
    required String email,
    required String name,
    required String bio,
    required List<String> skillsToTeach,
    required List<String> skillsToLearn,
    File? newImageFile,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      String imageBase64 = _profile?.profileImageUrl ?? '';
      if (newImageFile != null) {
        imageBase64 = await _imageService.imageToBase64(newImageFile);
      }

      final updated = UserModel(
        uid: uid,
        name: name,
        email: email,
        bio: bio,
        skillsToTeach: skillsToTeach,
        skillsToLearn: skillsToLearn,
        profileImageUrl: imageBase64,
        credits: _profile?.credits ?? 0,
        averageRating: _profile?.averageRating ?? 0.0,
        totalRatings: _profile?.totalRatings ?? 0,
      );

      await _firestoreService.saveProfile(updated);
      await _dbService.cacheProfile(updated);
      _profile = updated;
      _isFromCache = false;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Clears local profile state on logout.
  void reset() {
    _profile = null;
    _hasChecked = false;
    _isFromCache = false;
    notifyListeners();
  }
}
