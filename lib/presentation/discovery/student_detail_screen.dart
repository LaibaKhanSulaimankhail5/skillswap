import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_provider.dart';
import '../../services/profile_provider.dart';
import '../../services/request_provider.dart';
import '../../data/models/user_model.dart';

/// Read-only view of another student's profile, with a request form
/// that lets the sender attach an opening message.
class StudentDetailScreen extends StatefulWidget {
  final UserModel student;
  final bool readOnly;

  const StudentDetailScreen({
    super.key,
    required this.student,
    this.readOnly = false,
  });

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _handleSendRequest() async {
    final requestProvider = context.read<RequestProvider>();
    final me = context.read<AuthProvider>().user!;
    final myProfile = context.read<ProfileProvider>().profile!;

    final success = await requestProvider.sendRequest(
      fromUid: me.uid,
      fromName: myProfile.name,
      toUid: widget.student.uid,
      toName: widget.student.name,
      message: _messageController.text,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Request sent to ${widget.student.name}!'
              : 'Could not send request. Try again.',
        ),
      ),
    );
    if (success) _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final student = widget.student;
    final requestProvider = context.watch<RequestProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(student.name)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: student.profileImageUrl.isNotEmpty
                    ? MemoryImage(base64Decode(student.profileImageUrl))
                    : null,
                child: student.profileImageUrl.isEmpty
                    ? const Icon(Icons.person, size: 40)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              student.name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (student.bio.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(student.bio, textAlign: TextAlign.center),
            ],
            const SizedBox(height: 24),
            Text('Can teach', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: student.skillsToTeach
                  .map((s) => Chip(label: Text(s)))
                  .toList(),
            ),
            const SizedBox(height: 16),
            Text(
              'Wants to learn',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: student.skillsToLearn
                  .map((s) => Chip(label: Text(s)))
                  .toList(),
            ),
            if (!widget.readOnly) ...[
              const SizedBox(height: 32),
              Text(
                'Say hello (optional)',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _messageController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'e.g. Hi! I\'d love to learn Flutter from you.',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'This appears as your first chat message once they accept.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: requestProvider.isSending
                    ? null
                    : _handleSendRequest,
                icon: const Icon(Icons.handshake_outlined),
                label: Text(
                  requestProvider.isSending
                      ? 'Sending...'
                      : 'Send Skill Request',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
