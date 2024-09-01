import 'package:flutter/material.dart';
import 'package:pomodoro/config.dart';
import 'package:pomodoro/utils/l10n.dart';

///
///
///
class Settings extends StatefulWidget {
  ///
  ///
  ///
  const Settings({super.key});

  ///
  ///
  ///
  @override
  State<Settings> createState() => _SettingsState();
}

///
///
///
class _SettingsState extends State<Settings> {
  ///
  ///
  ///
  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t('settings')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              context.t('settings'),
              textAlign: TextAlign.center,
            ),
            ElevatedButton(
              onPressed: () async {
                await Config().setBrightness(
                  Config().brightness == Brightness.dark
                      ? Brightness.light
                      : Brightness.dark,
                );
              },
              child: Text(context.t('toggleBrightness')),
            ),
          ],
        ),
      ),
    );
  }
}
