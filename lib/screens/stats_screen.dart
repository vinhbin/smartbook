import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/auth_provider.dart';
import '/services/firestore_service.dart';

/// Screen that displays reading statistics for the user,
/// showing counts for each reading list category.
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve the user's UID from the auth provider
    final uid = context.read<AuthProvider>().user!.uid;

    // Get the Firestore service instance
    final fs  = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),

      // StreamBuilder listens to Firestore reading counts
      body: StreamBuilder<Map<String, int>>(
        stream: fs.readingCounts(uid), // Custom method that returns counts for want/current/finished
        builder: (_, snap) {
          // Show loading spinner while waiting for data
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final c = snap.data!; // Data format: { 'want': 2, 'current': 1, 'finished': 4 }

          // Build a list view showing the counts
          return ListView(
            children: [
              // Each ListTile shows a status and its count
              ListTile(title: const Text('Want to read'), trailing: Text('${c['want']}')),
              ListTile(title: const Text('Currently reading'), trailing: Text('${c['current']}')),
              ListTile(title: const Text('Finished'), trailing: Text('${c['finished']}')),
              
              // Total = sum of all three
              ListTile(
                title: const Text('Total'),
                trailing: Text('${c['want']! + c['current']! + c['finished']!}'),
              ),
            ],
          );
        },
      ),
    );
  }
}
