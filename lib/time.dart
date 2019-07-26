///
///
///
class Time {
  final int hours;
  final int minutes;
  final int seconds;

  ///
  ///
  ///
  Time({
    this.hours = 0,
    this.minutes = 0,
    this.seconds = 0,
  });

  ///
  ///
  ///
  @override
  String toString() {
    return _rawFormat(this);
  }

  ///
  ///
  ///
  static String format(int millis) {
    String s = "";

    if (millis < 0) {
      s = "-";
      millis = millis.abs() + 1000;
    }

    Time time = toTime(millis);

    return s + _rawFormat(time);
  }

  ///
  ///
  ///
  static _rawFormat(Time time) {
    String s = "${time.minutes.toString().padLeft(2, '0')}:"
        "${time.seconds.toString().padLeft(2, '0')}";

    if (time.hours > 0) {
      s = "${time.hours.toString()}:$s";
    }

    return s;
  }

  ///
  ///
  ///
  static Time toTime(int millis) {
    return Time(
      hours: millis ~/ 3600000 % 60,
      minutes: millis ~/ 60000 % 60,
      seconds: millis ~/ 1000 % 60,
    );
  }

  static int toMillis(Time time) {
    return time.hours * 3600000 + time.minutes * 60000 + time.seconds * 1000;
  }
}
