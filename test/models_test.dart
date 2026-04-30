import 'package:flutter_test/flutter_test.dart';
import 'package:phokat_to_focus/core/models/models.dart';

void main() {
  group('UserStats Model Tests', () {
    test('Calculates level correctly when gaining XP', () {
      // Start at level 1 with 0 XP
      var stats = UserStats(level: 1, xp: 0);

      // Level 1 needs 100 XP to reach Level 2
      stats = stats.copyWith(xp: 150);

      expect(stats.level, 2);
      expect(stats.xp, 50); // 150 - 100

      // Level 2 needs 200 XP to reach Level 3
      stats = stats.copyWith(xp: stats.xp + 200); // Has 50, adding 200 = 250. Needs 200 to level up.

      expect(stats.level, 3);
      expect(stats.xp, 50); // 250 - 200
    });

    test('Calculates level progress percentage correctly', () {
      final stats = UserStats(level: 2, xp: 100); // Needs 200 XP to level up
      expect(stats.levelProgress, 0.5); // 100/200 = 50%
    });
  });

  group('Task Model Tests', () {
    test('JSON serialization works correctly', () {
      final now = DateTime.now();
      final task = Task(
        id: '123',
        title: 'Study Math',
        subject: 'Math',
        scheduledTime: now,
        durationMinutes: 45,
        isCompleted: true,
      );

      final json = task.toJson();
      final reconstructedTask = Task.fromJson(json);

      expect(reconstructedTask.id, task.id);
      expect(reconstructedTask.title, task.title);
      expect(reconstructedTask.isCompleted, true);
      // We check difference because stringifying drops microseconds sometimes
      expect(reconstructedTask.scheduledTime.difference(now).inSeconds, 0);
    });
  });
}
