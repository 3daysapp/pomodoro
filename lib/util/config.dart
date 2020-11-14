///
///
///
enum Status {
  stopped,
  task,
  short,
  long,
}

///
///
///
class Config {
  static final Config _singleton = Config._internal();

  ///
  ///
  ///
  factory Config() {
    return _singleton;
  }

  int taskTime;
  int shortPause;
  int longPause;
  int taskQtd;
  int circle;
  int taskCount;
  Status status;
  Status lastStatus;
  DateTime startTime;
  int advanceNotification;
  bool wakeLock = false;
  bool change = false;
  bool debug = false;

  Config._internal();
}
