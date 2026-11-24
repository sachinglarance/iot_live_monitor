import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/connection_providers.dart';
import '../../state/dashboard_controller.dart';
import '../widgets/device_card.dart';
import '../widgets/link_status_chip.dart';
import 'device_detail_page.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardProvider);
    final settings = ref.watch(connectionSettingsProvider);
    final devices = state.devices.values.toList()
      ..sort((a, b) => a.id.compareTo(b.id));
    final width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('IoT Live Monitor'),
        actions: [
          LinkStatusChip(status: state.link),
          PopupMenuButton<Transport>(
            tooltip: 'Data source',
            icon: const Icon(Icons.swap_horiz),
            initialValue: settings.transport,
            onSelected: (t) => ref
                .read(connectionSettingsProvider.notifier)
                .update((s) => s.copyWith(transport: t)),
            itemBuilder: (_) => [
              for (final t in Transport.values)
                PopupMenuItem(value: t, child: Text(t.label)),
            ],
          ),
          IconButton(
            tooltip: 'Connection settings',
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettings(context, ref),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                '${settings.transport.label} · ${devices.length} devices · ${state.messageCount} messages',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ),
          if (devices.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text('Waiting for telemetry…')),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(12),
              sliver: SliverGrid.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: width > 900
                      ? 4
                      : width > 600
                      ? 3
                      : 2,
                  mainAxisExtent: 190,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: devices.length,
                itemBuilder: (context, i) => DeviceCard(
                  device: devices[i],
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => DeviceDetailPage(deviceId: devices[i].id),
                    ),
                  ),
                ),
              ),
            ),
          if (state.alerts.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: ListTile(
                title: const Text('Alerts'),
                trailing: TextButton(
                  onPressed: ref.read(dashboardProvider.notifier).clearAlerts,
                  child: const Text('Clear'),
                ),
              ),
            ),
            SliverList.builder(
              itemCount: state.alerts.length,
              itemBuilder: (_, i) => ListTile(
                dense: true,
                leading: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                ),
                title: Text(state.alerts[i].message),
                subtitle: Text(
                  TimeOfDay.fromDateTime(state.alerts[i].reading.timestamp)
                      .format(context),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showSettings(BuildContext context, WidgetRef ref) async {
    final s = ref.read(connectionSettingsProvider);
    final host = TextEditingController(text: s.mqttHost);
    final ws = TextEditingController(text: s.wsUrl);
    final save = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Connection settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: host,
              decoration: const InputDecoration(labelText: 'MQTT broker host'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ws,
              decoration: const InputDecoration(labelText: 'WebSocket URL'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (save ?? false) {
      ref
          .read(connectionSettingsProvider.notifier)
          .update(
            (s) =>
                s.copyWith(mqttHost: host.text.trim(), wsUrl: ws.text.trim()),
          );
    }
    host.dispose();
    ws.dispose();
  }
}
