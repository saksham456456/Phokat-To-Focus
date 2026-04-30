import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum FocusState { idle, running, paused, finished }

class FocusProvider extends ChangeNotifier {
  static const platform = MethodChannel('com.example.phokat_to_focus/strict_mode');

  FocusState _state = FocusState.idle;
  int _durationMinutes = 25;
  int _remainingSeconds = 25 * 60;
  Timer? _timer;
  DateTime? _lastTickTime;
  bool _isStrictModeEnabled = false;

  bool get isStrictModeEnabled => _isStrictModeEnabled;

  Future<void> toggleStrictMode(bool value) async {
    if (value) {
      try {
        final bool hasPermission = await platform.invokeMethod('requestOverlayPermission');
        if (hasPermission) {
          _isStrictModeEnabled = true;
        }
      } on PlatformException catch (_) {
        _isStrictModeEnabled = false;
      }
    } else {
      _isStrictModeEnabled = false;
      if (_state == FocusState.running) {
        await platform.invokeMethod('stopStrictMode');
      }
    }
    notifyListeners();
  }

  FocusState get state => _state;
  int get durationMinutes => _durationMinutes;
  int get remainingSeconds => _remainingSeconds;

  String get formattedTime {
    int m = _remainingSeconds ~/ 60;
    int s = _remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  double get progress => 1 - (_remainingSeconds / (_durationMinutes * 60));

  void setDuration(int minutes) {
    if (_state == FocusState.idle) {
      _durationMinutes = minutes;
      _remainingSeconds = minutes * 60;
      notifyListeners();
    }
  }

  void start() async {
    if (_state == FocusState.idle || _state == FocusState.paused) {
      _state = FocusState.running;
      _lastTickTime = DateTime.now();
      _timer = Timer.periodic(const Duration(seconds: 1), _tick);

      if (_isStrictModeEnabled) {
        try {
          await platform.invokeMethod('startStrictMode');
        } catch (_) {}
      }

      notifyListeners();
    }
  }

  void pause() async {
    if (_state == FocusState.running) {
      _timer?.cancel();
      _state = FocusState.paused;
      _lastTickTime = null;

      if (_isStrictModeEnabled) {
        try {
          await platform.invokeMethod('stopStrictMode');
        } catch (_) {}
      }

      notifyListeners();
    }
  }

  void stop() async {
    _timer?.cancel();
    _state = FocusState.idle;
    _remainingSeconds = _durationMinutes * 60;
    _lastTickTime = null;

    if (_isStrictModeEnabled) {
      try {
        await platform.invokeMethod('stopStrictMode');
      } catch (_) {}
    }

    notifyListeners();
  }

  void _tick(Timer timer) {
    if (_state != FocusState.running) return;

    final now = DateTime.now();
    if (_lastTickTime != null) {
      final elapsedSeconds = now.difference(_lastTickTime!).inSeconds;

      // We process the tick in bulk if the app was suspended in the background
      if (elapsedSeconds > 0) {
        _remainingSeconds -= elapsedSeconds;
        _lastTickTime = now;
      }
    } else {
      _lastTickTime = now;
      _remainingSeconds--;
    }

    if (_remainingSeconds <= 0) {
      _remainingSeconds = 0;
      _timer?.cancel();
      _state = FocusState.finished;
      _lastTickTime = null;

      if (_isStrictModeEnabled) {
        try {
          platform.invokeMethod('stopStrictMode');
        } catch (_) {}
      }
    }

    notifyListeners();
  }

  void reset() {
    stop();
  }
}
