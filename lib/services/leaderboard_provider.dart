import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import '../data/services/firestore_service.dart';

/// Holds the ranked list of most-helpful students.
class LeaderboardProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<UserModel> _students = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  List<UserModel> get students => _students;

  Future<void> loadLeaderboard() async {
    _isLoading = true;
    notifyListeners();

    _students = await _firestoreService.getLeaderboard();

    _isLoading = false;
    notifyListeners();
  }
}
