import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pomodoro/utils/l10n.dart';
import 'package:pomodoro/utils/pomodoro_controller.dart';
import 'package:pomodoro/views/settings.dart';
import 'package:pomodoro/widgets/pomodoro_event.dart';

///
///
///
class Home extends StatefulWidget {
  ///
  ///
  ///
  const Home({super.key});

  ///
  ///
  ///
  @override
  State<Home> createState() => _HomeState();
}

///
///
///
class _HomeState extends State<Home> {
  final PomodoroController _controller = PomodoroController();

  ///
  ///
  ///
  @override
  void initState() {
    Timer.periodic(const Duration(seconds: 1), updateScreen);
    super.initState();
  }

  ///
  ///
  ///
  Future<void> updateScreen(final Timer timer) async {
    await _controller.update();
    setState(() {});
  }

  ///
  ///
  ///
  Future<bool> yesNoDialog({
    required final BuildContext context,
    required final String message,
    final String title = 'Attention',
    final String affirmative = 'Yes',
    final String negative = 'No',
    final bool marked = false,
    final bool scrollable = false,
  }) async =>
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (final BuildContext context) => AlertDialog(
          title: Text(title),
          content: SelectableText(message),
          scrollable: scrollable,
          actions: marked
              ? <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(negative),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(affirmative),
                  ),
                ]
              : <Widget>[
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(negative),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(affirmative),
                  ),
                ],
        ),
      ) ??
      false;

  ///
  ///
  ///
  @override
  Widget build(final BuildContext context) {
    final PomodoroEvent currentEvent = _controller.currentEvent;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t('pomodoro')),
        actions: <Widget>[
          if (kDebugMode)
            IconButton(
              icon: const Icon(
                FontAwesomeIcons.wrench,
                color: Colors.transparent,
              ),
              onPressed: () async {
                _controller.next();
                setState(() {});
              },
            ),
          IconButton(
            icon: const Icon(FontAwesomeIcons.boltLightning),
            onPressed: _reset,
            tooltip: context.t('reset'),
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: <Widget>[
                  /// Settings
                  ListTile(
                    leading: const Icon(FontAwesomeIcons.wrench),
                    title: Text(context.t('settings')),
                    onTap: () async {
                      Navigator.of(context).pop();
                      await Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (final BuildContext context) =>
                              const Settings(),
                        ),
                      );
                      setState(() {});
                    },
                  ),

                  /// Reset
                  ListTile(
                    leading: const Icon(FontAwesomeIcons.boltLightning),
                    title: Text(context.t('reset')),
                    onTap: () async {
                      Navigator.of(context).pop();
                      await _reset();
                    },
                  ),
                ],
              ),
            ),
            FutureBuilder<PackageInfo>(
              // FutureBuilder is not used for this?
              // ignore: discarded_futures
              future: PackageInfo.fromPlatform(),
              builder: (
                final BuildContext context,
                final AsyncSnapshot<PackageInfo> snapshot,
              ) {
                if (snapshot.hasData) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 8, 8),
                    child: Text(
                      context.t(
                        'version',
                        variables: <String, String>{
                          'version': snapshot.data?.version ?? 'ERROR',
                        },
                      ),
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Center(
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.stretch,
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.end,
                spacing: 8,
                runSpacing: 8,
                children: _controller.events,
              ),
              Text(
                context.t(currentEvent.name),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              Expanded(
                child: FittedBox(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: SizedBox(
                      height: 40,
                      width: 40,
                      child: FittedBox(
                        child: Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            CircularProgressIndicator(
                              strokeWidth: 1.5,
                              value: _controller.progress,
                              color: currentEvent.color,
                              backgroundColor: Colors.grey.withOpacity(0.5),
                            ),
                            Text(
                              _controller.remaining,
                              textScaler: const TextScaler.linear(0.68),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              FloatingActionButton(
                onPressed: () async {
                  await _controller.playPause();
                  setState(() {});
                },
                tooltip: context.t(_controller.paused ? 'play' : 'pause'),
                backgroundColor: currentEvent.color.withOpacity(0.8),
                child: Icon(
                  _controller.paused
                      ? FontAwesomeIcons.play
                      : FontAwesomeIcons.pause,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///
  ///
  ///
  Future<void> _reset() async {
    if (await yesNoDialog(
      context: context,
      message: context.t('resetConfirmation'),
    )) {
      await _controller.reset();
      setState(() {});
    }
  }
}
