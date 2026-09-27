import 'package:cloud_firestore/cloud_firestore.dart';

/// A single message inside a chat conversation.
class ChatMessageModel {
  final String id;
  final String senderId;
  final String text;
  final DateTime sentAt;

  ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    required this.sentAt,
  });

  factory ChatMessageModel.fromMap(Map<String, dynamic> map, String id) {
    return ChatMessageModel(
      id: id,
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      sentAt: (map['sentAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'sentAt': FieldValue.serverTimestamp(),
    };
  }
}

/// Summary of a chat conversation, shown in the chat list.
class ChatSummary {
  final String chatId;
  final String otherUid;
  final String otherName;
  final String lastMessage;
  final DateTime lastMessageAt;

  ChatSummary({
    required this.chatId,
    required this.otherUid,
    required this.otherName,
    required this.lastMessage,
    required this.lastMessageAt,
  });

  factory ChatSummary.fromMap(
    Map<String, dynamic> map,
    String chatId,
    String myUid,
  ) {
    final participants = List<String>.from(map['participantIds'] ?? []);
    final names = Map<String, dynamic>.from(map['participantNames'] ?? {});
    final otherUid = participants.firstWhere(
      (id) => id != myUid,
      orElse: () => '',
    );

    return ChatSummary(
      chatId: chatId,
      otherUid: otherUid,
      otherName: names[otherUid] ?? 'Unknown',
      lastMessage: map['lastMessage'] ?? '',
      lastMessageAt:
          (map['lastMessageAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
