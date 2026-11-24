import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/sources/mqtt_source.dart';
import '../data/sources/simulated_source.dart';
import '../data/sources/telemetry_source.dart';
import '../data/sources/websocket_source.dart';

/// Connection settings (transport, MQTT host, WebSocket URL), their notifier,
/// and `telemetrySourceProvider` that builds the matching `TelemetrySource`.
enum Transport {
  simulated('Simulator (offline)'),
  mqtt('MQTT broker'),
  websocket('WebSocket server');

  const Transport(this.label);
  final String label;
}

class ConnectionSettings {
  const ConnectionSettings({
    this.transport = Transport.simulated,
    this.mqttHost = 'broker.hivemq.com',
    // 10.0.2.2 is the host machine as seen from the Android emulator.
    this.wsUrl = 'ws://10.0.2.2:8080',
  });

  final Transport transport;
  final String mqttHost;
  final String wsUrl;

  ConnectionSettings copyWith({
    Transport? transport,
    String? mqttHost,
    String? wsUrl,
  }) => ConnectionSettings(
    transport: transport ?? this.transport,
    mqttHost: mqttHost ?? this.mqttHost,
    wsUrl: wsUrl ?? this.wsUrl,
  );
}

final connectionSettingsProvider =
    NotifierProvider<ConnectionSettingsController, ConnectionSettings>(
      ConnectionSettingsController.new,
    );

class ConnectionSettingsController extends Notifier<ConnectionSettings> {
  @override
  ConnectionSettings build() => const ConnectionSettings();

  void update(ConnectionSettings Function(ConnectionSettings) change) =>
      state = change(state);
}

/// Rebuilt (old one disposed) whenever the settings change.
final telemetrySourceProvider = Provider<TelemetrySource>((ref) {
  final s = ref.watch(connectionSettingsProvider);
  final TelemetrySource source = switch (s.transport) {
    Transport.simulated => SimulatedSource(),
    Transport.mqtt => MqttSource(host: s.mqttHost),
    Transport.websocket => WebSocketSource(uri: Uri.parse(s.wsUrl)),
  };
  ref.onDispose(source.dispose);
  return source;
});
