import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';

class SocialScreen extends StatelessWidget {
  const SocialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.userName ?? 'User';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Social & Rooms'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Text(
            'Live Study Rooms',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildStudyRoomCard(
            context,
            'Library Silence',
            '14 studying • 3 on break',
            [Colors.blue.shade100, Colors.blue.shade200, Colors.blue.shade300],
          ),
          const SizedBox(height: 12),
          _buildStudyRoomCard(
            context,
            'Pomodoro Sync',
            '8 studying • 2 on break',
            [Colors.green.shade100, Colors.green.shade200, Colors.green.shade300],
          ),

          const SizedBox(height: 48),

          Text(
            'Friends Leaderboard',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildLeaderboardItem(context, 1, '$userName (You)', 120, true),
          _buildLeaderboardItem(context, 2, 'Sam', 95, false),
          _buildLeaderboardItem(context, 3, 'Jordan', 80, false),
        ],
      ),
    );
  }

  Widget _buildStudyRoomCard(BuildContext context, String title, String subtitle, List<Color> avatarColors) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Connecting to Study Room...')),
            );
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            textStyle: const TextStyle(fontSize: 14),
          ),
          child: const Text('Join'),
        ),
      ),
    );
  }

  Widget _buildLeaderboardItem(BuildContext context, int rank, String name, int xp, bool isMe) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isMe ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMe ? Theme.of(context).primaryColor.withValues(alpha: 0.3) : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '#$rank',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: rank == 1 ? Theme.of(context).colorScheme.error : null,
              ),
            ),
          ),
          const CircleAvatar(
            radius: 16,
            child: Icon(Icons.person, size: 16),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            '$xp XP',
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
