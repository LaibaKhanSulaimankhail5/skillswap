import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/request_model.dart';
import '../models/chat_message_model.dart';

/// Wraps a Firestore read result together with whether it came from the
/// device's local cache (offline) or the live server.
class FetchResult<T> {
  final T data;
  final bool isFromCache;
  FetchResult(this.data, this.isFromCache);
}

/// Handles all Firestore reads/writes for user profiles, requests,
/// chats, and ratings.
class FirestoreService {
  final CollectionReference _users = FirebaseFirestore.instance.collection(
    'users',
  );
  final CollectionReference _requests = FirebaseFirestore.instance.collection(
    'requests',
  );
  final CollectionReference _ratings = FirebaseFirestore.instance.collection(
    'ratings',
  );
  final CollectionReference _chats = FirebaseFirestore.instance.collection(
    'chats',
  );

  static const int creditsPerRating = 5;

  // ---------------- Profiles ----------------

  /// Creates or overwrites a profile document.
  Future<void> saveProfile(UserModel user) async {
    await _users.doc(user.uid).set(user.toMap());
  }

  /// Deletes a user's profile document (called when they delete their account).
  Future<void> deleteProfile(String uid) async {
    await _users.doc(uid).delete();
  }

  /// Fetches a single profile once, along with whether it came from the
  /// local Firestore cache (i.e. the device is offline).
  Future<FetchResult<UserModel?>> getProfileWithSource(String uid) async {
    final doc = await _users.doc(uid).get();
    final isFromCache = doc.metadata.isFromCache;
    if (!doc.exists) return FetchResult(null, isFromCache);
    return FetchResult(
      UserModel.fromMap(doc.data() as Map<String, dynamic>, uid),
      isFromCache,
    );
  }

  /// Fetches a single profile once. Returns null if it doesn't exist yet.
  /// (Simple version without cache-source info, used by chat/rating flows.)
  Future<UserModel?> getProfile(String uid) async {
    final result = await getProfileWithSource(uid);
    return result.data;
  }

  /// Streams live updates to a profile (useful for real-time credit/rating changes).
  Stream<UserModel?> profileStream(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data() as Map<String, dynamic>, uid);
    });
  }

  /// Fetches all student profiles except the current user's own, along
  /// with whether the result came from the local Firestore cache.
  Future<FetchResult<List<UserModel>>> getAllProfilesExceptWithSource(
    String currentUid,
  ) async {
    final snapshot = await _users.get();
    final students = snapshot.docs
        .where((doc) => doc.id != currentUid)
        .map(
          (doc) =>
              UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
        )
        .toList();
    return FetchResult(students, snapshot.metadata.isFromCache);
  }

  /// Fetches all student profiles except the current user's own.
  /// (Simple version without cache-source info.)
  Future<List<UserModel>> getAllProfilesExcept(String currentUid) async {
    final result = await getAllProfilesExceptWithSource(currentUid);
    return result.data;
  }

  // ---------------- Requests ----------------

  /// Sends a new skill exchange request.
  Future<void> sendRequest({
    required String fromUid,
    required String fromName,
    required String toUid,
    required String toName,
    String message = '',
  }) async {
    await _requests.add({
      'fromUid': fromUid,
      'fromName': fromName,
      'toUid': toUid,
      'toName': toName,
      'status': RequestStatus.pending.name,
      'createdAt': FieldValue.serverTimestamp(),
      'message': message,
    });
  }

  /// Streams requests received by [uid], newest first.
  Stream<List<RequestModel>> incomingRequests(String uid) {
    return _requests
        .where('toUid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(
                (d) => RequestModel.fromMap(
                  d.data() as Map<String, dynamic>,
                  d.id,
                ),
              )
              .toList(),
        );
  }

  /// Streams requests sent by [uid], newest first.
  Stream<List<RequestModel>> outgoingRequests(String uid) {
    return _requests
        .where('fromUid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(
                (d) => RequestModel.fromMap(
                  d.data() as Map<String, dynamic>,
                  d.id,
                ),
              )
              .toList(),
        );
  }

  /// Updates a request's status (accept/reject). Accepting also creates
  /// the chat so it's ready the moment either side opens it.
  Future<void> updateRequestStatus(
    String requestId,
    RequestStatus status, {
    String? fromUid,
    String? fromName,
    String? toUid,
    String? toName,
    String? initialMessage,
  }) async {
    await _requests.doc(requestId).update({'status': status.name});

    if (status == RequestStatus.accepted &&
        fromUid != null &&
        fromName != null &&
        toUid != null &&
        toName != null) {
      await createChatIfNotExists(
        uidA: fromUid,
        nameA: fromName,
        uidB: toUid,
        nameB: toName,
      );

      if (initialMessage != null && initialMessage.trim().isNotEmpty) {
        final chatId = buildChatId(fromUid, toUid);
        await sendMessage(chatId, fromUid, initialMessage.trim());
      }
    }
  }

  // ---------------- Chats ----------------

  /// Builds a deterministic chat ID from two UIDs, same regardless of order.
  String buildChatId(String uidA, String uidB) {
    final sorted = [uidA, uidB]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  /// Creates the chat document if it doesn't already exist. Called when a
  /// request is accepted, so a chat is ready before either side opens it.
  Future<void> createChatIfNotExists({
    required String uidA,
    required String nameA,
    required String uidB,
    required String nameB,
  }) async {
    final chatId = buildChatId(uidA, uidB);
    final doc = _chats.doc(chatId);
    final snapshot = await doc.get();
    if (snapshot.exists) return;

    await doc.set({
      'participantIds': [uidA, uidB],
      'participantNames': {uidA: nameA, uidB: nameB},
      'lastMessage': '',
      'lastMessageAt': FieldValue.serverTimestamp(),
    });
  }

  /// Sends a message and updates the parent chat's "last message" preview.
  Future<void> sendMessage(String chatId, String senderId, String text) async {
    final message = ChatMessageModel(
      id: '',
      senderId: senderId,
      text: text,
      sentAt: DateTime.now(),
    );
    await _chats.doc(chatId).collection('messages').add(message.toMap());
    await _chats.doc(chatId).update({
      'lastMessage': text,
      'lastMessageAt': FieldValue.serverTimestamp(),
    });
  }

  /// Streams messages in a chat, oldest first.
  Stream<List<ChatMessageModel>> messagesStream(String chatId) {
    return _chats
        .doc(chatId)
        .collection('messages')
        .orderBy('sentAt')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(
                (d) => ChatMessageModel.fromMap(
                  d.data() as Map<String, dynamic>,
                  d.id,
                ),
              )
              .toList(),
        );
  }

  /// Streams the list of chats the current user is part of, newest first.
  Stream<List<ChatSummary>> userChatsStream(String uid) {
    return _chats
        .where('participantIds', arrayContains: uid)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(
                (d) => ChatSummary.fromMap(
                  d.data() as Map<String, dynamic>,
                  d.id,
                  uid,
                ),
              )
              .toList(),
        );
  }

  // ---------------- Ratings ----------------

  /// Submits a rating for [ratedUid] and recalculates their average rating,
  /// rating count, and credits — all in one atomic transaction.
  Future<void> submitRating({
    required String ratedUid,
    required String raterUid,
    required String raterName,
    required int stars,
    String comment = '',
  }) async {
    final userRef = _users.doc(ratedUid);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final userSnap = await transaction.get(userRef);
      final data = userSnap.data() as Map<String, dynamic>? ?? {};

      final currentAvg = (data['averageRating'] ?? 0.0).toDouble();
      final currentCount = (data['totalRatings'] ?? 0) as int;
      final currentCredits = (data['credits'] ?? 0) as int;

      final newCount = currentCount + 1;
      final newAvg = ((currentAvg * currentCount) + stars) / newCount;

      transaction.update(userRef, {
        'averageRating': newAvg,
        'totalRatings': newCount,
        'credits': currentCredits + creditsPerRating,
      });

      final ratingRef = _ratings.doc();
      transaction.set(ratingRef, {
        'ratedUid': ratedUid,
        'raterUid': raterUid,
        'raterName': raterName,
        'stars': stars,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Checks if [raterUid] has already rated [ratedUid] — prevents duplicate ratings.
  Future<bool> hasAlreadyRated({
    required String ratedUid,
    required String raterUid,
  }) async {
    final snap = await _ratings
        .where('ratedUid', isEqualTo: ratedUid)
        .where('raterUid', isEqualTo: raterUid)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  /// Fetches the top-ranked students by credits, highest first.
  Future<List<UserModel>> getLeaderboard({int limit = 50}) async {
    final snapshot = await _users
        .orderBy('credits', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs
        .map(
          (doc) =>
              UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
        )
        .toList();
  }
}
