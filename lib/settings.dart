import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:pomodoro/config.dart';
import 'package:pomodoro/tempo.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  }
}

///
///
///
class TimerWidget extends StatelessWidget {
  final int millis;
  final ValueSetter<int> callback;

  ///
  ///
  ///
  TimerWidget(this.millis, {this.callback, Key key}) : super(key: key);

  ///
  ///
  ///
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
          border: Border.all(color: Colors.black45),
        ),
        child: FlatButton(
          onPressed: () => showPickerNumber(context),
          child: Text(
            Tempo.format(millis),
          ),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }

  ///
  ///
  ///
  showPickerNumber(BuildContext context) {
    Tempo time = Tempo.toTime(millis);

    Picker(
      adapter: NumberPickerAdapter(data: [
        NumberPickerColumn(
          initValue: time.hours,
          begin: 0,
          end: 99,
          onFormatValue: (value) => value.toString().padLeft(2, '0'),
        ),
        NumberPickerColumn(
          initValue: time.minutes,
          begin: 0,
          end: 59,
          onFormatValue: (value) => value.toString().padLeft(2, '0'),
        ),
        NumberPickerColumn(
          initValue: time.seconds,
          begin: 0,
          end: 59,
          onFormatValue: (value) => value.toString().padLeft(2, '0'),
        ),
      ]),
      delimiter: [
        PickerDelimiter(
          column: 1,
          child: Container(
            width: 30.0,
            alignment: Alignment.center,
            child: Text(
              ':',
              textScaleFactor: 2,
              style: TextStyle(
                color: Colors.black45,
              ),
            ),
          ),
        ),
        PickerDelimiter(
          column: 3,
          child: Container(
            width: 30.0,
            alignment: Alignment.center,
            child: Text(
              ':',
              textScaleFactor: 2,
              style: TextStyle(
                color: Colors.black45,
              ),
            ),
          ),
        ),
      ],
      hideHeader: true,
      title: Text(
        "Task Time",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.black45,
        ),
      ),
      selectedTextStyle: TextStyle(color: Theme.of(context).accentColor),
      onConfirm: (Picker picker, List value) {
        List<int> parts = picker.getSelectedValues();
        Tempo time = Tempo(
          hours: parts[0],
          minutes: parts[1],
          seconds: parts[2],
        );

        if (callback != null) {
          callback(time.toInt());
        }
      },
    ).showDialog(context);
  }
}

///
///
///
class FieldLabel extends StatelessWidget {
  final String label;

  ///
  ///
  ///
  const FieldLabel(this.label, {Key key}) : super(key: key);

  ///
  ///
  ///
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 8.0,
        left: 16.0,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.black45,
        ),
      ),
    );
  }
}
