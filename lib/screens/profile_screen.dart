import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/auth_provider.dart';
import 'stats_screen.dart';
import 'reviews_screen.dart';
import 'history_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user!;
    final t    = Theme.of(context);

    Widget tile(String label, IconData icon, VoidCallback onTap) =>
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.4),
            borderRadius: BorderRadius.circular(6),
          ),
          child: ListTile(
            leading: Icon(icon, color: Colors.black87),
            title: Text(label),
            trailing: const Icon(Icons.chevron_right),
            onTap: onTap,
          ),
        );

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
              /* header */
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.home),
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/home'),
                    ),
                    const Spacer(),
                    Text('SmartBook',
                        style: t.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64C7A6))),
                    const Spacer(),
                    IconButton(
                        icon: const Icon(Icons.settings), onPressed: () {}),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              /* avatar + email */
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.grey.shade300,
                child: const Icon(Icons.person, size: 40),
              ),
              const SizedBox(height: 8),
              Text(user.email ?? 'User',
                  style: t.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              TextButton.icon(
                onPressed: () => context.read<AuthProvider>().signOut(),
                icon: const Icon(Icons.logout, size: 16),
                label: const Text('Log Out'),
              ),
              const SizedBox(height: 16),

              /* menu tiles */
              tile('Statistics', Icons.bar_chart, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const StatsScreen()));
              }),
              tile('List of Reviews', Icons.favorite, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ReviewsScreen()));
              }),
              tile('Reading History', Icons.bookmarks, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const HistoryScreen()));
              }),

              // placeholders
              tile('Notifications', Icons.notifications, () {}),
              tile('Accessibility', Icons.key, () {}),
              tile('Help', Icons.help, () {}),
            ],
          ),
        ),
      ),
    );
  }
}
