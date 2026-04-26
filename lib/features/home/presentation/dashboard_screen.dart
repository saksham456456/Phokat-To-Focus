import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../planner/providers/planner_provider.dart';
import 'package:intl/intl.dart';
import '../../auth/providers/auth_provider.dart';
import '../../premium/presentation/paywall_screen.dart';
import '../../ai_coach/presentation/ai_coach_screen.dart';
import '../../stats/presentation/stats_screen.dart';
import '../../gamification/presentation/rewards_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<PlannerProvider>(
          builder: (context, provider, child) {
            final stats = provider.stats;
            final todayTasks = provider.todayTasks;
            final completedTasks = provider.completedToday;
            final totalTasks = todayTasks.length;
            final progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good evening, Alex 👋',
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        const SizedBox(height: 24),

                        // Behavior Engine Mock Banner
                        if (provider.showsProcrastinationRisk) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.psychology, color: Theme.of(context).colorScheme.error),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Procrastination risk detected. Try a quick 15-min task right now to build momentum.',
                                    style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Streak + XP + AI Coach Access
                        Row(
                          children: [
                            _buildStatBadge(
                              context,
                              '🔥 ${stats.streak} Day Streak',
                              Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 12),
                            InkWell(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RewardsScreen())),
                              child: _buildStatBadge(
                                context,
                                '⭐ Lvl ${stats.level} (${stats.xp} XP)',
                                Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () {
                                if (Provider.of<AuthProvider>(context, listen: false).isPremium) {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AICoachScreen()));
                                } else {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumPaywallScreen()));
                                }
                              },
                              icon: Icon(Icons.auto_awesome, color: Theme.of(context).primaryColor),
                              tooltip: 'AI Coach',
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Today's Progress Card
                        InkWell(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const StatsScreen()));
                          },
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Today\'s Progress',
                                        style: Theme.of(context).textTheme.titleLarge,
                                      ),
                                    if (totalTasks > 0)
                                      Text(
                                        '$completedTasks/$totalTasks done',
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      )
                                    else
                                      Text(
                                        'No tasks',
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          color: Theme.of(context).disabledColor,
                                        ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      minHeight: 12,
                                      backgroundColor: Theme.of(context).disabledColor.withValues(alpha: 0.2),
                                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Center(
                                    child: Text(
                                      'Tap to view detailed analytics',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Today's Plan Header
                        Text(
                          'Today\'s Plan',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // Tasks List
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final task = todayTasks[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Container(
                              width: 12,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                color: task.isCompleted ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.secondary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            title: Text(
                              task.title,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                color: task.isCompleted ? Theme.of(context).disabledColor : null,
                              ),
                            ),
                            subtitle: Text(
                              '${task.subject} • ${DateFormat('h:mm a').format(task.scheduledTime)}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                              ),
                            ),
                            trailing: Checkbox(
                              value: task.isCompleted,
                              onChanged: (_) => provider.toggleTaskCompletion(task.id),
                              activeColor: Theme.of(context).primaryColor,
                            ),
                          ),
                        );
                      },
                      childCount: todayTasks.length,
                    ),
                  ),
                ),

                // Bottom padding for FAB
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatBadge(BuildContext context, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: color,
        ),
      ),
    );
  }
}
