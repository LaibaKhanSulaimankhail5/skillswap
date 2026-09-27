import 'package:flutter/material.dart';
import '../data/services/firestore_service.dart';

/// Manages submitting ratings for completed skill exchanges.
class RatingProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isSubmitting = false;

  bool get isSubmitting => _isSubmitting;

  Future<bool> hasAlreadyRated({
    required String ratedUid,
    required String raterUid,
  }) {
    return _firestoreService.hasAlreadyRated(
      ratedUid: ratedUid,
      raterUid: raterUid,
    );
  }

  Future<bool> submitRating({
    required String ratedUid,
    required String raterUid,
    required String raterName,
    required int stars,
    String comment = '',
  }) async {
    _isSubmitting = true;
    notifyListeners();
    try {
      await _firestoreService.submitRating(
        ratedUid: ratedUid,
        raterUid: raterUid,
        raterName: raterName,
        stars: stars,
        comment: comment,
      );
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }
}
