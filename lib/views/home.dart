import 'package:flutter/material.dart';
import 'package:pomodoro/utils/l10n.dart';
import 'package:pomodoro/views/settings.dart';

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
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t('pomodoro')),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            ListTile(
              title: Text(context.t('settings')),
              onTap: () async {
                Navigator.of(context).pop();
                await Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) {
                      return const Settings();
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text('Home'),
      ),
    );
  }
}
