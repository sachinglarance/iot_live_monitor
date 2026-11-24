import 'dart:convert';

import 'telemetry.dart';

/// Wire format shared by the MQTT topic, the WebSocket feed and the tools:
/// `{"deviceId":"pump-01","ts":1700000000000,"metrics":{"temperature":31.2}}`
abstract final class TelemetryCodec {
  static const topicPrefix = 'iotlive/demo';
  static String telemetryTopic(String deviceId) =>
      '$topicPrefix/$deviceId/telemetry';
  static String commandTopic(String deviceId) => '$topicPrefix/$deviceId/cmd';
  static const telemetryWildcard = '$topicPrefix/+/telemetry';

  /// Returns an empty list for malformed messages instead of throwing, so one
  /// bad device can't break the stream for everyone.
  static List<SensorReading> decode(String raw) {
    try {
      final json = jsonDecode(raw);
      if (json is! Map<String, dynamic>) return const [];
      final deviceId = json['deviceId'];
      final metrics = json['metrics'];
      if (deviceId is! String || metrics is! Map<String, dynamic>) {
        return const [];
      }
      final ts = json['ts'] is int
          ? DateTime.fromMillisecondsSinceEpoch(json['ts'] as int)
          : DateTime.now();
      return [
        for (final entry in metrics.entries)
          if (entry.value is num &&
              Metric.values.any((m) => m.name == entry.key))
            SensorReading(
              deviceId: deviceId,
              metric: Metric.values.byName(entry.key),
              value: (entry.value as num).toDouble(),
              timestamp: ts,
            ),
      ];
    } on FormatException {
      return const [];
    }
  }

  static String encode(
    String deviceId,
    DateTime ts,
    Map<Metric, double> metrics,
  ) => jsonEncode({
    'deviceId': deviceId,
    'ts': ts.millisecondsSinceEpoch,
    'metrics': {
      for (final e in metrics.entries)
        e.key.name: double.parse(e.value.toStringAsFixed(2)),
    },
  });
}
