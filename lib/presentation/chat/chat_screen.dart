import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../services/auth_provider.dart';
import '../../services/chat_provider.dart';
import '../../services/rating_provider.dart';
import '../../services/profile_provider.dart';
import '../../data/models/chat_message_model.dart';
import '../../data/services/firestore_service.dart';
import '../discovery/student_detail_screen.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String otherUid;
  final String otherName;
  final String otherImageBase64;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.otherUid,
    required this.otherName,
    this.otherImageBase64 = '',
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSend(String myUid) {
    final text = _messageController.text;
    if (text.trim().isEmpty) return;
    context.read<ChatProvider>().sendMessage(widget.chatId, myUid, text);
    _messageController.clear();
  }

  Future<void> _openOtherProfile() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final profile = await FirestoreService().getProfile(widget.otherUid);

    if (!mounted) return;
    Navigator.pop(context);

    if (profile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load this profile.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StudentDetailScreen(student: profile, readOnly: true),
      ),
    );
  }

  Future<void> _openRatingDialog(String myUid, String myName) async {
    final ratingProvider = context.read<RatingProvider>();
    final alreadyRated = await ratingProvider.hasAlreadyRated(
      ratedUid: widget.otherUid,
      raterUid: myUid,
    );
    if (!mounted) return;

    if (alreadyRated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You already rated ${widget.otherName}.')),
      );
      return;
    }

    int selectedStars = 5;
    final commentController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
          ),
          child: StatefulBuilder(
            builder: (sheetContext, setSheetState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Rate ${widget.otherName}',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starNumber = index + 1;
                      return IconButton(
                        icon: Icon(
                          starNumber <= selectedStars
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                        onPressed: () =>
                            setSheetState(() => selectedStars = starNumber),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: commentController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: 'Optional comment...',
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () async {
                      final success = await ratingProvider.submitRating(
                        ratedUid: widget.otherUid,
                        raterUid: myUid,
                        raterName: myName,
                        stars: selectedStars,
                        comment: commentController.text.trim(),
                      );
                      if (!sheetContext.mounted) return;
                      Navigator.pop(sheetContext);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? 'Thanks for rating ${widget.otherName}!'
                                : 'Could not submit rating. Try again.',
                          ),
                        ),
                      );
                    },
                    child: const Text('Submit Rating'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  String _dateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return DateFormat('MMM d, yyyy').format(date);
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final myUid = context.read<AuthProvider>().user!.uid;
    final chatProvider = context.read<ChatProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Theme-aware colors for the chat "wallpaper" and message bubbles.
    final chatBg = isDark ? const Color(0xFF0B141A) : const Color(0xFFECE5DD);
    final appBarBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final appBarFg = isDark ? Colors.white : Colors.black87;
    final myBubble = const Color(0xFF6C5CE7);
    final theirBubble = isDark ? const Color(0xFF262D31) : Colors.white;
    final theirText = isDark ? Colors.white : Colors.black87;
    final theirTimestamp = isDark ? Colors.white54 : Colors.black45;
    final dateChipBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final dateChipText = isDark ? Colors.grey.shade300 : Colors.black54;
    final inputBarBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final inputFieldBg = isDark
        ? const Color(0xFF2A2A2A)
        : const Color(0xFFF1F1F1);
    final inputTextColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: chatBg,
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: appBarBg,
        elevation: 1,
        foregroundColor: appBarFg,
        title: GestureDetector(
          onTap: _openOtherProfile,
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.deepPurple.shade100,
                backgroundImage: widget.otherImageBase64.isNotEmpty
                    ? MemoryImage(base64Decode(widget.otherImageBase64))
                    : null,
                child: widget.otherImageBase64.isEmpty
                    ? const Icon(
                        Icons.person,
                        size: 18,
                        color: Colors.deepPurple,
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.otherName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: appBarFg,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Rate this exchange',
            icon: Icon(Icons.star_outline, color: appBarFg),
            onPressed: () {
              final myName =
                  context.read<ProfileProvider>().profile?.name ?? 'A student';
              _openRatingDialog(myUid, myName);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<ChatMessageModel>>(
                stream: chatProvider.messagesStream(widget.chatId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final messages = snapshot.data!;
                  if (messages.isEmpty) {
                    return Center(
                      child: Text(
                        'Say hi to start the conversation! 👋',
                        style: TextStyle(color: theirTimestamp),
                      ),
                    );
                  }

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients) {
                      _scrollController.jumpTo(
                        _scrollController.position.maxScrollExtent,
                      );
                    }
                  });

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg.senderId == myUid;
                      final showDateChip =
                          index == 0 ||
                          !_isSameDay(messages[index - 1].sentAt, msg.sentAt);

                      return Column(
                        children: [
                          if (showDateChip)
                            _buildDateChip(
                              msg.sentAt,
                              dateChipBg,
                              dateChipText,
                            ),
                          Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 3),
                              padding: const EdgeInsets.fromLTRB(14, 10, 10, 8),
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.72,
                              ),
                              decoration: BoxDecoration(
                                color: isMe ? myBubble : theirBubble,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                                  bottomRight: Radius.circular(isMe ? 4 : 16),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    msg.text,
                                    style: TextStyle(
                                      color: isMe ? Colors.white : theirText,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    DateFormat('h:mm a').format(msg.sentAt),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isMe
                                          ? Colors.white.withValues(alpha: 0.7)
                                          : theirTimestamp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            _buildInputBar(
              myUid,
              inputBarBg,
              inputFieldBg,
              inputTextColor,
              myBubble,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateChip(DateTime date, Color bg, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 3,
            ),
          ],
        ),
        child: Text(
          _dateLabel(date),
          style: TextStyle(
            fontSize: 12,
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar(
    String myUid,
    Color barBg,
    Color fieldBg,
    Color textColor,
    Color sendButtonColor,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      color: barBg,
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: fieldBg,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: TextField(
                  controller: _messageController,
                  minLines: 1,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: 'Message...',
                    hintStyle: TextStyle(
                      color: textColor.withValues(alpha: 0.5),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onSubmitted: (_) => _handleSend(myUid),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: sendButtonColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: () => _handleSend(myUid),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
