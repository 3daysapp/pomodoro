import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

///
///
///
class Config {
  static final Config _singleton = Config._internal();

  static List<Locale> supportedLocales = <Locale>[
    const Locale('en', 'US'),
  ];

  ///
  ///
  ///
  factory Config() {
    return _singleton;
  }

  ///
  ///
  ///
  Config._internal();

  final ValueNotifier<Brightness> brightnessNotifier =
      ValueNotifier<Brightness>(Brightness.light);

  // TODO(anyone): Save to SharedPreferences.
  Locale locale = const Locale('en', 'US');

  Duration _taskDuration = const Duration(minutes: 25);
  Duration _shortBreakDuration = const Duration(minutes: 5);
  Duration _longBreakDuration = const Duration(minutes: 15);

  ///
  ///
  ///
  Future<void> start() async {
    final SharedPreferencesAsync prefs = SharedPreferencesAsync();

    final String? brightness = await prefs.getString('brightness');

    brightnessNotifier.value = brightness == null
        ? SchedulerBinding.instance.platformDispatcher.platformBrightness
        : brightness.toLowerCase() == 'dark'
            ? Brightness.dark
            : Brightness.light;

    final int? taskInt = await prefs.getInt('taskDuration');

    _taskDuration = taskInt == null
        ? const Duration(minutes: 25)
        : Duration(seconds: taskInt);
  }

  ///
  ///
  ///
  Brightness get brightness => brightnessNotifier.value;

  ///
  ///
  ///
  Future<void> setBrightness(final Brightness brightness) async {
    brightnessNotifier.value = brightness;
    await SharedPreferencesAsync().setString('brightness', brightness.name);
  }

  ///
  ///
  ///
  Duration get taskDuration => _taskDuration;

  ///
  ///
  ///
  set taskDuration(final Duration duration) {
    _taskDuration = duration;
    unawaited(
      SharedPreferencesAsync().setInt('taskDuration', duration.inSeconds),
    );
  }

  ///
  ///
  ///
  Duration get shortBreakDuration => _shortBreakDuration;

  ///
  ///
  ///
  set shortBreakDuration(final Duration duration) {
    _shortBreakDuration = duration;
    unawaited(
      SharedPreferencesAsync().setInt('shortBreakDuration', duration.inSeconds),
    );
  }

  ///
  ///
  ///
  Duration get longBreakDuration => _longBreakDuration;

  ///
  ///
  ///
  set longBreakDuration(final Duration duration) {
    _longBreakDuration = duration;
    unawaited(
      SharedPreferencesAsync().setInt('longBreakDuration', duration.inSeconds),
    );
  }
}

///
///
///
extension Durationparsing on Duration {
  String parse() => toString().split('.').first;
}
