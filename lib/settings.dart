import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:pomodoro/time.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
//  TextEditingController _taskQtdController = TextEditingController(text: '0');

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
          TimerWidget('task_time'),
          FieldLabel('Short Pause Time'),
          TimerWidget('short_pause'),
          FieldLabel('Long Pause Time'),
          TimerWidget('long_pause'),
//          FieldLabel('Task Quantity'),
//          Padding(
//            padding: const EdgeInsets.all(8.0),
//            child: TextField(
//              decoration: InputDecoration(
//                border: OutlineInputBorder(),
//                counterText: '',
//              ),
//              controller: _taskQtdController,
//              keyboardType: TextInputType.number,
//              textAlign: TextAlign.right,
//            ),
//          ),
        ],
      ),
    );
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

///
///
///
class TimerWidget extends StatelessWidget {
  final String prefAttr;
  int millis;

  ///
  ///
  ///
  TimerWidget(this.prefAttr, {Key key}) : super(key: key);

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
        child: StreamBuilder<SharedPreferences>(
          stream: SharedPreferences.getInstance().asStream(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              millis = snapshot.data.getInt(prefAttr);
              return FlatButton(
                onPressed: () => showPickerNumber(context),
                child: Text(
                  Time.format(millis),
                ),
                padding: EdgeInsets.zero,
              );
            }

            return Center(
              child: Text('Loading...'),
            );
          },
        ),
      ),
    );
  }

  ///
  ///
  ///
  showPickerNumber(BuildContext context) {
    Time time = Time.toTime(millis);

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
          Time time = Time(
            hours: parts[0],
            minutes: parts[1],
            seconds: parts[2],
          );

          // TODO: Parei aqui.
          print(time);
        }).showDialog(context);
  }
}
