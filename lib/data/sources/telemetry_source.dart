import '../../domain/telemetry.dart';

/// A live feed of sensor readings. Implemented by MQTT, WebSocket and an
/// offline simulator, so the dashboard doesn't care where data comes from.
abstract interface class TelemetrySource {
  Stream<List<SensorReading>> get readings;
  Stream<LinkStatus> get status;
  Future<void> connect();
  Future<void> sendCommand(String deviceId, String command);
  Future<void> dispose();
}
