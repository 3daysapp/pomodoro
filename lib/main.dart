import 'package:flutter/material.dart';
import 'package:pomodoro/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

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
    return Scaffold(
      appBar: AppBar(
        title: Text('Pomodoro Timer'),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Chip(
              label: Text(
                (config.circle ?? 0).toString(),
                key: Key('circleText'),
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
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: FittedBox(
                          child: StreamBuilder(
                            stream: _stream,
                            builder: (BuildContext context,
                                AsyncSnapshot<int> snapshot) {
                              if (snapshot.hasData) {
                                return Timer(data: snapshot.data, time: _time);
                              }
                              return Timer(data: 0, time: 0);
                            },
                          ),
                        ),
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
          label: Text(
            'Stopped',
            textScaleFactor: 1.5,
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.black26,
        );
      case Status.task:
        return Chip(
          key: Key('workingChip'),
          label: Text(
            'Working',
            textScaleFactor: 1.5,
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        );
      case Status.short:
        return Chip(
          key: Key('shortPauseChip'),
          label: Text(
            'Short Pause',
            textScaleFactor: 1.5,
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.amber,
        );
      case Status.long:
        return Chip(
          key: Key('longPauseChip'),
          label: Text(
            'Long Pause',
            textScaleFactor: 1.5,
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.orange,
        );
    }
    return null;
  }

  ///
  ///
  ///
  Widget _getTaskCount() {
    return Wrap(
      alignment: WrapAlignment.center,
      children: List.generate(config.taskQtd, (i) => i)
          .map((i) => i < config.taskCount
              ? Icon(
                  Icons.check_circle,
                  key: Key("taskOk${i}Icon"),
                  color: Colors.deepOrange,
                )
              : Icon(
                  Icons.brightness_1,
                  key: Key("taskEmpty${i}Icon"),
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
      _text = _formatTime(data);
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
