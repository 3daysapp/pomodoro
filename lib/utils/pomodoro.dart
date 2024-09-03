import 'dart:async';

import 'package:pomodoro/utils/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

///
///
///
class Pomodoro {
  static final Pomodoro _singleton = Pomodoro._internal();

  ///
  ///
  ///
  factory Pomodoro() {
    return _singleton;
  }

  ///
  ///
  ///
  Pomodoro._internal() {
    final SharedPreferencesAsync prefs = SharedPreferencesAsync();

    unawaited(
      prefs
          .getInt('pomodoroStartedAt')
          .then((final int? value) => _startedAt = value ?? 0),
    );

    unawaited(
      prefs
          .getInt('pomodoroPausedAt')
          .then((final int? value) => _pausedAt = value ?? 0),
    );

    unawaited(
      prefs
          .getBool('paused')
          .then((final bool? value) => _paused = value ?? true),
    );

    unawaited(
      prefs
          .getInt('pomodoroCurrentTask')
          .then((final int? value) => _currentTask = value ?? 0),
    );

    unawaited(
      prefs.getInt('pomodoroTaskDuration').then(
            (final int? value) => _taskDuration = value == null
                ? const Duration(minutes: 25)
                : Duration(seconds: value),
          ),
    );

    unawaited(
      prefs.getInt('pomodoroShortBreakDuration').then(
            (final int? value) => _shortBreakDuration = value == null
                ? const Duration(minutes: 5)
                : Duration(seconds: value),
          ),
    );

    unawaited(
      prefs.getInt('pomodoroLongBreakDuration').then(
            (final int? value) => _longBreakDuration = value == null
                ? const Duration(minutes: 15)
                : Duration(seconds: value),
          ),
    );

    unawaited(
      prefs
          .getInt('pomodoroTaskQuantity')
          .then((final int? value) => _taskQuantity = value ?? 4),
    );
  }

  int _startedAt = 0;
  int _pausedAt = 0;
  bool _paused = true;
  int _currentTask = 0;
  Duration _taskDuration = const Duration(minutes: 25);
  Duration _shortBreakDuration = const Duration(minutes: 5);
  Duration _longBreakDuration = const Duration(minutes: 15);
  int _taskQuantity = 4;

  ///
  ///
  ///
  bool get paused => _paused;

  ///
  ///
  ///
  int get taskDuration => _taskDuration.inSeconds;

  ///
  ///
  ///
  int get shortBreakDuration => _shortBreakDuration.inSeconds;

  ///
  ///
  ///
  int get longBreakDuration => _longBreakDuration.inSeconds;

  ///
  ///
  ///
  int get taskQuantity => _taskQuantity;

  ///
  ///
  ///
  int get currentTask => _currentTask;

  ///
  ///
  ///
  Future<void> reset() async {
    _startedAt = 0;
    _pausedAt = 0;
    _paused = true;
    _currentTask = 0;

    final Config config = Config();

    _taskDuration = config.taskDuration;
    _shortBreakDuration = config.shortBreakDuration;
    _longBreakDuration = config.longBreakDuration;
    _taskQuantity = config.taskQuantity;

    await persist();
  }

  ///
  ///
  ///
  Future<void> persist() async {
    final SharedPreferencesAsync prefs = SharedPreferencesAsync();

    await prefs.setInt(
      'pomodoroStartedAt',
      _startedAt,
    );

    await prefs.setInt(
      'pomodoroPausedAt',
      _pausedAt,
    );

    await prefs.setBool(
      'pomodoroPaused',
      _paused,
    );

    await prefs.setInt(
      'pomodoroTaskDuration',
      _taskDuration.inSeconds,
    );

    await prefs.setInt(
      'pomodoroShortBreakDuration',
      _shortBreakDuration.inSeconds,
    );

    await prefs.setInt(
      'pomodoroLongBreakDuration',
      _longBreakDuration.inSeconds,
    );

    await prefs.setInt(
      'pomodoroTaskQuantity',
      _taskQuantity,
    );

    await prefs.setInt(
      'pomodoroCurrentTask',
      _currentTask,
    );
  }
}
