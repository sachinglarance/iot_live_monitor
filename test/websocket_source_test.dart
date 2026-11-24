import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:iot_live_monitor/data/sources/websocket_source.dart';
import 'package:iot_live_monitor/domain/telemetry.dart';
import 'package:iot_live_monitor/domain/telemetry_codec.dart';

void main() {
  test('retry delay doubles and caps at 30s', () {
    expect(WebSocketSource.retryDelay(0), const Duration(seconds: 1));
    expect(WebSocketSource.retryDelay(3), const Duration(seconds: 8));
    expect(WebSocketSource.retryDelay(10), const Duration(seconds: 30));
  });

  test('receives telemetry from a real socket and reports a drop', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((req) async {
      final ws = await WebSocketTransformer.upgrade(req);
      ws.add(
        TelemetryCodec.encode('pump-01', DateTime.now(), {Metric.humidity: 55}),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await ws.close();
    });

    final source = WebSocketSource(
      uri: Uri.parse('ws://127.0.0.1:${server.port}'),
    );
    final statuses = <LinkStatus>[];
    source.status.listen(statuses.add);
    final first = source.readings.first;

    await source.connect();
    final readings = await first.timeout(const Duration(seconds: 5));
    await Future<void>.delayed(const Duration(milliseconds: 200));

    expect(readings.single.value, 55);
    expect(
      statuses,
      containsAllInOrder([
        LinkStatus.connecting,
        LinkStatus.connected,
        LinkStatus.reconnecting,
      ]),
    );

    await source.dispose();
    await server.close(force: true);
  });
}
