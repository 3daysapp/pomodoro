import 'dart:math';

import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pomodoro/utils/config.dart';
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          /// Task Duration
          ListTile(
            leading: const Icon(
              FontAwesomeIcons.solidCircle,
              color: Colors.deepOrange,
            ),
            title: Text(
              '${context.t('taskDuration')}: '
              '${Config().taskDuration.parse()}',
            ),
            onTap: () async {
              final Duration? duration = await showDurationPicker(
                context: context,
                initialTime: Config().taskDuration,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                ),
              );

              if (duration != null) {
                setState(() {
                  Config().taskDuration = duration;
                });
              }
            },
          ),

          /// Short Break Duration
          ListTile(
            leading: Transform.rotate(
              angle: 3 / 2 * pi,
              child: const Icon(
                FontAwesomeIcons.play,
                color: Colors.indigoAccent,
              ),
            ),
            title: Text(
              '${context.t('shortBreakDuration')}: '
              '${Config().shortBreakDuration.parse()}',
            ),
            onTap: () async {
              final Duration? duration = await showDurationPicker(
                context: context,
                initialTime: Config().shortBreakDuration,
              );

              if (duration != null) {
                setState(() {
                  Config().shortBreakDuration = duration;
                });
              }
            },
          ),

          /// Long Break Duration
          ListTile(
            leading: const Icon(
              FontAwesomeIcons.solidSquare,
              color: Colors.lightGreen,
            ),
            title: Text(
              '${context.t('longBreakDuration')}: '
              '${Config().longBreakDuration.parse()}',
            ),
            onTap: () async {
              final Duration? duration = await showDurationPicker(
                context: context,
                initialTime: Config().longBreakDuration,
              );

              if (duration != null) {
                setState(() {
                  Config().longBreakDuration = duration;
                });
              }
            },
          ),

          // TODO(anyone): Create task quantity.

          /// Toggle Brightness
          ListTile(
            leading: Config().brightness == Brightness.dark
                ? const Icon(
                    FontAwesomeIcons.solidSun,
                    color: Colors.yellow,
                  )
                : const Icon(
                    FontAwesomeIcons.solidMoon,
                    color: Colors.black87,
                  ),
            title: Text(context.t('toggleBrightness')),
            onTap: () async {
              await Config().setBrightness(
                Config().brightness == Brightness.dark
                    ? Brightness.light
                    : Brightness.dark,
              );
            },
          ),

          ElevatedButton(
            onPressed: () async {
              await showTimePicker(
                  context: context, initialTime: TimeOfDay.now());
            },
            child: const Text('Test'),
          ),
        ],
      ),
    );
  }
}
