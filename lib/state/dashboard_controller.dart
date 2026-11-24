import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/telemetry.dart';
import 'connection_providers.dart';

class DeviceSnapshot {
  const DeviceSnapshot({
    required this.id,
    required this.history,
    required this.lastSeen,
  });
  final String id;
  final Map<Metric, List<SensorReading>> history;
  final DateTime lastSeen;

  SensorReading? latest(Metric m) => history[m]?.lastOrNull;
  bool get hasAlert => Metric.values.any((m) => latest(m)?.isAlert ?? false);
}

class DashboardState {
  const DashboardState({
    this.devices = const {},
    this.alerts = const [],
    this.link = LinkStatus.disconnected,
    this.messageCount = 0,
  });

  final Map<String, DeviceSnapshot> devices;
  final List<Alert> alerts;
  final LinkStatus link;
  final int messageCount;

  DashboardState copyWith({
    Map<String, DeviceSnapshot>? devices,
    List<Alert>? alerts,
    LinkStatus? link,
    int? messageCount,
  }) => DashboardState(
    devices: devices ?? this.devices,
    alerts: alerts ?? this.alerts,
    link: link ?? this.link,
    messageCount: messageCount ?? this.messageCount,
  );
}

final dashboardProvider = NotifierProvider<DashboardController, DashboardState>(
  DashboardController.new,
);

class DashboardController extends Notifier<DashboardState> {
  static const historyLength = 60;
  static const maxAlerts = 20;

  @override
  DashboardState build() {
    final source = ref.watch(telemetrySourceProvider);
    final subs = [
      source.readings.listen(ingest),
      source.status.listen((s) => state = state.copyWith(link: s)),
    ];
    ref.onDispose(() {
      for (final s in subs) {
        s.cancel();
      }
    });
    unawaited(source.connect());
    return const DashboardState(link: LinkStatus.connecting);
  }

  /// Adds readings to a rolling window per device and metric. Alerts are
  /// edge-triggered: one alert when a value crosses its limit, not one per
  /// reading while it stays high.
  void ingest(List<SensorReading> readings) {
    final devices = Map.of(state.devices);
    final newAlerts = <Alert>[];

    for (final r in readings) {
      final device = devices[r.deviceId];
      final history = {
        for (final e in (device?.history ?? const {}).entries) e.key: e.value,
      };
      final series = history[r.metric] ?? const <SensorReading>[];
      final wasAlert = series.lastOrNull?.isAlert ?? false;
      if (r.isAlert && !wasAlert) newAlerts.add(Alert(r));

      final updated = [...series, r];
      history[r.metric] = updated.length > historyLength
          ? updated.sublist(updated.length - historyLength)
          : updated;
      devices[r.deviceId] = DeviceSnapshot(
        id: r.deviceId,
        history: history,
        lastSeen: r.timestamp,
      );
    }

    final alerts = [...newAlerts.reversed, ...state.alerts];
    state = state.copyWith(
      devices: devices,
      alerts: alerts.length > maxAlerts ? alerts.sublist(0, maxAlerts) : alerts,
      messageCount: state.messageCount + 1,
    );
  }

  void clearAlerts() => state = state.copyWith(alerts: const []);

  Future<void> sendCommand(String deviceId, String command) =>
      ref.read(telemetrySourceProvider).sendCommand(deviceId, command);
}
