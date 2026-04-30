import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:phokat_to_focus/features/planner/providers/planner_provider.dart';
import 'package:phokat_to_focus/core/models/models.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';

// Mock class for Firebase to prevent initialization errors in unit tests
class MockFirebase {
  static Future<void> init() async {}
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('PlannerProvider Logic Tests', () {
    test('Shows procrastination risk correctly', () {
      final provider = PlannerProvider();

      // Override tasks to test logic
      provider.addTask(Task(
        id: '1',
        title: 'Task 1',
        subject: 'Sub',
        scheduledTime: DateTime.now(),
        durationMinutes: 25,
      ));
      provider.addTask(Task(
        id: '2',
        title: 'Task 2',
        subject: 'Sub',
        scheduledTime: DateTime.now(),
        durationMinutes: 25,
      ));

      final now = DateTime.now();

      // It should show risk if it is past 4 PM (16) and 0 tasks are completed
      if (now.hour >= 16) {
        expect(provider.showsProcrastinationRisk, true);
      } else {
        expect(provider.showsProcrastinationRisk, false);
      }
    });

    test('Toggling task completion updates stats', () {
      final provider = PlannerProvider();
      final task = Task(
        id: 'test_task',
        title: 'Task 1',
        subject: 'Sub',
        scheduledTime: DateTime.now(),
        durationMinutes: 25,
      );

      provider.addTask(task);
      expect(provider.completedToday, 0);

      // Initial XP is 0 (or whatever is loaded from mock). We just track the diff.
      final initialXp = provider.stats.xp;

      // Toggle ON
      provider.toggleTaskCompletion('test_task');
      expect(provider.completedToday, 1);
      expect(provider.stats.xp, initialXp + 10);

      // Toggle OFF
      provider.toggleTaskCompletion('test_task');
      expect(provider.completedToday, 0);
      expect(provider.stats.xp, initialXp); // Back to normal
    });
  });
}
