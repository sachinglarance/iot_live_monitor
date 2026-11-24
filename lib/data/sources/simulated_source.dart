import 'dart:async';

import '../../domain/telemetry.dart';
import '../simulator/telemetry_generator.dart';
import 'telemetry_source.dart';

class SimulatedSource implements TelemetrySource {
  SimulatedSource({
    TelemetryGenerator? generator,
    this.interval = const Duration(seconds: 1),
  }) : _generator = generator ?? TelemetryGenerator();

  final TelemetryGenerator _generator;
  final Duration interval;
  final _readings = StreamController<List<SensorReading>>.broadcast();
  final _status = StreamController<LinkStatus>.broadcast();
  Timer? _timer;

  @override
  Stream<List<SensorReading>> get readings => _readings.stream;

  @override
  Stream<LinkStatus> get status => _status.stream;

  @override
  Future<void> connect() async {
    _status.add(LinkStatus.connected);
    _timer = Timer.periodic(interval, (_) {
      final now = DateTime.now();
      for (final id in _generator.deviceIds) {
        final values = _generator.next(id);
        _readings.add([
          for (final e in values.entries)
            SensorReading(
              deviceId: id,
              metric: e.key,
              value: e.value,
              timestamp: now,
            ),
        ]);
      }
    });
  }

  @override
  Future<void> sendCommand(String deviceId, String command) async {}

  @override
  Future<void> dispose() async {
    _timer?.cancel();
    await _readings.close();
    await _status.close();
  }
}
