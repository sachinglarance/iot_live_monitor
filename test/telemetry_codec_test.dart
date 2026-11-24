import 'package:flutter_test/flutter_test.dart';
import 'package:iot_live_monitor/domain/telemetry.dart';
import 'package:iot_live_monitor/domain/telemetry_codec.dart';

void main() {
  test('encode → decode round-trip', () {
    final ts = DateTime.fromMillisecondsSinceEpoch(1700000000000);
    final raw = TelemetryCodec.encode('pump-01', ts, {
      Metric.temperature: 31.234,
      Metric.power: 300,
    });
    final readings = TelemetryCodec.decode(raw);

    expect(readings, hasLength(2));
    expect(readings.first.deviceId, 'pump-01');
    expect(readings.first.value, 31.23);
    expect(readings.first.timestamp, ts);
  });

  test('malformed or partial payloads never throw', () {
    expect(TelemetryCodec.decode('not json'), isEmpty);
    expect(TelemetryCodec.decode('[1,2]'), isEmpty);
    expect(TelemetryCodec.decode('{"metrics":{}}'), isEmpty);
    expect(
      TelemetryCodec.decode(
        '{"deviceId":"x","metrics":{"temperature":"hot","unknown":1,"humidity":50}}',
      ).map((r) => r.metric),
      [Metric.humidity],
    );
  });
}
