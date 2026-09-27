import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_provider.dart';
import '../../services/profile_provider.dart';
import '../../services/theme_provider.dart';
import '../../core/utils/badge_helper.dart';
import '../discovery/discovery_screen.dart';
import '../requests/requests_screen.dart';
import '../chat/chat_list_screen.dart';
import '../leaderboard/leaderboard_screen.dart';
import 'create_profile_screen.dart';

class ProfileViewScreen extends StatelessWidget {
  const ProfileViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final profile = profileProvider.profile!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final primaryText = isDark ? Colors.white : const Color(0xFF1E293B);
    final secondaryText = isDark
        ? Colors.grey.shade400
        : const Color(0xFF475569);
    final dividerColor = isDark
        ? Colors.grey.shade800
        : const Color(0xFFE2E8F0);
    final statsBg = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF8FAFC);
    final teachBg = isDark ? const Color(0xFF14361F) : const Color(0xFFE6F4EA);
    final teachText = isDark
        ? const Color(0xFF6FCF97)
        : const Color(0xFF137333);
    final learnBg = isDark ? const Color(0xFF232149) : const Color(0xFFEEF2FF);
    final learnText = isDark
        ? const Color(0xFFA5B4FC)
        : const Color(0xFF4F46E5);
    final badgeBg = isDark ? const Color(0xFF3A2E14) : const Color(0xFFFFF7E6);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Toggle Theme',
            icon: Icon(
              context.watch<ThemeProvider>().isDarkMode
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
              color: primaryText,
            ),
            onPressed: () => context.read<ThemeProvider>().toggleTheme(),
          ),
          IconButton(
            tooltip: 'Leaderboard',
            icon: Icon(Icons.leaderboard_outlined, color: primaryText),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Discover',
            icon: Icon(Icons.explore_outlined, color: primaryText),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DiscoveryScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Requests',
            icon: Icon(Icons.inbox_outlined, color: primaryText),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RequestsScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Chats',
            icon: Icon(Icons.chat_bubble_outline, color: primaryText),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatListScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Edit Profile',
            icon: Icon(Icons.edit_outlined, color: primaryText),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateProfileScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Logout',
            icon: Icon(Icons.logout, color: primaryText),
            onPressed: () {
              context.read<ProfileProvider>().reset();
              context.read<AuthProvider>().logout();
            },
          ),
          IconButton(
            tooltip: 'Delete Account',
            icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
            onPressed: () => _confirmDelete(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            if (profileProvider.isFromCache)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.wifi_off,
                      size: 16,
                      color: Colors.orange.shade800,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You\'re offline — showing last saved profile.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            _buildHeaderCard(
              profile,
              cardColor: cardColor,
              primaryText: primaryText,
              secondaryText: secondaryText,
              dividerColor: dividerColor,
              statsBg: statsBg,
              badgeBg: badgeBg,
            ),
            const SizedBox(height: 20),
            _buildSkillCard(
              title: 'Can Teach',
              icon: Icons.school_outlined,
              skills: profile.skillsToTeach,
              chipBg: teachBg,
              chipText: teachText,
              cardColor: cardColor,
              primaryText: primaryText,
              secondaryText: secondaryText,
            ),
            const SizedBox(height: 16),
            _buildSkillCard(
              title: 'Wants to Learn',
              icon: Icons.lightbulb_outline,
              skills: profile.skillsToLearn,
              chipBg: learnBg,
              chipText: learnText,
              cardColor: cardColor,
              primaryText: primaryText,
              secondaryText: secondaryText,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(
    profile, {
    required Color cardColor,
    required Color primaryText,
    required Color secondaryText,
    required Color dividerColor,
    required Color statsBg,
    required Color badgeBg,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: dividerColor, width: 2),
            ),
            child: CircleAvatar(
              radius: 46,
              backgroundColor: statsBg,
              backgroundImage: profile.profileImageUrl.isNotEmpty
                  ? MemoryImage(base64Decode(profile.profileImageUrl))
                  : null,
              child: profile.profileImageUrl.isEmpty
                  ? Icon(Icons.person, size: 40, color: secondaryText)
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            profile.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: primaryText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            profile.email,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: secondaryText),
          ),
          if (profile.bio.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              profile.bio,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: secondaryText, height: 1.4),
            ),
          ],
          const SizedBox(height: 20),
          _buildStatsRow(
            profile,
            statsBg: statsBg,
            dividerColor: dividerColor,
            primaryText: primaryText,
            secondaryText: secondaryText,
          ),
          const SizedBox(height: 16),
          _buildBadgesRow(
            profile,
            badgeBg: badgeBg,
            primaryText: primaryText,
            secondaryText: secondaryText,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(
    profile, {
    required Color statsBg,
    required Color dividerColor,
    required Color primaryText,
    required Color secondaryText,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: statsBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            emoji: '⭐',
            value: profile.averageRating.toStringAsFixed(1),
            label: 'Rating',
            primaryText: primaryText,
            secondaryText: secondaryText,
          ),
          Container(height: 32, width: 1, color: dividerColor),
          _buildStatItem(
            emoji: '🪙',
            value: '${profile.credits}',
            label: 'Credits',
            primaryText: primaryText,
            secondaryText: secondaryText,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String emoji,
    required String value,
    required String label,
    required Color primaryText,
    required Color secondaryText,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: primaryText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 12, color: secondaryText)),
      ],
    );
  }

  Widget _buildBadgesRow(
    profile, {
    required Color badgeBg,
    required Color primaryText,
    required Color secondaryText,
  }) {
    final badges = BadgeHelper.badgesFor(profile);
    if (badges.isEmpty) {
      return Text(
        'No badges yet — complete an exchange to earn your first one!',
        style: TextStyle(fontSize: 12, color: secondaryText),
        textAlign: TextAlign.center,
      );
    }
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: badges
          .map(
            (b) => Chip(
              label: Text('${b.emoji} ${b.label}'),
              backgroundColor: badgeBg,
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: primaryText,
              ),
              side: BorderSide.none,
            ),
          )
          .toList(),
    );
  }

  Widget _buildSkillCard({
    required String title,
    required IconData icon,
    required List<String> skills,
    required Color chipBg,
    required Color chipText,
    required Color cardColor,
    required Color primaryText,
    required Color secondaryText,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: chipText),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          skills.isEmpty
              ? Text(
                  'Nothing added yet',
                  style: TextStyle(color: secondaryText, fontSize: 13),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: skills
                      .map(
                        (s) => Chip(
                          label: Text(s),
                          backgroundColor: chipBg,
                          labelStyle: TextStyle(
                            color: chipText,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      )
                      .toList(),
                ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text(
          'This permanently deletes your profile, ratings, and chats cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final uid = context.read<AuthProvider>().user!.uid;
              final success = await context
                  .read<ProfileProvider>()
                  .deleteAccount(uid);
              if (!context.mounted) return;
              if (!success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Could not delete account. Please log out and back in, then try again.',
                    ),
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
