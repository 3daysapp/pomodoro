import 'package:flutter/material.dart';
import 'package:pomodoro/util/tempo.dart';
import 'package:flutter_picker/flutter_picker.dart';

///
///
///
class TimerWidget extends StatelessWidget {
  final int millis;
  final ValueSetter<int> callback;

  ///
  ///
  ///
  TimerWidget(
    this.millis, {
    this.callback,
    Key key,
  }) : super(key: key);

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
  void showPickerNumber(BuildContext context) {
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
        'Task Time',
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
