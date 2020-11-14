import 'package:flutter/material.dart';
import 'package:pomodoro/util/tempo.dart';

///
///
///
class Clock extends StatelessWidget {
  final int data;
  final int time;

  ///
  ///
  ///
  const Clock({
    Key key,
    this.data,
    this.time,
  }) : super(key: key);

  ///
  ///
  ///
  @override
  Widget build(BuildContext context) {
    String _text;
    double _value;

    if (time == 0) {
      _text = 'Waiting';
      _value = 0;
    } else {
      _text = Tempo.format(data);
      _value = (data - 1000) / time;
    }

    return Stack(
      alignment: AlignmentDirectional.center,
      children: <Widget>[
        SizedBox(
          width: 100,
          height: 100,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            backgroundColor: Colors.black26,
            value: _value,
          ),
        ),
        SizedBox(
          width: 100,
          height: 100,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: FittedBox(
              child: Text(
                _text,
                style: TextStyle(
                  color: Color.lerp(Colors.red, Colors.black54, _value ?? 1),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
