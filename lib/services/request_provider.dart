import 'package:flutter/material.dart';
import '../data/models/request_model.dart';
import '../data/services/firestore_service.dart';

/// Manages sending, accepting, and rejecting skill exchange requests.
class RequestProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isSending = false;

  bool get isSending => _isSending;

  Future<bool> sendRequest({
    required String fromUid,
    required String fromName,
    required String toUid,
    required String toName,
    String message = '',
  }) async {
    _isSending = true;
    notifyListeners();
    try {
      await _firestoreService.sendRequest(
        fromUid: fromUid,
        fromName: fromName,
        toUid: toUid,
        toName: toName,
        message: message,
      );
      _isSending = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isSending = false;
      notifyListeners();
      return false;
    }
  }

  Stream<List<RequestModel>> incomingRequests(String uid) =>
      _firestoreService.incomingRequests(uid);

  Stream<List<RequestModel>> outgoingRequests(String uid) =>
      _firestoreService.outgoingRequests(uid);

  Future<void> acceptRequest(RequestModel request) =>
      _firestoreService.updateRequestStatus(
        request.id,
        RequestStatus.accepted,
        fromUid: request.fromUid,
        fromName: request.fromName,
        toUid: request.toUid,
        toName: request.toName,
        initialMessage: request.message,
      );

  Future<void> rejectRequest(String requestId) =>
      _firestoreService.updateRequestStatus(requestId, RequestStatus.rejected);
}
