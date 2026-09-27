import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_provider.dart';
import '../../services/leaderboard_provider.dart';
import '../../data/models/user_model.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LeaderboardProvider>().loadLeaderboard();
    });
  }

  String _rankEmoji(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '#$rank';
    }
  }

  @override
  Widget build(BuildContext context) {
    final myUid = context.read<AuthProvider>().user?.uid;
    final leaderboard = context.watch<LeaderboardProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: SafeArea(
        child: leaderboard.isLoading
            ? const Center(child: CircularProgressIndicator())
            : leaderboard.students.isEmpty
                ? const Center(child: Text('No students yet.'))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: leaderboard.students.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final student = leaderboard.students[index];
                      final rank = index + 1;
                      final isMe = student.uid == myUid;

                      final isDark = Theme.of(context).brightness == Brightness.dark;
                      return Card(
                        color: isMe
                            ? (isDark ? Colors.deepPurple.shade900 : Colors.deepPurple.shade50)
                            : null,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: SizedBox(
                            width: 40,
                            child: Text(
                              _rankEmoji(rank),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundImage: student.profileImageUrl.isNotEmpty
                                    ? MemoryImage(base64Decode(student.profileImageUrl))
                                    : null,
                                child: student.profileImageUrl.isEmpty
                                    ? const Icon(Icons.person, size: 18)
                                    : null,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  isMe ? '${student.name} (You)' : student.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            '⭐ ${student.averageRating.toStringAsFixed(1)} · ${student.totalRatings} ratings',
                          ),
                          trailing: Text(
                            '🪙 ${student.credits}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}