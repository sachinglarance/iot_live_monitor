import 'package:flutter/material.dart';

import '../../domain/telemetry.dart';
import '../../state/dashboard_controller.dart';
import 'sparkline.dart';

class DeviceCard extends StatelessWidget {
  const DeviceCard({super.key, required this.device, required this.onTap});
  final DeviceSnapshot device;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: device.hasAlert
            ? BorderSide(color: theme.colorScheme.error, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.sensors, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(device.id, style: theme.textTheme.titleMedium),
                  ),
                  if (device.hasAlert)
                    Icon(
                      Icons.warning_amber_rounded,
                      color: theme.colorScheme.error,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              for (final m in Metric.values)
                if (device.latest(m) case final r?)
                  Row(
                    children: [
                      Expanded(
                        child: Text(m.label, style: theme.textTheme.bodySmall),
                      ),
                      Text(
                        '${r.value.toStringAsFixed(1)} ${m.unit}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                          color: r.isAlert ? theme.colorScheme.error : null,
                          fontWeight: r.isAlert ? FontWeight.bold : null,
                        ),
                      ),
                    ],
                  ),
              const SizedBox(height: 8),
              Expanded(
                child: Sparkline(
                  readings: device.history[Metric.temperature] ?? const [],
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
