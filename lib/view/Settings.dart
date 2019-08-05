import 'package:flutter/material.dart';
import 'package:pomodoro/util/FieldLabel.dart';
import 'package:pomodoro/util/TimerWidget.dart';
import 'package:pomodoro/util/Config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock/wakelock.dart';

///
///
///
class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

///
///
///
class _SettingsState extends State<Settings> {
  Config config = Config();
  FocusNode _taskQtdFocusNode = FocusNode();
  TextEditingController _taskQtdController;

  ///
  ///
  ///
  @override
  void initState() {
    super.initState();
    _taskQtdController = TextEditingController(text: config.taskQtd.toString());

    _taskQtdFocusNode.addListener(() {
      if (_taskQtdFocusNode.hasFocus) {
        _taskQtdController.selection = TextSelection(
            baseOffset: 0, extentOffset: _taskQtdController.text.length);
      }
    });
  }

  ///
  ///
  ///
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pomodoro Timer'),
      ),
      body: ListView(
        padding: EdgeInsets.all(8.0),
        children: <Widget>[
          FieldLabel('Task Time'),
          TimerWidget(
            config.taskTime,
            callback: (time) async {
              setState(() => config.taskTime = time);
              await saveConfig();
            },
          ),
          FieldLabel('Short Pause Time'),
          TimerWidget(
            config.shortPause,
            callback: (time) async {
              setState(() => config.shortPause = time);
              await saveConfig();
            },
          ),
          FieldLabel('Long Pause Time'),
          TimerWidget(
            config.longPause,
            callback: (time) async {
              setState(() => config.longPause = time);
              await saveConfig();
            },
          ),
          FieldLabel('Task Quantity'),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                counterText: '',
              ),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              controller: _taskQtdController,
              focusNode: _taskQtdFocusNode,
              onChanged: (text) async {
                try {
                  int value = int.parse(text);
                  if (value < 2) {
                    throw Exception('Task quantity is invalid.');
                  }
                  setState(() => config.taskQtd = value);
                  await saveConfig();
                } catch (error) {
                  // TODO: Show this message.
                  print('Erro: $error');
                }
              },
            ),
          ),
          FieldLabel('Advance Notification'),
          TimerWidget(
            config.advanceNotification,
            callback: (time) async {
              setState(() => config.advanceNotification = time);
              await saveConfig();
            },
          ),
          FieldLabel('More Options'),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.0),
                border: Border.all(color: Colors.black45),
              ),
              child: Column(
                children: <Widget>[
                  SwitchListTile.adaptive(
                    title: Text(
                      'Not sleep',
                      style: TextStyle(color: Colors.black45),
                    ),
                    value: config.wakeLock,
                    onChanged: (value) async {
                      setState(() => config.wakeLock = value);
                      await saveConfig();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  ///
  ///
  ///
  Future<void> saveConfig() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setInt('task_time', config.taskTime);
    await prefs.setInt('short_pause', config.shortPause);
    await prefs.setInt('long_pause', config.longPause);
    await prefs.setInt('task_qtd', config.taskQtd);
    await prefs.setInt('advance_notification', config.advanceNotification);
    await prefs.setBool('wake_lock', config.wakeLock);

    config.change = true;

    Wakelock.toggle(on: config.wakeLock);
  }
}
