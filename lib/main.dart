import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:pomodoro/util/config.dart';
import 'package:pomodoro/view/home.dart';
import 'package:pomodoro/view/settings.dart';

///
///
///
void main() async {
  bool debug = false;
  assert(debug = true);
  Config config = Config();
  config.debug = debug;

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  if (debug) {
    runApp(PomodoroTimer());
  } else {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

    runZonedGuarded(() {
      runApp(PomodoroTimer());
    }, FirebaseCrashlytics.instance.recordError);
  }
}

///
///
///
class PomodoroTimer extends StatelessWidget {
  final bool disableNotifications;

  static FirebaseAnalytics analytics = FirebaseAnalytics();

  const PomodoroTimer({Key key, this.disableNotifications = false})
      : super(key: key);

  ///
  ///
  ///
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: FlutterUdid.consistentUdid,
      builder: (context, snapshot) {
        if (snapshot.hasData || snapshot.hasError) {
          if (snapshot.hasData) {
            FirebaseCrashlytics.instance.setUserIdentifier(snapshot.data);
          }

          return MaterialApp(
            title: 'Pomodoro Timer',
            theme: ThemeData(
              primarySwatch: Colors.red,
            ),
            home: Home(disableNotifications: disableNotifications),
            routes: {
              '/home': (_) => Home(),
              '/settings': (_) => Settings(),
            },
            navigatorObservers: [
              FirebaseAnalyticsObserver(analytics: analytics),
            ],
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: [
              Locale('pt', 'BR'),
            ],
          );
        }

        // TODO - Melhorar a tela branca.
        return Container(
          color: Colors.white,
        );
      },
    );
  }
}
