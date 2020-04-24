import 'package:flutter_driver/flutter_driver.dart';
import 'package:screenshots/screenshots.dart';
import 'package:test/test.dart';

///
///
///
void main() {
  ///
  ///
  ///
  group('end-to-end test', () {
    FlutterDriver driver;
    final Config _config = Config();
    int _count = 0;

    ///
    ///
    ///
    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    ///
    ///
    ///
    tearDownAll(() async {
      if (driver != null) await driver.close();
    });

    ///
    ///
    ///
    test('main test', () async {
      Health health = await driver.checkHealth();

      print(health.status);

      SerializableFinder fab = find.byTooltip('Pomodoro Control');

      SerializableFinder workingChip = find.byValueKey('workingChip');

      SerializableFinder stoppedChip = find.byValueKey('stoppedChip');

      SerializableFinder shortPauseChip = find.byValueKey('shortPauseChip');

      SerializableFinder longPauseChip = find.byValueKey('longPauseChip');

      await driver.waitFor(fab);

      await screenshot(driver, _config, (_count++).toString());

      /// Starting the circle.

      int taskQtd = int.parse(await driver.requestData('task_qtd'));

      print('Task Qtd: $taskQtd');

      for (int t = 1; t <= taskQtd; t++) {
        print('t: $t');

        /// Waiting
        print('Waiting');
        await driver.waitFor(stoppedChip);
        await Future.delayed(Duration(seconds: 2));
        await driver.tap(fab);

        /// Working
        print('Working');
        await driver.waitFor(workingChip);
        if (t == 1) {
          await screenshot(driver, _config, (_count++).toString());
        }
        await Future.delayed(Duration(seconds: 5));
        await driver.tap(fab);

        /// Task Count
        print('Task Count');
        SerializableFinder taskOk = find.byValueKey('taskOk${t - 1}Icon');
        await driver.waitFor(taskOk);

        /// Waiting
        print('Waiting 2');
        await driver.waitFor(stoppedChip);
        await Future.delayed(Duration(seconds: 2));
        await driver.tap(fab);

        if (t < taskQtd) {
          /// Short Pause
          print('Short Pause');
          await driver.waitFor(shortPauseChip);
          if (t == 1) {
            await screenshot(driver, _config, (_count++).toString());
          }
          await Future.delayed(Duration(seconds: 5));
          await driver.tap(fab);
        } else {
          /// Long Pause
          print('Long Pause');
          await driver.waitFor(longPauseChip);
          await screenshot(driver, _config, (_count++).toString());
          await Future.delayed(Duration(seconds: 5));
          await driver.tap(fab);
        }
      }

      /// Circle Change
      print('Circle Change');
      SerializableFinder circleText = find.byValueKey('circleText');
      expect(await driver.getText(circleText), '1');

      /// Task Empty
      for (int i = 0; i < taskQtd; i++) {
        print('Task Empty $i');
        SerializableFinder taskEmpty = find.byValueKey('taskEmpty${i}Icon');
        await driver.waitFor(taskEmpty, timeout: Duration(seconds: 2));
      }

      await driver.waitFor(stoppedChip);

      // FIXME: Better way to find the Drawer.
      SerializableFinder homeDrawer = find.byTooltip('Open navigation menu');

      await driver.waitFor(homeDrawer);

      await driver.tap(homeDrawer);

      SerializableFinder settingsTile = find.byValueKey('settingsTile');

      await driver.waitFor(settingsTile);

      await driver.tap(settingsTile);

      await driver.waitFor(find.text('Task Time'));

      await screenshot(driver, _config, (_count++).toString());

      await driver.tap(find.pageBack());

      await driver.waitFor(homeDrawer);

      await driver.tap(homeDrawer);

      SerializableFinder resetTile = find.byValueKey('resetTile');

      await driver.waitFor(resetTile);

      await screenshot(driver, _config, (_count++).toString());

      await driver.tap(resetTile);

      print('The End');

      await Future.delayed(Duration(seconds: 5));
    }, timeout: Timeout(Duration(seconds: 120)));
  });
}
