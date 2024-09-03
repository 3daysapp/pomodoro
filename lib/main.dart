import 'package:duration_picker/localization/localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18next/i18next.dart';
import 'package:pomodoro/firebase_options.dart';
import 'package:pomodoro/utils/config.dart';
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

  /// Firebase initialization.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Pass all uncaught "fatal" errors from the framework to Crashlytics.
  FlutterError.onError = (final FlutterErrorDetails errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  // Pass all uncaught asynchronous errors that aren't handled by the Flutter
  // framework to Crashlytics
  PlatformDispatcher.instance.onError = (
    final Object error,
    final StackTrace stack,
  ) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

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
          title: 'Super Pomodoro Timer',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepOrange,
              brightness: brightness,
            ),
            useMaterial3: true,
            brightness: brightness,
          ),
          home: const Home(),
          localizationsDelegates: <LocalizationsDelegate<dynamic>>[
            DurationPickerLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            I18NextLocalizationDelegate(
              locales: Config.supportedLocales,
              dataSource: AssetBundleLocalizationDataSource(
                bundlePath: 'l10n',
              ),
            ),
          ],
          locale: Config().locale,
          supportedLocales: Config.supportedLocales,
        );
      },
    );
  }
}
