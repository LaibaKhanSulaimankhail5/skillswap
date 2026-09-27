import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_provider.dart';
import '../../services/discovery_provider.dart';
import '../../services/profile_provider.dart';
import '../../data/models/user_model.dart';
import 'student_detail_screen.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  @override
  void initState() {
    super.initState();
    final uid = context.read<AuthProvider>().user!.uid;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DiscoveryProvider>().loadStudents(uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final me = context.watch<ProfileProvider>().profile!;
    final discovery = context.watch<DiscoveryProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Discover Skills')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search by skill or name...',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) => discovery.setSearchQuery(value),
              ),
            ),
            if (discovery.isFromCache)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  margin: const EdgeInsets.only(bottom: 8),
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
                          'Offline — showing last saved list.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: discovery.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildList(me, discovery),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(UserModel me, DiscoveryProvider discovery) {
    final results = discovery.getResults(me);

    if (results.isEmpty) {
      return const Center(child: Text('No students found.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final student = results[index];
        final greatMatch = discovery.isGreatMatch(me, student);
        final partialMatch = discovery.isPartialMatch(me, student);

        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: CircleAvatar(
              radius: 26,
              child: Text(student.name.isNotEmpty ? student.name[0] : '?'),
            ),
            title: Text(student.name),
            subtitle: Text(
              'Teaches: ${student.skillsToTeach.join(", ")}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: greatMatch
                ? const Chip(label: Text('🎯 Great Match'))
                : partialMatch
                ? const Chip(label: Text('Match'))
                : null,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StudentDetailScreen(student: student),
              ),
            ),
          ),
        );
      },
    );
  }
}
