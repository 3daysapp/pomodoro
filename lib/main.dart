import 'package:flutter/material.dart';
import 'package:pomodoro/config.dart';
import 'package:pomodoro/views/home.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

///
///
///
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Keep the screen on.
  await WakelockPlus.enable();

  /// Start the configuration.
  await Config().start();

  runApp(const MyApp());
}

///
///
///
class MyApp extends StatelessWidget {
  ///
  ///
  ///
  const MyApp({super.key});

  ///
  ///
  ///
  @override
  Widget build(final BuildContext context) {
    return ValueListenableBuilder<Brightness>(
      valueListenable: Config().brightnessNotifier,
      builder: (_, final Brightness brightness, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Pomodoro Timer',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepOrange,
              brightness: brightness,
            ),
            useMaterial3: true,
            brightness: brightness,
          ),
          home: const Home(),
        );
      },
    );
  }
}
