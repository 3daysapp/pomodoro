import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pomodoro/utils/l10n.dart';

///
///
///
enum PomodoroEvent {
  task(Colors.deepOrange, FontAwesomeIcons.solidCircle, 0),
  shortBreak(Colors.indigoAccent, FontAwesomeIcons.play, 3 / 2 * pi),
  longBreak(Colors.lightGreen, FontAwesomeIcons.solidSquare, 0);

  ///
  ///
  ///
  const PomodoroEvent(this.color, this.icon, this.angle);

  final Color color;
  final IconData icon;
  final double angle;
}

///
///
///
class EventWidget extends StatelessWidget {
  final PomodoroEvent _event;
  final double? _size;
  final bool _enabled;

  ///
  ///
  ///
  const EventWidget({
    required final PomodoroEvent event,
    final double? size,
    final bool enabled = true,
    super.key,
  })  : _event = event,
        _size = size,
        _enabled = enabled;

  ///
  ///
  ///
  @override
  Widget build(final BuildContext context) {
    return Tooltip(
      message: context.t(_event.name),
      child: Transform.rotate(
        angle: _event.angle,
        child: Icon(
          _event.icon,
          color: _enabled ? _event.color : Colors.grey,
          size: _size,
        ),
      ),
    );
  }
}
