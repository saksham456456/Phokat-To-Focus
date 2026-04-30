import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../planner/providers/planner_provider.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewards & Unlocks'),
      ),
      body: Consumer<PlannerProvider>(
        builder: (context, planner, child) {
          final stats = planner.stats;

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // Level Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Theme.of(context).primaryColor, Theme.of(context).colorScheme.secondary],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.stars, color: Colors.white, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Level ${stats.level}',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: stats.levelProgress,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${stats.xp} XP', style: const TextStyle(color: Colors.white)),
                        Text('${stats.xpForNextLevel} XP needed', style: TextStyle(color: Colors.white.withValues(alpha: 0.7))),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              Text('Unlockable Themes', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              _buildRewardItem(context, 'Midnight Blue Theme', 500, stats.level >= 2, Icons.dark_mode),
              _buildRewardItem(context, 'Forest Green Theme', 1000, stats.level >= 5, Icons.eco),

              const SizedBox(height: 32),
              Text('Focus Sounds', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              _buildRewardItem(context, 'Rain on Tent', 200, stats.level >= 2, Icons.water_drop),
              _buildRewardItem(context, 'Coffee Shop', 400, stats.level >= 3, Icons.local_cafe),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRewardItem(BuildContext context, String title, int requiredXp, bool isUnlocked, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isUnlocked ? Theme.of(context).cardTheme.color : Theme.of(context).disabledColor.withValues(alpha: 0.1),
      child: ListTile(
        leading: Icon(icon, color: isUnlocked ? Theme.of(context).primaryColor : Colors.grey),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isUnlocked ? null : Colors.grey,
          ),
        ),
        subtitle: Text(isUnlocked ? 'Unlocked' : 'Requires Level ${requiredXp ~/ 100 + 1}'),
        trailing: isUnlocked
            ? const Icon(Icons.check_circle, color: Color(0xFF22C55E))
            : const Icon(Icons.lock, color: Colors.grey),
      ),
    );
  }
}
