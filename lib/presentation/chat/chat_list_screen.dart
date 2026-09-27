import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_provider.dart';
import '../../services/chat_provider.dart';
import '../../data/models/chat_message_model.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().user!.uid;
    final chatProvider = context.read<ChatProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: SafeArea(
        child: StreamBuilder<List<ChatSummary>>(
          stream: chatProvider.userChatsStream(uid),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final chats = snapshot.data!;
            if (chats.isEmpty) {
              return const Center(
                child: Text('No chats yet — accept a request to start one!'),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: chats.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final chat = chats[index];
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                      child: Text(
                        chat.otherName.isNotEmpty ? chat.otherName[0] : '?',
                      ),
                    ),
                    title: Text(chat.otherName),
                    subtitle: Text(
                      chat.lastMessage.isEmpty ? 'Say hi!' : chat.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          chatId: chat.chatId,
                          otherUid: chat.otherUid,
                          otherName: chat.otherName,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
