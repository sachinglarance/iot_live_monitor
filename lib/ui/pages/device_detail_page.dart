import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/telemetry.dart';
import '../../state/dashboard_controller.dart';
import '../widgets/sparkline.dart';

class DeviceDetailPage extends ConsumerWidget {
  const DeviceDetailPage({super.key, required this.deviceId});
  final String deviceId;

  static const _colors = {
    Metric.temperature: Colors.deepOrange,
    Metric.humidity: Colors.blue,
    Metric.power: Colors.green,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // `select` rebuilds this page only when *this* device changes.
    final device = ref.watch(
      dashboardProvider.select((s) => s.devices[deviceId]),
    );
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(deviceId)),
      body: device == null
          ? const Center(child: Text('No data yet'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final m in Metric.values)
                  if (device.latest(m) case final r?)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  m.label,
                                  style: theme.textTheme.titleMedium,
                                ),
                                const Spacer(),
                                Text(
                                  '${r.value.toStringAsFixed(1)} ${m.unit}',
                                  style: theme.textTheme.headlineSmall,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 140,
                              child: Sparkline(
                                readings: device.history[m]!,
                                color: _colors[m]!,
                                showAxis: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                const SizedBox(height: 8),
                Text(
                  'Remote commands (MQTT QoS 1)',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final cmd in ['relay:on', 'relay:off', 'reboot'])
                      OutlinedButton(
                        onPressed: () async {
                          await ref
                              .read(dashboardProvider.notifier)
                              .sendCommand(deviceId, cmd);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Sent "$cmd" to $deviceId'),
                              ),
                            );
                          }
                        },
                        child: Text(cmd),
                      ),
                  ],
                ),
              ],
            ),
    );
  }
}
