import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_provider.dart';
import '../../services/request_provider.dart';
import '../../data/models/request_model.dart';

class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().user!.uid;
    final requestProvider = context.read<RequestProvider>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Requests'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Incoming'),
              Tab(text: 'Outgoing'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _IncomingTab(uid: uid, requestProvider: requestProvider),
            _OutgoingTab(uid: uid, requestProvider: requestProvider),
          ],
        ),
      ),
    );
  }
}

class _IncomingTab extends StatelessWidget {
  final String uid;
  final RequestProvider requestProvider;

  const _IncomingTab({required this.uid, required this.requestProvider});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<RequestModel>>(
      stream: requestProvider.incomingRequests(uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final requests = snapshot.data!;
        if (requests.isEmpty) {
          return const Center(child: Text('No incoming requests yet.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final req = requests[index];
            return Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                title: Text(req.fromName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Status: ${req.status.name}'),
                    if (req.message.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        '"${req.message}"',
                        style: const TextStyle(fontStyle: FontStyle.italic),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
                trailing: req.status == RequestStatus.pending
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                            onPressed: () => requestProvider.acceptRequest(req),
                          ),
                          IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            onPressed: () =>
                                requestProvider.rejectRequest(req.id),
                          ),
                        ],
                      )
                    : null,
              ),
            );
          },
        );
      },
    );
  }
}

class _OutgoingTab extends StatelessWidget {
  final String uid;
  final RequestProvider requestProvider;

  const _OutgoingTab({required this.uid, required this.requestProvider});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<RequestModel>>(
      stream: requestProvider.outgoingRequests(uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final requests = snapshot.data!;
        if (requests.isEmpty) {
          return const Center(child: Text('No outgoing requests yet.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final req = requests[index];
            return Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                title: Text(req.toName),
                subtitle: Text('Status: ${req.status.name}'),
              ),
            );
          },
        );
      },
    );
  }
}
