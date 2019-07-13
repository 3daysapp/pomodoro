import 'package:flutter/material.dart';

void main() => runApp(MyApp());

enum Status { stopped, task, short, long }

///
///
///
class Config {
  int taskTime;
  int shortPause;
  int longPause;
  int taskQtd;

  Config({
    this.taskTime = 25 * 60 * 1000,
    this.shortPause = 5 * 60 * 1000,
    this.longPause = 25 * 60 * 1000,
    this.taskQtd = 4,
  });
}

///
///
///
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pomodoro Timer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: MyHomePage(),
    );
  }
}

///
///
///
class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

///
///
///
class _MyHomePageState extends State<MyHomePage> {
  Config config;

  int _time = 0;
  int _circle = 0;
  int _taskCount = 0;
  Status _status = Status.stopped;
  Status _lastStatus;
  DateTime _startTime;
  Icon _fabIcon;
  Stream<int> _stream;

  ///
  ///
  ///
  @override
  void initState() {
    super.initState();
    _fabIcon = Icon(Icons.play_arrow);
    _stream = Stream<int>.periodic(Duration(milliseconds: 500), _decreaseTime);
  }

  ///
  ///
  ///
  @override
  Widget build(BuildContext context) {
    config = Config();

    return Scaffold(
      appBar: AppBar(
        title: Text('Pomodoro Timer'),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Chip(
              label: Text(
                _circle.toString(),
                style: TextStyle(
                    color: Theme.of(context).accentColor,
                    fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.white24,
            ),
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: _getChipByStatus(_status),
          ),
          StreamBuilder(
            stream: _stream,
            builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
              if (snapshot.hasData) {
                return Timer(data: snapshot.data, time: _time);
              }
              return Timer(data: 0, time: 0);
            },
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: _getTaskCount(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        key: Key('faButton'),
        onPressed: () {
          _fabPress();
        },
        tooltip: 'Pomodoro Control',
        child: _fabIcon,
      ),
    );
  }

  ///
  ///
  ///
  void _fabPress() {
    switch (_status) {
      case Status.stopped:
        if (_lastStatus == null ||
            _lastStatus == Status.long ||
            _lastStatus == Status.short) {
          _status = Status.task;
        } else {
          if (_taskCount < config.taskQtd) {
            _status = Status.short;
          } else {
            _status = Status.long;
          }
        }
        _lastStatus = Status.stopped;
        _fabIcon = Icon(Icons.check);
        _startTime = DateTime.now();
        break;
      case Status.task:
        _lastStatus = Status.task;
        _fabIcon = Icon(Icons.play_arrow);
        _status = Status.stopped;
        _taskCount++;
        break;
      case Status.short:
        _lastStatus = Status.short;
        _fabIcon = Icon(Icons.play_arrow);
        _status = Status.stopped;
        break;
      case Status.long:
        _lastStatus = Status.long;
        _fabIcon = Icon(Icons.play_arrow);
        _status = Status.stopped;
        _taskCount = 0;
        _circle++;
        break;
    }

    switch (_status) {
      case Status.task:
        _time = config.taskTime;
        break;
      case Status.short:
        _time = config.shortPause;
        break;
      case Status.long:
        _time = config.longPause;
        break;
      default:
        break;
    }

    setState(() {});
  }

  ///
  ///
  ///
  int _decreaseTime(int value) {
    if (_status == Status.stopped) {
      return null;
    }

    Duration duration = DateTime.now().difference(_startTime);

    return _time - duration.inMilliseconds;
  }

  ///
  ///
  ///
  Chip _getChipByStatus(Status status) {
    switch (status) {
      case Status.stopped:
        return Chip(
          key: Key('stoppedChip'),
          label: Text('Stopped'),
          backgroundColor: Colors.black26,
        );
      case Status.task:
        return Chip(
          key: Key('workingChip'),
          label: Text('Working'),
          backgroundColor: Colors.green,
        );
      case Status.short:
        return Chip(
          key: Key('shortPauseChip'),
          label: Text('Short Pause'),
          backgroundColor: Colors.amber,
        );
      case Status.long:
        return Chip(
          key: Key('longPauseChip'),
          label: Text('Long Pause'),
          backgroundColor: Colors.orange,
        );
    }
    return null;
  }

  ///
  ///
  ///
  Widget _getTaskCount() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(config.taskQtd, (i) => i)
          .map((i) => i < _taskCount
              ? Icon(
                  Icons.check_circle,
                  key: Key("task${i}Icon"),
                  color: Colors.deepOrange,
                )
              : Icon(
                  Icons.brightness_1,
                  key: Key("task${i}Icon"),
                  color: Colors.black26,
                ))
          .toList(),
    );
  }
}

///
///
///
class Timer extends StatelessWidget {
  final int data;
  final int time;

  const Timer({Key key, this.data, this.time}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String _text;
    double _value;

    if (data == 0 && time == 0) {
      _text = 'Waiting';
      _value = null;
    } else {
      _text = _formatTime(data);
      _value = (data - 1000) / time;
    }

    return Stack(
      children: <Widget>[
        Center(
          child: SizedBox(
            width: 150,
            height: 150,
            child: CircularProgressIndicator(
              strokeWidth: 8,
              backgroundColor: Colors.black26,
              value: _value,
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 55),
            child: Text(
              _text,
              key: Key('timeText'),
              style: Theme.of(context).textTheme.display1,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  ///
  ///
  ///
  String _formatTime(int millis) {
    String s = "";

    if (millis < 0) {
      s = "-";
      millis = millis.abs() + 1000;
    }

    int seconds = millis ~/ 1000 % 60;

    int minutes = millis ~/ 60000 % 60;

    s = "$s${minutes.toString().padLeft(2, '0')}:"
        "${seconds.toString().padLeft(2, '0')}";

    int hours = millis ~/ 3600000 % 60;

    if (hours > 0) {
      s = "${hours.toString()}:$s";
    }

    return s;
  }
}
