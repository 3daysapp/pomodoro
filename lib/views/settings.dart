import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pomodoro/utils/config.dart';
import 'package:pomodoro/utils/l10n.dart';
import 'package:pomodoro/widgets/pomodoro_event.dart';

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
  final TextEditingController _controller =
      TextEditingController(text: Config().taskQuantity.toString());
  final int _min = 1;
  final int _max = 20;

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
          /// Task Quantity
          ListTile(
            title: Row(
              children: <Widget>[
                Text('${context.t('taskQuantity')}:'),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: Config().taskQuantity > _min
                      ? () {
                          setState(() => Config().taskQuantity--);
                          _controller.text = Config().taskQuantity.toString();
                        }
                      : null,
                  icon: const Icon(FontAwesomeIcons.minus),
                ),
                Flexible(
                  child: TextField(
                    controller: _controller,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (final String value) {
                      int taskQuantity = int.tryParse(value) ?? _min;

                      if (taskQuantity < _min) {
                        taskQuantity = _min;
                      }

                      if (taskQuantity > _max) {
                        taskQuantity = _max;
                      }

                      setState(() {
                        Config().taskQuantity = taskQuantity;
                        _controller.value = TextEditingValue(
                          text: taskQuantity.toString(),
                          selection: TextSelection.fromPosition(
                            TextPosition(
                              offset: taskQuantity.toString().length,
                            ),
                          ),
                        );
                      });
                    },
                  ),
                ),
                IconButton(
                  onPressed: Config().taskQuantity < _max
                      ? () {
                          setState(() => Config().taskQuantity++);
                          _controller.text = Config().taskQuantity.toString();
                        }
                      : null,
                  icon: const Icon(FontAwesomeIcons.plus),
                ),
                Flexible(child: Container()),
              ],
            ),
          ),

          /// Task Duration
          ListTile(
            leading: const EventWidget(event: PomodoroEvent.task),
            title: Text(
              '${context.t('taskDuration')}: '
              '${Config().taskDuration.parse()}',
            ),
            onTap: () async {
              final Duration? duration = await showDurationPicker(
                context: context,
                title: Text(
                  context.t('taskDuration'),
                  textAlign: TextAlign.center,
                ),
                initialTime: Config().taskDuration,
              );
              if (duration != null) {
                setState(() => Config().taskDuration = duration);
              }
            },
          ),

          /// Short Break Duration
          ListTile(
            leading: const EventWidget(event: PomodoroEvent.shortBreak),
            title: Text(
              '${context.t('shortBreakDuration')}: '
              '${Config().shortBreakDuration.parse()}',
            ),
            onTap: () async {
              final Duration? duration = await showDurationPicker(
                context: context,
                title: Text(
                  context.t('shortBreakDuration'),
                  textAlign: TextAlign.center,
                ),
                initialTime: Config().shortBreakDuration,
              );

              if (duration != null) {
                setState(() => Config().shortBreakDuration = duration);
              }
            },
          ),

          /// Long Break Duration
          ListTile(
            leading: const EventWidget(event: PomodoroEvent.longBreak),
            title: Text(
              '${context.t('longBreakDuration')}: '
              '${Config().longBreakDuration.parse()}',
            ),
            onTap: () async {
              final Duration? duration = await showDurationPicker(
                context: context,
                title: Text(
                  context.t('longBreakDuration'),
                  textAlign: TextAlign.center,
                ),
                initialTime: Config().longBreakDuration,
              );

              if (duration != null) {
                setState(() => Config().longBreakDuration = duration);
              }
            },
          ),

          /// Play Sound
          SwitchListTile(
            title: Row(
              children: <Widget>[
                Icon(
                  Config().playSound
                      ? FontAwesomeIcons.volumeHigh
                      : FontAwesomeIcons.volumeXmark,
                ),
                const SizedBox(width: 16),
                Text(context.t('playSound')),
              ],
            ),
            value: Config().playSound,
            onChanged: (final bool value) =>
                setState(() => Config().playSound = value),
          ),

          /// Auto Pause
          SwitchListTile(
            title: Row(
              children: <Widget>[
                Icon(
                  Config().autoPause
                      ? FontAwesomeIcons.solidCirclePause
                      : FontAwesomeIcons.circlePause,
                ),
                const SizedBox(width: 16),
                Text(context.t('autoPause')),
              ],
            ),
            value: Config().autoPause,
            onChanged: (final bool value) =>
                setState(() => Config().autoPause = value),
          ),

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
            onTap: Config().toggleBrightness,
          ),
        ],
      ),
    );
  }
}
