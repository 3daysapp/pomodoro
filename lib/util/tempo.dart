///
///
///
class Tempo {
  final int hours;
  final int minutes;
  final int seconds;

  ///
  ///
  ///
  Tempo({
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
  int toInt() {
    return Tempo.toMillis(this);
  }

  ///
  ///
  ///
  static String format(int millis) {
    String s = '';

    if (millis < 0) {
      s = '-';
      millis = millis.abs() + 1000;
    }

    Tempo tempo = toTime(millis);

    return s + _rawFormat(tempo);
  }

  ///
  ///
  ///
  static String _rawFormat(Tempo time) {
    String s = '${time.minutes.toString().padLeft(2, '0')}:'
        '${time.seconds.toString().padLeft(2, '0')}';

    if (time.hours > 0) {
      s = '${time.hours.toString()}:$s';
    }

    return s;
  }

  ///
  ///
  ///
  static Tempo toTime(int millis) {
    return Tempo(
      hours: millis ~/ 3600000 % 60,
      minutes: millis ~/ 60000 % 60,
      seconds: millis ~/ 1000 % 60,
    );
  }

  ///
  ///
  ///
  static int toMillis(Tempo time) {
    return time.hours * 3600000 + time.minutes * 60000 + time.seconds * 1000;
  }
}
