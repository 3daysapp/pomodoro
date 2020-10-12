import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:package_info/package_info.dart';
import 'package:pomodoro/util/clock.dart';
import 'package:pomodoro/util/Config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock/wakelock.dart';

///
///
///
class Home extends StatefulWidget {
  final bool disableNotifications;

  ///
  ///
  ///
  const Home({Key key, this.disableNotifications}) : super(key: key);

  ///
  ///
  ///
  @override
  _HomeState createState() => _HomeState();
}

///
///
///
class _HomeState extends State<Home> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final Config _config = Config();

  int _time = 0;
  Icon _fabIcon;
  Stream<int> _stream;
  String _version = '0.0.0';

  ///
  ///
  ///
  @override
  void initState() {
    super.initState();
    if (!widget.disableNotifications) {
      AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('pomodoro_icon');

      IOSInitializationSettings initializationSettingsIOS =
          IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification,
      );

      InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onSelectNotification: onSelectNotification,
      );
    }

    _fabIcon = Icon(Icons.play_arrow);
    _stream = Stream<int>.periodic(Duration(milliseconds: 500), _decreaseTime);

    PackageInfo.fromPlatform().then((info) => _version = info.version);
  }

  ///
  ///
  ///
  Future<void> onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }

    _fabPress();
  }

  ///
  ///
  ///
  Future<void> onDidReceiveLocalNotification(
    int id,
    String title,
    String body,
    String payload,
  ) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Ok'),
            onPressed: _fabPress,
          )
        ],
      ),
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
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Chip(
              label: Text(
                (_config.circle ?? 0).toString(),
                key: Key('circleText'),
                style: TextStyle(
                  color: Theme.of(context).accentColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.white24,
            ),
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              color: Colors.red.shade300,
              child: Padding(
                padding: const EdgeInsets.only(top: 46.0, bottom: 12.0,),
                child: Image.asset(
                  'assets/images/pomodoro_512.png',
                  height: 100.0,
                ),
              ),
            ),
            ListTile(
              key: Key('resetTile'),
              leading: Icon(Icons.restore),
              title: Text('Reset'),
              onTap: _reset,
            ),
            Divider(),
            ListTile(
              key: Key('settingsTile'),
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () => Navigator.of(context).popAndPushNamed('/settings'),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.verified_user),
              title: Text('Version'),
              subtitle: Text(_version),
            ),
          ],
        ),
      ),
      body: StreamBuilder(
          stream: _loadFromSharedPreferences().asStream(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (_config.change) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Center(
                      child: Text(
                    'Config has changed.',
                    style: Theme.of(context).textTheme.headline6,
                  )),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(
                      'Do you want to reset the timer?',
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                  ),
                  RaisedButton(
                    child: Text(
                      'Yes!',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      await _reset();
                      _stream = Stream<int>.periodic(
                          Duration(milliseconds: 500), _decreaseTime);
                      setState(() {
                        _config.change = false;
                      });
                    },
                    color: Theme.of(context).accentColor,
                  ),
                  RaisedButton(
                    child: Text('No, thanks.'),
                    onPressed: () {
                      _stream = Stream<int>.periodic(
                        Duration(milliseconds: 500),
                        _decreaseTime,
                      );
                      setState(() {
                        _config.change = false;
                      });
                    },
                  ),
                ],
              );
            }

            if (snapshot.hasData) {
              if (snapshot.data) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: _getChipByStatus(_config.status),
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: SizedBox(
                          height: double.infinity,
                          width: double.infinity,
                          child: FittedBox(
                            child: StreamBuilder(
                              stream: _stream,
                              builder: (BuildContext context,
                                  AsyncSnapshot<int> snapshot) {
                                if (snapshot.hasData) {
                                  return Clock(
                                    data: snapshot.data,
                                    time: _time,
                                  );
                                }
                                return Clock(data: 0, time: 0);
                              },
                            ),
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
        onPressed: _fabPress,
        tooltip: 'Pomodoro Control',
        child: _fabIcon,
      ),
    );
  }

  ///
  ///
  ///
  Future<void> _reset({bool pop = true}) async {
    _config.lastStatus = null;
    _config.status = Status.stopped;
    _config.taskCount = 0;
    _config.circle = 0;
    _config.startTime = null;

    _checkTime();

    await _cancelAllNotifications();

    await _saveToSharedPreferences();

    setState(() {});

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  ///
  ///
  ///
  Future<bool> _loadFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    _config.taskTime = prefs.getInt('task_time') ?? 1500000;
    _config.shortPause = prefs.getInt('short_pause') ?? 300000;
    _config.longPause = prefs.getInt('long_pause') ?? 1500000;
    _config.taskQtd = prefs.getInt('task_qtd') ?? 4;
    _config.circle = prefs.getInt('circle') ?? 0;
    _config.taskCount = prefs.getInt('task_count') ?? 0;
    _config.advanceNotification = prefs.getInt('advance_notification') ?? 10000;
    _config.wakeLock = prefs.getBool('wake_lock') ?? false;
    _config.status = Status.values.elementAt(prefs.getInt('status') ?? 0);

    int lastStatus = prefs.getInt('last_status');
    if (lastStatus == null || lastStatus < 0) {
      _config.lastStatus = null;
    } else {
      _config.lastStatus = Status.values.elementAt(lastStatus);
    }

    int startTime = prefs.get('start_time');
    if (startTime == null || startTime < 0) {
      _config.startTime = null;
    } else {
      _config.startTime = DateTime.fromMillisecondsSinceEpoch(startTime);
    }

    await Wakelock.toggle(enable: _config.wakeLock);

    _checkTime();

    return true;
  }

  ///
  ///
  ///
  Future<void> _saveToSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setInt('task_time', _config.taskTime);
    await prefs.setInt('short_pause', _config.shortPause);
    await prefs.setInt('long_pause', _config.longPause);
    await prefs.setInt('task_qtd', _config.taskQtd);
    await prefs.setInt('circle', _config.circle);
    await prefs.setInt('task_count', _config.taskCount);
    await prefs.setInt('advance_notification', _config.advanceNotification);
    await prefs.setBool('wake_lock', _config.wakeLock);
    await prefs.setInt('status', _config.status.index);

    int lastStatus = -1;
    if (_config.lastStatus != null) {
      lastStatus = _config.lastStatus.index;
    }
    await prefs.setInt('last_status', lastStatus);

    int startTime = -1;
    if (_config.startTime != null) {
      startTime = _config.startTime.millisecondsSinceEpoch;
    }
    await prefs.setInt('start_time', startTime);
  }

  ///
  ///
  ///
  void _fabPress() async {
    await _loadFromSharedPreferences();

    _config.change = false;

    switch (_config.status) {
      case Status.stopped:
        if (_config.lastStatus == null ||
            _config.lastStatus == Status.long ||
            _config.lastStatus == Status.short) {
          _config.status = Status.task;
          await _scheduleNotification(_config.taskTime);
        } else {
          if (_config.taskCount < _config.taskQtd) {
            _config.status = Status.short;
            await _scheduleNotification(_config.shortPause);
          } else {
            _config.status = Status.long;
            await _scheduleNotification(_config.longPause);
          }
        }
        _config.lastStatus = Status.stopped;
        _fabIcon = Icon(Icons.check);
        _config.startTime = DateTime.now();
        break;
      case Status.task:
        _config.lastStatus = Status.task;
        _fabIcon = Icon(Icons.play_arrow);
        _config.status = Status.stopped;
        _config.taskCount++;
        await _cancelAllNotifications();
        break;
      case Status.short:
        _config.lastStatus = Status.short;
        _fabIcon = Icon(Icons.play_arrow);
        _config.status = Status.stopped;
        await _cancelAllNotifications();
        break;
      case Status.long:
        _config.lastStatus = Status.long;
        _fabIcon = Icon(Icons.play_arrow);
        _config.status = Status.stopped;
        _config.taskCount = 0;
        _config.circle++;
        await _cancelAllNotifications();
        break;
    }

    _checkTime();

    await _saveToSharedPreferences();

    setState(() {});
  }

  ///
  ///
  ///
  void _checkTime() {
    switch (_config.status) {
      case Status.task:
        _time = _config.taskTime;
        break;
      case Status.short:
        _time = _config.shortPause;
        break;
      case Status.long:
        _time = _config.longPause;
        break;
      default:
        break;
    }
  }

  ///
  ///
  ///
  Future<void> _scheduleNotification(int millis) async {
    if (widget.disableNotifications) {
      return;
    }

    var scheduledNotificationDateTime = DateTime.now().add(
      Duration(
        milliseconds: millis - _config.advanceNotification,
      ),
    );

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'pomodoro timer channel id',
        'pomodoro timer channel name',
        'pomodoro timer channel description',
//        icon: 'secondary_icon',
//        sound: 'slow_spring_board',
//        largeIcon: 'sample_large_icon',
//        largeIconBitmapSource: BitmapSource.Drawable,
//        vibrationPattern: vibrationPattern,
        importance: Importance.max,
        priority: Priority.high,
        enableLights: true,
//        color: const Color.fromARGB(255, 255, 0, 0),
        ledColor: const Color.fromARGB(255, 255, 0, 0),
        ledOnMs: 1000,
        ledOffMs: 500);

    var iOSPlatformChannelSpecifics =
        IOSNotificationDetails(sound: 'slow_spring_board.aiff');

    await flutterLocalNotificationsPlugin.schedule(
      0,
      'Pomodoro Timer',
      "Time's Up!",
      scheduledNotificationDateTime,
      NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      ),
    );
  }

  ///
  ///
  ///
  Future<void> _cancelAllNotifications() async {
    if (widget.disableNotifications) {
      return;
    }

    await flutterLocalNotificationsPlugin.cancelAll();
  }

  ///
  ///
  ///
  int _decreaseTime(int value) {
    if (_config.status == Status.stopped) {
      return null;
    }
    Duration duration = DateTime.now().difference(_config.startTime);
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
      children: List.generate(_config.taskQtd, (i) => i)
          .map((i) => i < _config.taskCount
              ? Icon(
                  Icons.check_circle,
                  key: Key('taskOk${i}Icon'),
                  color: Theme.of(context).accentColor,
                )
              : Icon(
                  Icons.brightness_1,
                  key: Key('taskEmpty${i}Icon'),
                  color: Colors.black26,
                ))
          .toList(),
    );
  }
}
