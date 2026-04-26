import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/models/models.dart';

class PlannerProvider extends ChangeNotifier {
  FirebaseFirestore? _firestore;
  FirebaseAuth? _auth;
  List<Task> _tasks = [];
  UserStats _stats = UserStats();

  List<Task> get tasks => _tasks;
  UserStats get stats => _stats;

  List<Task> get todayTasks {
    final now = DateTime.now();
    return _tasks.where((t) =>
      t.scheduledTime.year == now.year &&
      t.scheduledTime.month == now.month &&
      t.scheduledTime.day == now.day
    ).toList()..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
  }

  int get completedToday {
    return todayTasks.where((t) => t.isCompleted).length;
  }

  int get totalToday {
    return todayTasks.length;
  }

  bool get showsProcrastinationRisk {
    final tasks = todayTasks;
    if (tasks.isEmpty) return false;

    final completed = completedToday;
    final now = DateTime.now();

    // Rule: If it's past 4 PM, they have at least 2 tasks, and completed 0, they are procrastinating.
    if (now.hour >= 16 && tasks.length >= 2 && completed == 0) {
      return true;
    }

    // Rule: If completion rate is less than 20% and it's near the end of the day (8 PM)
    if (now.hour >= 20 && completed / tasks.length < 0.2) {
      return true;
    }

    return false;
  }

  PlannerProvider() {
    try {
      _firestore = FirebaseFirestore.instance;
      _auth = FirebaseAuth.instance;
    } catch (_) {
      debugPrint("Firebase not initialized yet. Planner using local storage only.");
    }
    _loadData();
  }

  Future<void> _loadData() async {
    final user = _auth?.currentUser;

    if (user != null && _firestore != null) {
      // Load strictly from Firebase based on the user's UID
      try {
        final doc = await _firestore!.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data()!.containsKey('stats')) {
          _stats = UserStats.fromJson(doc.data()!['stats']);
        } else {
          _stats = UserStats(streak: 0, xp: 0, totalFocusMinutes: 0);
        }

        final tasksSnapshot = await _firestore!.collection('users').doc(user.uid).collection('tasks').get();
        if (tasksSnapshot.docs.isNotEmpty) {
          _tasks = tasksSnapshot.docs.map((doc) => Task.fromJson(doc.data())).toList();
        } else {
          _tasks = [];
        }
      } catch (e) {
        debugPrint("Failed to load from Firebase: \$e");
        _tasks = [];
        _stats = UserStats();
      }
    } else {
      // Offline / Unauthenticated fallback
      final prefs = await SharedPreferences.getInstance();

      final statsJson = prefs.getString('user_stats');
      if (statsJson != null) {
        _stats = UserStats.fromJson(jsonDecode(statsJson));
      } else {
        _stats = UserStats(streak: 0, xp: 0, totalFocusMinutes: 0);
      }

      final tasksJson = prefs.getStringList('user_tasks');
      if (tasksJson != null) {
        _tasks = tasksJson.map((t) => Task.fromJson(jsonDecode(t))).toList();
      } else {
        _tasks = [];
      }
    }

    notifyListeners();
  }

  /// Called when a user logs out, to clear the local memory of tasks
  void clearData() {
    _tasks = [];
    _stats = UserStats();
    notifyListeners();
  }

  /// Called when a user logs in, to force a sync from Firestore
  void syncUser() {
    _loadData();
  }

  Future<void> _saveData() async {
    // Save Locally
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_stats', jsonEncode(_stats.toJson()));

    final tasksJsonList = _tasks.map((t) => jsonEncode(t.toJson())).toList();
    await prefs.setStringList('user_tasks', tasksJsonList);

    // Sync with Firebase (if logged in)
    if (_auth != null && _firestore != null) {
      try {
        final user = _auth!.currentUser;
        if (user != null) {
          // We do not await this, so it doesn't block the UI
          _firestore!.collection('users').doc(user.uid).set({
            'stats': _stats.toJson(),
          }, SetOptions(merge: true));

          // Syncing tasks batch (Simplified for MVP)
          final batch = _firestore!.batch();
          for (var task in _tasks) {
            final docRef = _firestore!.collection('users').doc(user.uid).collection('tasks').doc(task.id);
            batch.set(docRef, task.toJson());
          }
          batch.commit();
        }
      } catch (e) {
        debugPrint("Firebase sync failed (Likely not configured yet): $e");
      }
    }
  }

  // Legacy method for fallback, safe to remove later
  void loadMockData() { }

  void addTask(Task task) {
    _tasks.add(task);
    _saveData();
    notifyListeners();
  }

  void toggleTaskCompletion(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index >= 0) {
      final task = _tasks[index];
      _tasks[index] = task.copyWith(isCompleted: !task.isCompleted);

      // Update XP
      if (_tasks[index].isCompleted) {
        _stats = _stats.copyWith(xp: _stats.xp + 10);
      } else {
        // Prevent XP from dropping below 0 when untoggling tasks
        int newXp = _stats.xp - 10;
        if (newXp < 0) newXp = 0;
        _stats = _stats.copyWith(xp: newXp);
      }

      _saveData();
      notifyListeners();
    }
  }

  void addFocusMinutes(int minutes) {
    _stats = _stats.copyWith(
      totalFocusMinutes: _stats.totalFocusMinutes + minutes,
      xp: _stats.xp + (minutes ~/ 5), // 1 XP for every 5 mins
    );
    _saveData();
    notifyListeners();
  }
}
