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

  Locale locale = const Locale('en', 'US');

  ///
  ///
  ///
  Future<void> start() async {
    final String? brightness =
        await SharedPreferencesAsync().getString('brightness');

    brightnessNotifier.value = brightness == null
        ? SchedulerBinding.instance.platformDispatcher.platformBrightness
        : brightness.toLowerCase() == 'dark'
            ? Brightness.dark
            : Brightness.light;
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
}
