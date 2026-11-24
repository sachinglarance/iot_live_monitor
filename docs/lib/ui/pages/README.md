# `lib/ui/pages/`

**Purpose:** Routed screens (`ConsumerWidget` / `ConsumerStatefulWidget`); render controller state only.

> Generated from the code by the `codebase-map` skill (synced at ``). Edit the **Purpose** lines by hand; everything else comes from the source and its `///` comments.

Up: [`lib/ui/`](../README.md)

## Files

| File | Purpose |
|---|---|
| [`dashboard_page.dart`](#dashboard_pagedart) | Home screen: responsive grid of device cards, link status chip, data-source picker, connection settings dialog and the alerts list. |
| [`device_detail_page.dart`](#device_detail_pagedart) | Per-device screen showing each metric's latest value with a full sparkline chart and buttons to send remote commands. |

## `dashboard_page.dart`

**Purpose:** Home screen: responsive grid of device cards, link status chip, data-source picker, connection settings dialog and the alerts list.

Source: [`lib/ui/pages/dashboard_page.dart`](../../../../lib/ui/pages/dashboard_page.dart)

- **Uses:** `lib/state/connection_providers.dart`, `lib/state/dashboard_controller.dart`, `lib/ui/pages/device_detail_page.dart`, `lib/ui/widgets/device_card.dart`, `lib/ui/widgets/link_status_chip.dart`
- **Used by:** `lib/main.dart`

### `class DashboardPage extends ConsumerWidget`

| Member | Kind | What it does |
|---|---|---|
| `const DashboardPage({super.key})` | constructor | _(auto)_ Creates an instance. |
| `Widget build(BuildContext context, WidgetRef ref)` | method | _(auto)_ Builds this widget's UI. |
| `Future<void> _showSettings(BuildContext context, WidgetRef ref)` | method | Opens a dialog pre-filled with the MQTT host and WebSocket URL; on Save, writes the trimmed values to `connectionSettingsProvider` (rebuilding the source). Disposes the text controllers afterwards. |

## `device_detail_page.dart`

**Purpose:** Per-device screen showing each metric's latest value with a full sparkline chart and buttons to send remote commands.

Source: [`lib/ui/pages/device_detail_page.dart`](../../../../lib/ui/pages/device_detail_page.dart)

- **Uses:** `lib/domain/telemetry.dart`, `lib/state/dashboard_controller.dart`, `lib/ui/widgets/sparkline.dart`
- **Used by:** `lib/ui/pages/dashboard_page.dart`

### `class DeviceDetailPage extends ConsumerWidget`

| Member | Kind | What it does |
|---|---|---|
| `const DeviceDetailPage({super.key, required this.deviceId})` | constructor | _(auto)_ Takes the dependencies / values listed as named parameters. |
| `final String deviceId` | field | _(auto)_ Value passed in by the parent widget. |
| `static const _colors = …` | field | _(auto)_ Constant; long value, see the source. |
| `Widget build(BuildContext context, WidgetRef ref)` | method | _(auto)_ Builds this widget's UI. |

