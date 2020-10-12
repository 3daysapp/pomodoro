import 'package:flutter/material.dart';
import 'package:pomodoro/util/field_label.dart';
import 'package:pomodoro/util/timer_widget.dart';
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
  final Config _config = Config();
  final FocusNode _taskQtdFocusNode = FocusNode();
  TextEditingController _taskQtdController;

  ///
  ///
  ///
  @override
  void initState() {
    super.initState();
    _taskQtdController = TextEditingController(
      text: _config.taskQtd.toString(),
    );

    _taskQtdFocusNode.addListener(
      () {
        if (_taskQtdFocusNode.hasFocus) {
          _taskQtdController.selection = TextSelection(
            baseOffset: 0,
            extentOffset: _taskQtdController.text.length,
          );
        }
      },
    );
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
            _config.taskTime,
            callback: (time) async {
              await saveConfig();
              setState(() => _config.taskTime = time);
            },
          ),
          FieldLabel('Short Pause Time'),
          TimerWidget(
            _config.shortPause,
            callback: (time) async {
              setState(() => _config.shortPause = time);
              await saveConfig();
            },
          ),
          FieldLabel('Long Pause Time'),
          TimerWidget(
            _config.longPause,
            callback: (time) async {
              setState(() => _config.longPause = time);
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
                  setState(() => _config.taskQtd = value);
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
            _config.advanceNotification,
            callback: (time) async {
              setState(() => _config.advanceNotification = time);
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
                    value: _config.wakeLock,
                    onChanged: (value) async {
                      setState(() => _config.wakeLock = value);
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

    await prefs.setInt('task_time', _config.taskTime);
    await prefs.setInt('short_pause', _config.shortPause);
    await prefs.setInt('long_pause', _config.longPause);
    await prefs.setInt('task_qtd', _config.taskQtd);
    await prefs.setInt('advance_notification', _config.advanceNotification);
    await prefs.setBool('wake_lock', _config.wakeLock);

    _config.change = true;

    await Wakelock.toggle(enable: _config.wakeLock);
  }
}
