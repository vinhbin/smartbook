import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/auth_provider.dart';
import '/services/firestore_service.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  final _searchCtrl = TextEditingController();
  String _filter = '';

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().user!.uid;
    final fs  = FirestoreService();
    final t   = Theme.of(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final title = await _inputDialog(context, 'Thread title');
          if (title != null && title.trim().isNotEmpty) {
            await fs.addThread(uid, title.trim());
          }
        },
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8FFF2), Color(0xFFC8EFD9)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              /* header */
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.home),
                      onPressed: () => Navigator.pushReplacementNamed(
                          context, '/home'),
                    ),
                    const Spacer(),
                    Text(
                      'SmartBook',
                      style: t.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64C7A6),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () {}, // TODO
                    ),
                  ],
                ),
              ),

              /* title */
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text('Discussion Forum',
                        style: t.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const Spacer(),
                    const Icon(Icons.filter_alt_outlined),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              /* search bar — optional */
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _filter = v.trim()),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(.6),
                    hintText: 'User',
                    prefixIcon: const Icon(Icons.menu),
                    suffixIcon: const Icon(Icons.search),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: fs.threads(),
                  builder: (_, snap) {
                    if (!snap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    var threads = snap.data!;
                    if (_filter.isNotEmpty) {
                      threads = threads
                          .where((t) =>
                              t['createdBy']
                                  .toString()
                                  .toLowerCase()
                                  .contains(_filter.toLowerCase()) ||
                              t['title']
                                  .toString()
                                  .toLowerCase()
                                  .contains(_filter.toLowerCase()))
                          .toList();
                    }
                    if (threads.isEmpty) {
                      return const Center(child: Text('No threads yet'));
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: threads.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 24, thickness: .5),
                      itemBuilder: (_, i) {
                        final t = threads[i];
                        return ListTile(
                          title: Text(t['title']),
                          subtitle: Text(t['createdBy']),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ThreadScreen(
                                  threadId: t['id'], title: t['title']),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _inputDialog(BuildContext ctx, String hint) =>
      showDialog<String>(
        context: ctx,
        builder: (_) {
          final ctrl = TextEditingController();
          return AlertDialog(
            title: Text(hint),
            content: TextField(controller: ctrl),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, null),
                  child: const Text('Cancel')),
              ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, ctrl.text),
                  child: const Text('OK')),
            ],
          );
        },
      );
}


class ThreadScreen extends StatelessWidget {
  final String threadId, title;
  const ThreadScreen(
      {super.key, required this.threadId, required this.title});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().user!.uid;
    final fs  = FirestoreService();
    final ctrl = TextEditingController();
    final t    = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8FFF2), Color(0xFFC8EFD9)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.home),
                      onPressed: () => Navigator.pushReplacementNamed(
                          context, '/home'),
                    ),
                    const Spacer(),
                    Text(
                      'SmartBook',
                      style: t.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64C7A6),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              Text(title,
                  style: t.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: fs.comments(threadId),
                  builder: (_, snap) {
                    if (!snap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                          controller: ctrl,
                          decoration: const InputDecoration(
                              hintText: 'Comment…', filled: true)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () {
                        if (ctrl.text.trim().isNotEmpty) {
                          fs.addComment(
                              uid: uid,
                              threadId: threadId,
                              text: ctrl.text.trim());
                          ctrl.clear();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
