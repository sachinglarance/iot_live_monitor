// Publishes fake telemetry for 4 devices to a public MQTT broker so the app's
// "MQTT broker" mode shows live data.
//
//   dart run tool/mqtt_device_simulator.dart [broker-host]
import 'dart:async';
import 'dart:io';

import 'package:iot_live_monitor/data/simulator/telemetry_generator.dart';
import 'package:iot_live_monitor/domain/telemetry_codec.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

Future<void> main(List<String> args) async {
  final host = args.isNotEmpty ? args.first : 'broker.hivemq.com';
  final client =
      MqttServerClient(
          host,
          'iotlive-sim-${DateTime.now().millisecondsSinceEpoch}',
        )
        ..logging(on: false)
        ..keepAlivePeriod = 20
        ..autoReconnect = true;
  await client.connect();
  stdout.writeln(
    'Connected to $host. Publishing to ${TelemetryCodec.telemetryWildcard}',
  );

  // Print commands sent from the app.
  client.subscribe('${TelemetryCodec.topicPrefix}/+/cmd', MqttQos.atLeastOnce);
  client.updates!.listen((msgs) {
    for (final m in msgs) {
      final p = m.payload as MqttPublishMessage;
      stdout.writeln(
        '⇠ ${m.topic}: ${MqttPublishPayload.bytesToStringAsString(p.payload.message)}',
      );
    }
  });

  final gen = TelemetryGenerator();
  Timer.periodic(const Duration(seconds: 1), (_) {
    for (final id in gen.deviceIds) {
      final payload = TelemetryCodec.encode(id, DateTime.now(), gen.next(id));
      final builder = MqttClientPayloadBuilder()..addString(payload);
      client.publishMessage(
        TelemetryCodec.telemetryTopic(id),
        MqttQos.atMostOnce,
        builder.payload!,
      );
    }
  });
}
