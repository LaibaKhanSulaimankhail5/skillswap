import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import '../data/services/firestore_service.dart';
import '../data/services/db_service.dart';

/// Holds the list of discoverable students, search query, and matching logic.
class DiscoveryProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final DbService _dbService = DbService();

  List<UserModel> _allStudents = [];
  String _searchQuery = '';
  bool _isLoading = false;
  bool _isFromCache = false;

  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  bool get isFromCache => _isFromCache;

  /// Loads every profile except the logged-in user's own.
  Future<void> loadStudents(String currentUid) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _firestoreService.getAllProfilesExceptWithSource(
        currentUid,
      );
      _allStudents = result.data;
      _isFromCache = result.isFromCache;

      if (_allStudents.isNotEmpty) {
        await _dbService.cacheDiscoveryList(_allStudents);
      }
    } catch (e) {
      _allStudents = await _dbService.getCachedDiscoveryList();
      _isFromCache = _allStudents.isNotEmpty;
    }

    _isLoading = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  bool _skillsRelated(String skillA, String skillB) {
    final a = skillA.trim().toLowerCase();
    final b = skillB.trim().toLowerCase();
    if (a.isEmpty || b.isEmpty) return false;
    return a == b || a.contains(b) || b.contains(a);
  }

  bool _theyTeachWhatIWantToLearn(UserModel me, UserModel other) {
    return other.skillsToTeach.any(
      (theirSkill) => me.skillsToLearn.any(
        (mySkill) => _skillsRelated(theirSkill, mySkill),
      ),
    );
  }

  bool isGreatMatch(UserModel me, UserModel other) {
    final theyTeachMe = _theyTeachWhatIWantToLearn(me, other);
    final iTeachThem = other.skillsToLearn.any(
      (theirWant) =>
          me.skillsToTeach.any((mySkill) => _skillsRelated(theirWant, mySkill)),
    );
    return theyTeachMe && iTeachThem;
  }

  bool isPartialMatch(UserModel me, UserModel other) {
    return _theyTeachWhatIWantToLearn(me, other) && !isGreatMatch(me, other);
  }

  List<UserModel> getResults(UserModel me) {
    var results = _allStudents.where((student) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      return student.skillsToTeach.any(
            (s) => s.toLowerCase().contains(query),
          ) ||
          student.name.toLowerCase().contains(query);
    }).toList();

    results.sort((a, b) {
      int score(UserModel s) {
        if (isGreatMatch(me, s)) return 0;
        if (isPartialMatch(me, s)) return 1;
        return 2;
      }

      return score(a).compareTo(score(b));
    });

    return results;
  }
}
