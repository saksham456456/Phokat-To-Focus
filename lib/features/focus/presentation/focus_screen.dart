import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/focus_provider.dart';
import '../../planner/providers/planner_provider.dart';

class FocusScreen extends StatelessWidget {
  const FocusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? const Color(0xFF1A1A1A)
          : Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Consumer<FocusProvider>(
          builder: (context, focusProvider, child) {

            // Auto-save progress and reset if finished
            if (focusProvider.state == FocusState.finished) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final plannerProvider = Provider.of<PlannerProvider>(context, listen: false);
                plannerProvider.addFocusMinutes(focusProvider.durationMinutes);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Session complete! +${focusProvider.durationMinutes ~/ 5} XP'),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                );
                focusProvider.reset();
              });
            }

            final isRunning = focusProvider.state == FocusState.running;
            final isPaused = focusProvider.state == FocusState.paused;
            final isIdle = focusProvider.state == FocusState.idle;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // Task Indicator (mocked for simplicity here, could sync with active task)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.center_focus_strong, size: 16, color: Colors.white.withValues(alpha: 0.7)),
                      const SizedBox(width: 8),
                      Text(
                        'Deep Focus Mode',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                // Timer UI
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 280,
                      height: 280,
                      child: CircularProgressIndicator(
                        value: focusProvider.progress,
                        strokeWidth: 12,
                        backgroundColor: Colors.white.withValues(alpha: 0.05),
                        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          focusProvider.formattedTime,
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 64,
                            color: Colors.white,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        if (isIdle)
                          TextButton(
                            onPressed: () => _showDurationPicker(context, focusProvider),
                            child: Text(
                              '${focusProvider.durationMinutes} min session',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 64),

                // Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isRunning || isPaused) ...[
                      _buildControlButton(
                        icon: isRunning ? Icons.pause : Icons.play_arrow,
                        onPressed: isRunning ? focusProvider.pause : focusProvider.start,
                        color: Colors.white,
                        isPrimary: true,
                      ),
                      const SizedBox(width: 24),
                      _buildControlButton(
                        icon: Icons.stop,
                        onPressed: focusProvider.stop,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ] else ...[
                      _buildControlButton(
                        icon: Icons.play_arrow,
                        onPressed: focusProvider.start,
                        color: Theme.of(context).primaryColor,
                        isPrimary: true,
                        size: 80,
                      ),
                    ],
                  ],
                ),

                const Spacer(),

                if (isRunning)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32.0),
                    child: Text(
                      'Stay focused. Don\'t close the app.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
    bool isPrimary = false,
    double size = 64,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(size / 2),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isPrimary ? color : Colors.transparent,
          shape: BoxShape.circle,
          border: isPrimary ? null : Border.all(color: color, width: 2),
        ),
        child: Icon(
          icon,
          size: size * 0.5,
          color: isPrimary ? Colors.white : color,
        ),
      ),
    );
  }

  void _showDurationPicker(BuildContext context, FocusProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Select Duration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              ListTile(
                title: const Text('Pomodoro (25 min)'),
                onTap: () {
                  provider.setDuration(25);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Deep Work (50 min)'),
                onTap: () {
                  provider.setDuration(50);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Quick Review (15 min)'),
                onTap: () {
                  provider.setDuration(15);
                  Navigator.pop(context);
                },
              ),
              // Hidden developer option for testing:
              if (const bool.fromEnvironment('dart.vm.product') == false)
                ListTile(
                  title: const Text('Test (1 min)'),
                  onTap: () {
                    provider.setDuration(1);
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
