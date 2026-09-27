import 'package:flutter/material.dart';
import '../data/models/chat_message_model.dart';
import '../data/services/firestore_service.dart';

/// Manages chat conversations — sending messages and streaming updates.
class ChatProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  String buildChatId(String uidA, String uidB) =>
      _firestoreService.buildChatId(uidA, uidB);

  Future<void> sendMessage(String chatId, String senderId, String text) {
    if (text.trim().isEmpty) return Future.value();
    return _firestoreService.sendMessage(chatId, senderId, text.trim());
  }

  Stream<List<ChatMessageModel>> messagesStream(String chatId) =>
      _firestoreService.messagesStream(chatId);

  Stream<List<ChatSummary>> userChatsStream(String uid) =>
      _firestoreService.userChatsStream(uid);
}
