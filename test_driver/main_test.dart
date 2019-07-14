import 'package:flutter_driver/flutter_driver.dart';
import 'package:screenshots/screenshots.dart';
import 'package:test/test.dart';

void main() {
  group('end-to-end test', () {
    FlutterDriver driver;
    final config = Config().configInfo;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      if (driver != null) await driver.close();
    });

    test('main test', () async {
      Health health = await driver.checkHealth();

      print(health.status);

      SerializableFinder fab = find.byTooltip('Pomodoro Control');

      SerializableFinder workingChip = find.byValueKey('workingChip');

      SerializableFinder stoppedChip = find.byValueKey('stoppedChip');

      SerializableFinder shortPauseChip = find.byValueKey('shortPauseChip');

      SerializableFinder longPauseChip = find.byValueKey('longPauseChip');

      await driver.waitFor(fab);

      await screenshot(driver, config, '0');

      await driver.tap(fab);

      /// Starting the circle.

      int taskQtd = int.parse(await driver.requestData('task_qtd'));

      print('Task Qtd: $taskQtd');

      for (int t = 1; t <= taskQtd; t++) {
        /// Working
        await driver.waitFor(workingChip);
        if (t == 1) {
          await screenshot(driver, config, '1');
        }
        await Future.delayed(Duration(seconds: 5));
        await driver.tap(fab);

        /// Waiting
        await driver.waitFor(stoppedChip);
        await Future.delayed(Duration(seconds: 5));
        await driver.tap(fab);

        if (t < taskQtd) {
          /// Short Pause
          await driver.waitFor(shortPauseChip);
          if (t == 1) {
            await screenshot(driver, config, '2');
          }

          // TODO: Verificar se o tarefa foi marcada corretamente.

          await Future.delayed(Duration(seconds: 5));
          await driver.tap(fab);
        } else {
          /// Long Pause
          await driver.waitFor(longPauseChip);
          await screenshot(driver, config, '3');
          await Future.delayed(Duration(seconds: 5));
          await driver.tap(fab);
        }

        /// Waiting
        await driver.waitFor(stoppedChip);
        await Future.delayed(Duration(seconds: 2));
        await driver.tap(fab);
      }

      // TODO: Verificar se o ciclo mudou.

      await driver.waitFor(workingChip);

      print('The End');

      await Future.delayed(Duration(seconds: 5));
    }, timeout: Timeout(Duration(seconds: 120)));
  });
}
