import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iot_live_monitor/data/sources/telemetry_source.dart';
import 'package:iot_live_monitor/domain/telemetry.dart';
import 'package:iot_live_monitor/state/connection_providers.dart';
import 'package:iot_live_monitor/state/dashboard_controller.dart';

class FakeSource implements TelemetrySource {
  final readingsCtrl = StreamController<List<SensorReading>>.broadcast();
  final statusCtrl = StreamController<LinkStatus>.broadcast();
  final commands = <String>[];

  @override
  Stream<List<SensorReading>> get readings => readingsCtrl.stream;
  @override
  Stream<LinkStatus> get status => statusCtrl.stream;
  @override
  Future<void> connect() async => statusCtrl.add(LinkStatus.connected);
  @override
  Future<void> sendCommand(String deviceId, String command) async =>
      commands.add('$deviceId:$command');
  @override
  Future<void> dispose() async {}
}

SensorReading temp(double v, [int i = 0]) => SensorReading(
  deviceId: 'd1',
  metric: Metric.temperature,
  value: v,
  timestamp: DateTime(2026).add(Duration(seconds: i)),
);

void main() {
  late FakeSource source;
  late ProviderContainer container;
  DashboardController controller() =>
      container.read(dashboardProvider.notifier);

  setUp(() {
    source = FakeSource();
    container = ProviderContainer(
      overrides: [telemetrySourceProvider.overrideWithValue(source)],
    );
    container.listen(dashboardProvider, (_, _) {});
  });
  tearDown(() => container.dispose());

  test('reflects link status from the source', () async {
    await Future<void>.delayed(Duration.zero);
    expect(container.read(dashboardProvider).link, LinkStatus.connected);
  });

  test('keeps only the last historyLength readings per metric', () {
    for (var i = 0; i < DashboardController.historyLength + 15; i++) {
      controller().ingest([temp(20 + i % 5, i)]);
    }
    final series = container
        .read(dashboardProvider)
        .devices['d1']!
        .history[Metric.temperature]!;
    expect(series, hasLength(DashboardController.historyLength));
    expect(
      series.last.timestamp.second,
      (DashboardController.historyLength + 14) % 60,
    );
  });

  test(
    'alerts fire once per threshold crossing, not on every high reading',
    () {
      controller()
        ..ingest([temp(30)])
        ..ingest([temp(40)]) // crosses → alert
        ..ingest([temp(41)]) // still high → no new alert
        ..ingest([temp(30)]) // back to normal
        ..ingest([temp(39)]); // crosses again → alert

      expect(container.read(dashboardProvider).alerts, hasLength(2));
      expect(container.read(dashboardProvider).devices['d1']!.hasAlert, isTrue);
    },
  );

  test(
    'stream readings flow into state and commands go to the source',
    () async {
      source.readingsCtrl.add([temp(25)]);
      await Future<void>.delayed(Duration.zero);
      expect(container.read(dashboardProvider).devices, contains('d1'));

      await controller().sendCommand('d1', 'reboot');
      expect(source.commands, ['d1:reboot']);
    },
  );
}
