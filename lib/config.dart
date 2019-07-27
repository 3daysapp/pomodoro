///
///
///
enum Status { stopped, task, short, long }

///
///
///
class Config {
  static final Config _singleton = Config._internal();

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

  Config._internal();
}

// TODO: Implement Progress Notification.
// TODO: Implement Vibration.
// TODO: Reset App.
// TODO: App version in drawer.
// FIXME: Verify FAB icon on app load.
