import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../providers/auth_provider.dart';

class ForumScreen extends StatelessWidget {
  const ForumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().user!.uid;
    final fs = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Community')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final title = await _inputDialog(context, 'Thread title');
          if (title != null && title.trim().isNotEmpty) {
            await fs.addThread(uid, title.trim());
          }
        },
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: fs.threads(),
        builder: (_, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final threads = snap.data!;
          if (threads.isEmpty) {
            return const Center(child: Text('No threads yet'));
          }
          return ListView.builder(
            itemCount: threads.length,
            itemBuilder: (_, i) {
              final t = threads[i];
              return ListTile(
                title: Text(t['title']),
                subtitle: Text(t['createdBy']),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ThreadScreen(threadId: t['id'], title: t['title']),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<String?> _inputDialog(BuildContext ctx, String hint) => showDialog<String>(
        context: ctx,
        builder: (_) {
          final ctrl = TextEditingController();
          return AlertDialog(
            title: Text(hint),
            content: TextField(controller: ctrl),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, null), child: const Text('Cancel')),
              ElevatedButton(onPressed: () => Navigator.pop(ctx, ctrl.text), child: const Text('OK')),
            ],
          );
        },
      );
}

class ThreadScreen extends StatelessWidget {
  final String threadId, title;
  const ThreadScreen({super.key, required this.threadId, required this.title});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().user!.uid;
    final fs = FirestoreService();
    final ctrl = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: fs.comments(threadId),
              builder: (_, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                final comments = snap.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: comments.length,
                  itemBuilder: (_, i) => ListTile(
                    title: Text(comments[i]['text']),
                    subtitle: Text(comments[i]['uid']),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Expanded(child: TextField(controller: ctrl, decoration: const InputDecoration(hintText: 'Comment…'))),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (ctrl.text.trim().isNotEmpty) {
                      fs.addComment(uid: uid, threadId: threadId, text: ctrl.text.trim());
                      ctrl.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
