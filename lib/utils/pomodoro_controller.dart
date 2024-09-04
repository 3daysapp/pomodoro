import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pomodoro/utils/config.dart';
import 'package:pomodoro/widgets/pomodoro_event.dart';
import 'package:shared_preferences/shared_preferences.dart';

///
///
///
class PomodoroController {
  int _startedAt = 0;
  bool _paused = true;
  Duration _remaining = Duration.zero;
  int _currentTask = 0;
  Duration _taskDuration = const Duration(minutes: 25);
  Duration _shortBreakDuration = const Duration(minutes: 5);
  Duration _longBreakDuration = const Duration(minutes: 15);
  int _taskQuantity = 4;

  ///
  ///
  ///
  PomodoroController() {
    final SharedPreferencesAsync prefs = SharedPreferencesAsync();

    unawaited(
      prefs
          .getInt('pomodoroStartedAt')
          .then((final int? value) => _startedAt = value ?? 0),
    );

    unawaited(
      prefs
          .getBool('pomodoroPaused')
          .then((final bool? value) => _paused = value ?? true),
    );

    unawaited(
      prefs.getInt('pomodoroRemaining').then(
            (final int? value) => _remaining =
                value == null ? Duration.zero : Duration(seconds: value),
          ),
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

  ///
  ///
  ///
  String get remaining => _remaining.parse();

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
  PomodoroEvent _getEventType(final int index) => index.isEven
      ? PomodoroEvent.task
      : index == _taskQuantity * 2 - 1
          ? PomodoroEvent.longBreak
          : PomodoroEvent.shortBreak;

  ///
  ///
  ///
  PomodoroEvent get currentEvent => _getEventType(_currentTask);

  ///
  ///
  ///
  List<Widget> get events {
    return List<Widget>.generate(
      _taskQuantity * 2,
      (final int index) => EventWidget(
        event: _getEventType(index),
        size: index == _currentTask ? 36 : 24,
        enabled: index >= _currentTask,
      ),
    );
  }

  ///
  ///
  ///
  double? get progress {
    if (_paused) {
      return null;
    }

    final Duration duration = switch (_getEventType(_currentTask)) {
      PomodoroEvent.task => _taskDuration,
      PomodoroEvent.shortBreak => _shortBreakDuration,
      PomodoroEvent.longBreak => _longBreakDuration
    };

    return 1.0 -
        _remaining.inSeconds.toDouble() / duration.inSeconds.toDouble();
  }

  ///
  ///
  ///
  Future<void> reset() async {
    final Config config = Config();

    _startedAt = 0;
    _paused = true;
    _remaining = config.taskDuration;
    _currentTask = 0;

    _taskDuration = config.taskDuration;
    _shortBreakDuration = config.shortBreakDuration;
    _longBreakDuration = config.longBreakDuration;
    _taskQuantity = config.taskQuantity;

    await _persist();
  }

  ///
  ///
  ///
  Future<void> update() async {
    if (kDebugMode) {
      print('Update: ${DateTime.now()}');
    }

    if (!_paused) {
      if (_startedAt <= 0) {
        _startedAt = DateTime.now().millisecondsSinceEpoch;

        // _remaining = switch (_getEventType(_currentTask)) {
        //   PomodoroEvent.task => _taskDuration,
        //   PomodoroEvent.shortBreak => _shortBreakDuration,
        //   PomodoroEvent.longBreak => _longBreakDuration
        // };
      }

      _remaining = _remaining - const Duration(seconds: 1);

      if (_remaining.inSeconds <= 0) {
        _currentTask++;

        if (_currentTask >= _taskQuantity * 2) {
          _currentTask = 0;
        }

        _remaining = switch (_getEventType(_currentTask)) {
          PomodoroEvent.task => _taskDuration,
          PomodoroEvent.shortBreak => _shortBreakDuration,
          PomodoroEvent.longBreak => _longBreakDuration
        };

        _startedAt = 0;
        _paused = true;
        // TODO(edufolly): Play sound
      }

      await _persist();
    }
  }

  ///
  ///
  ///
  Future<void> playPause() async {
    if (_paused) {
      _paused = false;
    } else {
      _paused = true;
    }

    await _persist();
  }

  ///
  ///
  ///
  Future<void> _persist() async {
    final SharedPreferencesAsync prefs = SharedPreferencesAsync();

    await prefs.setInt(
      'pomodoroStartedAt',
      _startedAt,
    );

    await prefs.setBool(
      'pomodoroPaused',
      _paused,
    );

    await prefs.setInt(
      'pomodoroRemaining',
      _remaining.inSeconds,
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
