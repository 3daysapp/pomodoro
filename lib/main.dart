import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pomodoro/view/Home.dart';
import 'package:pomodoro/view/Settings.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_udid/flutter_udid.dart';

///
///
///
void main() {
  bool debug = false;

  assert(debug = true);

  if (debug) {
    runApp(PomodoroTimer());
  } else {
    Crashlytics.instance.enableInDevMode = false;
    FlutterError.onError = Crashlytics.instance.recordFlutterError;

    runZoned<Future<void>>(
      () async => runApp(PomodoroTimer()),
      onError: Crashlytics.instance.recordError,
    );
  }
}

///
///
///
class PomodoroTimer extends StatelessWidget {
  final bool disableNotifications;

  const PomodoroTimer({Key key, this.disableNotifications = false})
      : super(key: key);

  ///
  ///
  ///
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      stream: FlutterUdid.consistentUdid.asStream(),
      builder: (context, snapshot) {
        if (snapshot.hasData || snapshot.hasError) {
          if (snapshot.hasData) {
            Crashlytics.instance.setUserIdentifier(snapshot.data);
          }

          return MaterialApp(
            title: 'Pomodoro Timer',
            theme: ThemeData(
              primarySwatch: Colors.red,
            ),
            home: Home(disableNotifications: disableNotifications),
            routes: getRoutes(context),
          );
        }
        return CircularProgressIndicator();
      },
    );
  }

  ///
  ///
  ///
  static Map<String, WidgetBuilder> getRoutes(BuildContext context) {
    return {
      '/home': (_) => Home(),
      '/settings': (_) => Settings(),
    };
  }
}
