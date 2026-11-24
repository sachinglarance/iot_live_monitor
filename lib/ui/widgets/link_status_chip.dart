import 'package:flutter/material.dart';

import '../../domain/telemetry.dart';

class LinkStatusChip extends StatelessWidget {
  const LinkStatusChip({super.key, required this.status});
  final LinkStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      LinkStatus.connected => ('Live', Colors.green),
      LinkStatus.connecting => ('Connecting', Colors.blue),
      LinkStatus.reconnecting => ('Reconnecting', Colors.orange),
      LinkStatus.disconnected => ('Offline', Colors.grey),
      LinkStatus.error => ('Error', Colors.red),
    };
    return Chip(
      avatar: Icon(Icons.circle, size: 10, color: color),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}
