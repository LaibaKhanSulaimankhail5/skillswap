import 'package:cloud_firestore/cloud_firestore.dart';

enum RequestStatus { pending, accepted, rejected }

/// Represents a skill exchange request between two students.
class RequestModel {
  final String id;
  final String fromUid;
  final String fromName;
  final String toUid;
  final String toName;
  final RequestStatus status;
  final DateTime createdAt;
  final String message;

  RequestModel({
    required this.id,
    required this.fromUid,
    required this.fromName,
    required this.toUid,
    required this.toName,
    required this.status,
    required this.createdAt,
    this.message = '',
  });

  factory RequestModel.fromMap(Map<String, dynamic> map, String id) {
    return RequestModel(
      id: id,
      fromUid: map['fromUid'] ?? '',
      fromName: map['fromName'] ?? '',
      toUid: map['toUid'] ?? '',
      toName: map['toName'] ?? '',
      status: RequestStatus.values.firstWhere(
        (s) => s.name == (map['status'] ?? 'pending'),
        orElse: () => RequestStatus.pending,
      ),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      message: map['message'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fromUid': fromUid,
      'fromName': fromName,
      'toUid': toUid,
      'toName': toName,
      'status': status.name,
      'message': message,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
