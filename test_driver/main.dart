import 'package:flutter/widgets.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:pomodoro/config.dart';
import 'package:pomodoro/main.dart';

void main() {
  Future<String> dataHandler(String msg) async {
    Config config = Config();
    switch (msg) {
      case 'task_qtd':
        return config.taskQtd.toString();
    }
    return null;
  }

  enableFlutterDriverExtension(handler: dataHandler);

  runApp(PomodoroTimer(disableNotifications: true));
}
