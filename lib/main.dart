import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  int circle;
  int taskCount;
  Status status;
  Status lastStatus;
  DateTime startTime;

  Config({
    this.taskTime = 25 * 60 * 1000,
    this.shortPause = 5 * 60 * 1000,
    this.longPause = 25 * 60 * 1000,
    this.taskQtd = 4,
    this.circle = 0,
    this.taskCount = 0,
    this.status = Status.stopped,
    this.lastStatus,
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
  Config config = Config();

  int _time = 0;
  Icon _fabIcon;
  Stream<int> _stream;
  double _min;

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
    _min = math.min(
          MediaQuery.of(context).size.height,
          MediaQuery.of(context).size.width,
        ) *
        (MediaQuery.of(context).size.aspectRatio >= 1 ? 0.5 : 0.75);

    return Scaffold(
      appBar: AppBar(
        title: Text('Pomodoro Timer'),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Chip(
              label: Text(
                config.circle.toString(),
                style: TextStyle(
                    color: Theme.of(context).accentColor,
                    fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.white24,
            ),
          )
        ],
      ),
      body: FutureBuilder(
          future: loadFromSharedPreferences(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: _getChipByStatus(config.status),
                    ),
                    Expanded(
                      child: StreamBuilder(
                        stream: _stream,
                        builder:
                            (BuildContext context, AsyncSnapshot<int> snapshot) {
                          if (snapshot.hasData) {
                            return Timer(
                                data: snapshot.data, time: _time, min: _min);
                          }
                          return Timer(data: 0, time: 0, min: _min);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: _getTaskCount(),
                    ),
                  ],
                );
              }
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          }),
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
  Future<bool> loadFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    config.taskTime = prefs.getInt('task_time') ?? 1500000;
    config.shortPause = prefs.getInt('short_pause') ?? 300000;
    config.longPause = prefs.getInt('long_pause') ?? 1500000;
    config.taskQtd = prefs.getInt('task_qtd') ?? 4;
    config.circle = prefs.getInt('circle') ?? 0;
    config.taskCount = prefs.getInt('task_count') ?? 0;
    config.status = Status.values.elementAt(prefs.getInt('status') ?? 0);

    int lastStatus = prefs.getInt('last_status') ?? null;
    if (lastStatus == null) {
      config.lastStatus = null;
    } else {
      config.lastStatus = Status.values.elementAt(lastStatus);
    }

    int startTime = prefs.get('start_time') ?? null;
    if (startTime == null) {
      config.startTime = null;
    } else {
      config.startTime = DateTime.fromMillisecondsSinceEpoch(startTime);
    }

    checkTime();

    return true;
  }

  ///
  ///
  ///
  Future<void> saveToSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setInt('task_time', config.taskTime);
    await prefs.setInt('short_pause', config.shortPause);
    await prefs.setInt('long_pause', config.longPause);
    await prefs.setInt('task_qtd', config.taskQtd);
    await prefs.setInt('circle', config.circle);
    await prefs.setInt('task_count', config.taskCount);
    await prefs.setInt('status', config.status.index);

    int lastStatus = -1;
    if (config.lastStatus != null) {
      lastStatus = config.lastStatus.index;
    }
    await prefs.setInt('last_status', lastStatus);

    await prefs.setInt('start_time', config.startTime.millisecondsSinceEpoch);
  }

  ///
  ///
  ///
  void _fabPress() async {
    await loadFromSharedPreferences();

    switch (config.status) {
      case Status.stopped:
        if (config.lastStatus == null ||
            config.lastStatus == Status.long ||
            config.lastStatus == Status.short) {
          config.status = Status.task;
        } else {
          if (config.taskCount < config.taskQtd) {
            config.status = Status.short;
          } else {
            config.status = Status.long;
          }
        }
        config.lastStatus = Status.stopped;
        _fabIcon = Icon(Icons.check);
        config.startTime = DateTime.now();
        break;
      case Status.task:
        config.lastStatus = Status.task;
        _fabIcon = Icon(Icons.play_arrow);
        config.status = Status.stopped;
        config.taskCount++;
        break;
      case Status.short:
        config.lastStatus = Status.short;
        _fabIcon = Icon(Icons.play_arrow);
        config.status = Status.stopped;
        break;
      case Status.long:
        config.lastStatus = Status.long;
        _fabIcon = Icon(Icons.play_arrow);
        config.status = Status.stopped;
        config.taskCount = 0;
        config.circle++;
        break;
    }

    checkTime();

    await saveToSharedPreferences();

    setState(() {});
  }

  ///
  ///
  ///
  void checkTime() {
    switch (config.status) {
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
  }

  ///
  ///
  ///
  int _decreaseTime(int value) {
    if (config.status == Status.stopped) {
      return null;
    }
    Duration duration = DateTime.now().difference(config.startTime);
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
          .map((i) => i < config.taskCount
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
  final double min;

  const Timer({Key key, this.data, this.time, this.min}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String _text;
    double _value;

    if (time == 0) {
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
            width: min,
            height: min,
            child: CircularProgressIndicator(
              strokeWidth: min * 0.025,
              backgroundColor: Colors.black26,
              value: _value,
            ),
          ),
        ),
        Center(
          child: SizedBox(
            width: min * 0.85,
            height: min,
            child: FittedBox(
              child: Text(
                _text,
                key: Key('timeText'),
                style: TextStyle(
                  color: Color.lerp(Colors.red, Colors.black54, _value ?? 1),
                ),
                textAlign: TextAlign.center,
              ),
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
