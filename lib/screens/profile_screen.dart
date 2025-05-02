import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<String> _genres = [];
  final _all = ['fiction', 'fantasy', 'mystery', 'history', 'romance', 'science'];

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((p) {
      setState(() => _genres = p.getStringList('userGenres') ?? ['fiction']);
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user!;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.email),
              title: Text(user.email ?? ''),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text('Favourite genres:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Wrap(
                  spacing: 6,
                  children: _genres.map((g) => Chip(label: Text(g))).toList(),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: _editGenres,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editGenres() async {
    final tmp = [..._genres];
    final res = await showDialog<List<String>>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Pick genres'),
        content: StatefulBuilder(builder: (_, setSt) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: _all.map((g) {
              final selected = tmp.contains(g);
              return CheckboxListTile(
                title: Text(g),
                value: selected,
                onChanged: (v) => setSt(() {
                  v! ? tmp.add(g) : tmp.remove(g);
                }),
              );
            }).toList(),
          );
        }),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, null), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, tmp), child: const Text('Save')),
        ],
      ),
    );
    if (res != null) {
      setState(() => _genres = res);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('userGenres', res);
      // also sync to Firestore profile doc
      final uid = context.read<AuthProvider>().user!.uid;
      FirestoreService().db.doc('users/$uid').set(
  {'favoriteGenres': res},
  SetOptions(merge: true),
);
    }
  }
}
