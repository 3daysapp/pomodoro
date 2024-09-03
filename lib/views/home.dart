import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pomodoro/utils/config.dart';
import 'package:pomodoro/utils/l10n.dart';
import 'package:pomodoro/utils/pomodoro.dart';
import 'package:pomodoro/views/settings.dart';
import 'package:pomodoro/widgets/symbols.dart';

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
  void updateScreen(final Timer timer) {
    print(DateTime.now());
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
                  )
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
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t('pomodoro')),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            /// Settings
            ListTile(
              title: Text(context.t('settings')),
              onTap: () async {
                Navigator.of(context).pop();
                await Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const Settings(),
                  ),
                );
                setState(() {});
              },
            ),

            /// Reset
            ListTile(
              title: Text(context.t('reset')),
              onTap: () async {
                Navigator.of(context).pop();
                if (await yesNoDialog(
                  context: context,
                  message: context.t('resetConfirmation'),
                )) {
                  await Pomodoro().reset();
                  setState(() {});
                }
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: <Widget>[
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              children: <Widget>[
                ...List<List<Widget>>.generate(
                  Config().taskQuantity - 1,
                  (final _) => <Widget>[
                    const TaskSymbol(),
                    const ShortBreakSymbol(),
                  ],
                ).expand((final List<Widget> e) => e),
                const TaskSymbol(),
                const LongBreakSymbol(),
              ],
            ),
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: <Widget>[
                  FittedBox(
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      value: 0.75,
                      color: Colors.deepOrange,
                      backgroundColor: Colors.grey.withAlpha(128),
                    ),
                  ),
                  const FittedBox(
                    child: Align(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Text('25:00'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            FloatingActionButton(
              onPressed: () {},
              backgroundColor: Colors.deepOrange.withAlpha(200),
              child: const Icon(FontAwesomeIcons.pause),
            )
          ],
        ),
      ),
    );
  }
}
