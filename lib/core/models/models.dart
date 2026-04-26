class Task {
  final String id;
  final String title;
  final String subject;
  final DateTime scheduledTime;
  final int durationMinutes;
  final bool isCompleted;
  final int priority;

  Task({
    required this.id,
    required this.title,
    required this.subject,
    required this.scheduledTime,
    required this.durationMinutes,
    this.isCompleted = false,
    this.priority = 1,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      subject: json['subject'],
      scheduledTime: DateTime.parse(json['scheduledTime']),
      durationMinutes: json['durationMinutes'],
      isCompleted: json['isCompleted'] ?? false,
      priority: json['priority'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'scheduledTime': scheduledTime.toIso8601String(),
      'durationMinutes': durationMinutes,
      'isCompleted': isCompleted,
      'priority': priority,
    };
  }

  Task copyWith({
    String? id,
    String? title,
    String? subject,
    DateTime? scheduledTime,
    int? durationMinutes,
    bool? isCompleted,
    int? priority,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
    );
  }
}

class UserStats {
  final int streak;
  final int xp;
  final int totalFocusMinutes;
  final int level;

  UserStats({
    this.streak = 0,
    this.xp = 0,
    this.totalFocusMinutes = 0,
    this.level = 1,
  });

  // Calculate XP needed for next level (simple curve: 100 * level)
  int get xpForNextLevel => level * 100;

  // Calculate progress percentage to next level
  double get levelProgress => (xp % xpForNextLevel) / xpForNextLevel;

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      streak: json['streak'] ?? 0,
      xp: json['xp'] ?? 0,
      totalFocusMinutes: json['totalFocusMinutes'] ?? 0,
      level: json['level'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'streak': streak,
      'xp': xp,
      'totalFocusMinutes': totalFocusMinutes,
      'level': level,
    };
  }

  UserStats copyWith({
    int? streak,
    int? xp,
    int? totalFocusMinutes,
    int? level,
  }) {
    // Automatically handle leveling up if passing new XP
    int newXp = xp ?? this.xp;
    int currentLevel = level ?? this.level;

    // Check if we gained enough XP to level up
    while (newXp >= (currentLevel * 100)) {
      newXp -= (currentLevel * 100);
      currentLevel++;
    }

    return UserStats(
      streak: streak ?? this.streak,
      xp: newXp,
      totalFocusMinutes: totalFocusMinutes ?? this.totalFocusMinutes,
      level: currentLevel,
    );
  }
}
