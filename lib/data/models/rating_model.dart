import 'package:cloud_firestore/cloud_firestore.dart';

/// A single rating one student gives another after a skill exchange.
class RatingModel {
  final String id;
  final String ratedUid;
  final String raterUid;
  final String raterName;
  final int stars;
  final String comment;
  final DateTime createdAt;

  RatingModel({
    required this.id,
    required this.ratedUid,
    required this.raterUid,
    required this.raterName,
    required this.stars,
    required this.comment,
    required this.createdAt,
  });

  factory RatingModel.fromMap(Map<String, dynamic> map, String id) {
    return RatingModel(
      id: id,
      ratedUid: map['ratedUid'] ?? '',
      raterUid: map['raterUid'] ?? '',
      raterName: map['raterName'] ?? '',
      stars: map['stars'] ?? 0,
      comment: map['comment'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ratedUid': ratedUid,
      'raterUid': raterUid,
      'raterName': raterName,
      'stars': stars,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
