/// Core telemetry model: the `Metric` enum with alert limits, `SensorReading`,
/// `Alert` and the `LinkStatus` connection states.
enum Metric {
  temperature('Temperature', '°C', 35),
  humidity('Humidity', '%', 85),
  power('Power', 'W', 450);

  const Metric(this.label, this.unit, this.alertAbove);
  final String label;
  final String unit;

  /// Readings above this raise an alert on the dashboard.
  final double alertAbove;
}

class SensorReading {
  const SensorReading({
    required this.deviceId,
    required this.metric,
    required this.value,
    required this.timestamp,
  });
  final String deviceId;
  final Metric metric;
  final double value;
  final DateTime timestamp;

  bool get isAlert => value > metric.alertAbove;
}

/// State of the link to the broker or server, shown as a chip in the app bar.
enum LinkStatus { disconnected, connecting, connected, reconnecting, error }

class Alert {
  const Alert(this.reading);
  final SensorReading reading;
  String get message =>
      '${reading.deviceId}: ${reading.metric.label} ${reading.value.toStringAsFixed(1)}${reading.metric.unit} '
      '(limit ${reading.metric.alertAbove.toStringAsFixed(0)}${reading.metric.unit})';
}
