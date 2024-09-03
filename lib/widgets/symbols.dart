import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pomodoro/utils/l10n.dart';

///
///
///
class TaskSymbol extends StatelessWidget {
  final double? _size;
  final bool _enabled;

  ///
  ///
  ///
  const TaskSymbol({
    final double? size,
    final bool enabled = true,
    super.key,
  })  : _size = size,
        _enabled = enabled;

  ///
  ///
  ///
  @override
  Widget build(final BuildContext context) {
    return Tooltip(
      message: context.t('task'),
      child: Icon(
        FontAwesomeIcons.solidCircle,
        color: _enabled ? Colors.deepOrange : Colors.grey,
        size: _size,
      ),
    );
  }
}

///
///
///
class ShortBreakSymbol extends StatelessWidget {
  final double? _size;
  final bool _enabled;

  ///
  ///
  ///
  const ShortBreakSymbol({
    final double? size,
    final bool enabled = true,
    super.key,
  })  : _size = size,
        _enabled = enabled;

  ///
  ///
  ///
  @override
  Widget build(final BuildContext context) {
    return Tooltip(
      message: context.t('shortBreak'),
      child: Transform.rotate(
        angle: 3 / 2 * pi,
        child: Icon(
          FontAwesomeIcons.play,
          color: _enabled ? Colors.indigoAccent : Colors.grey,
          size: _size,
        ),
      ),
    );
  }
}

///
///
///
class LongBreakSymbol extends StatelessWidget {
  final double? _size;
  final bool _enabled;

  ///
  ///
  ///
  const LongBreakSymbol({
    final double? size,
    final bool enabled = true,
    super.key,
  })  : _size = size,
        _enabled = enabled;

  ///
  ///
  ///
  @override
  Widget build(final BuildContext context) {
    return Tooltip(
      message: context.t('longBreak'),
      child: Icon(
        FontAwesomeIcons.solidSquare,
        color: _enabled ? Colors.lightGreen : Colors.grey,
        size: _size,
      ),
    );
  }
}
