import 'dart:math';

import '../../domain/telemetry.dart';

/// Produces believable sensor values (slow drift + noise + rare spikes).
/// Pure Dart, so it's shared by the in-app simulator and the `tool/` scripts.
class TelemetryGenerator {
  TelemetryGenerator({
    this.deviceIds = const ['pump-01', 'pump-02', 'tank-01', 'gen-01'],
    int? seed,
  }) : _random = Random(seed);

  final List<String> deviceIds;
  final Random _random;
  final Map<String, Map<Metric, double>> _last = {};

  static const _base = {
    Metric.temperature: 28.0,
    Metric.humidity: 60.0,
    Metric.power: 300.0,
  };
  static const _noise = {
    Metric.temperature: 0.6,
    Metric.humidity: 1.5,
    Metric.power: 15.0,
  };

  Map<Metric, double> next(String deviceId) {
    final last = _last.putIfAbsent(deviceId, () => Map.of(_base));
    for (final m in Metric.values) {
      final pull = (_base[m]! - last[m]!) * 0.05; // drift back towards baseline
      var v = last[m]! + pull + (_random.nextDouble() * 2 - 1) * _noise[m]!;
      // Occasional spike, so the dashboard has alerts to show.
      if (_random.nextDouble() < 0.01) {
        v += _noise[m]! * 12;
      }
      last[m] = v;
    }
    return Map.of(last);
  }
}
