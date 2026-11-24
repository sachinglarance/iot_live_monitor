import 'dart:async';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import '../../domain/telemetry.dart';
import '../../domain/telemetry_codec.dart';
import 'telemetry_source.dart';

/// Subscribes to `iotlive/demo/+/telemetry` on an MQTT broker.
/// Uses the client's built-in auto-reconnect and re-subscribes on reconnect.
class MqttSource implements TelemetrySource {
  MqttSource({
    this.host = 'broker.hivemq.com',
    this.port = 1883,
    MqttServerClient? client,
  }) : _client =
           client ??
           MqttServerClient.withPort(
             host,
             'iotlive-${DateTime.now().millisecondsSinceEpoch}',
             port,
           );

  final String host;
  final int port;
  final MqttServerClient _client;
  final _readings = StreamController<List<SensorReading>>.broadcast();
  final _status = StreamController<LinkStatus>.broadcast();
  StreamSubscription<List<MqttReceivedMessage<MqttMessage>>>? _updates;

  @override
  Stream<List<SensorReading>> get readings => _readings.stream;

  @override
  Stream<LinkStatus> get status => _status.stream;

  @override
  Future<void> connect() async {
    _client
      ..logging(on: false)
      ..keepAlivePeriod = 20
      ..autoReconnect = true
      ..resubscribeOnAutoReconnect = true
      ..onConnected = (() => _status.add(LinkStatus.connected))
      ..onDisconnected = (() => _status.add(LinkStatus.disconnected))
      ..onAutoReconnect = (() => _status.add(LinkStatus.reconnecting))
      ..onAutoReconnected = (() => _status.add(LinkStatus.connected))
      ..connectionMessage = MqttConnectMessage().startClean();

    _status.add(LinkStatus.connecting);
    try {
      await _client.connect();
    } on Exception {
      _status.add(LinkStatus.error);
      _client.disconnect();
      return;
    }

    _client.subscribe(TelemetryCodec.telemetryWildcard, MqttQos.atMostOnce);
    _updates = _client.updates!.listen((messages) {
      for (final m in messages) {
        final payload = m.payload;
        if (payload is! MqttPublishMessage) continue;
        final text = MqttPublishPayload.bytesToStringAsString(
          payload.payload.message,
        );
        final decoded = TelemetryCodec.decode(text);
        if (decoded.isNotEmpty) _readings.add(decoded);
      }
    });
  }

  /// Commands use QoS 1 so they are delivered at least once.
  @override
  Future<void> sendCommand(String deviceId, String command) async {
    if (_client.connectionStatus?.state != MqttConnectionState.connected) {
      return;
    }
    final builder = MqttClientPayloadBuilder()..addString(command);
    _client.publishMessage(
      TelemetryCodec.commandTopic(deviceId),
      MqttQos.atLeastOnce,
      builder.payload!,
    );
  }

  @override
  Future<void> dispose() async {
    await _updates?.cancel();
    _client.autoReconnect = false;
    _client.disconnect();
    await _readings.close();
    await _status.close();
  }
}
