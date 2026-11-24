# `lib/ui/widgets/`

**Purpose:** Widgets used by this module's pages; render state passed in or watched from controllers.

> Generated from the code by the `codebase-map` skill (synced at ``). Edit the **Purpose** lines by hand; everything else comes from the source and its `///` comments.

Up: [`lib/ui/`](../README.md)

## Files

| File | Purpose |
|---|---|
| [`device_card.dart`](#device_carddart) | Dashboard grid card for one device: latest metric values, alert highlighting and a temperature sparkline. |
| [`link_status_chip.dart`](#link_status_chipdart) | App-bar chip that shows the current `LinkStatus` as a coloured dot and label (Live, Connecting, Offline …). |
| [`sparkline.dart`](#sparklinedart) | fl_chart line chart of a reading series; compact by default, with axis, grid, touch and a dashed alert-limit line when `showAxis` is true. |

## `device_card.dart`

**Purpose:** Dashboard grid card for one device: latest metric values, alert highlighting and a temperature sparkline.

Source: [`lib/ui/widgets/device_card.dart`](../../../../lib/ui/widgets/device_card.dart)

- **Uses:** `lib/domain/telemetry.dart`, `lib/state/dashboard_controller.dart`, `lib/ui/widgets/sparkline.dart`
- **Used by:** `lib/ui/pages/dashboard_page.dart`

### `class DeviceCard extends StatelessWidget`

| Member | Kind | What it does |
|---|---|---|
| `const DeviceCard({super.key, required this.device, required this.onTap})` | constructor | _(auto)_ Takes the dependencies / values listed as named parameters. |
| `final DeviceSnapshot device` | field | _(auto)_ Value passed in by the parent widget. |
| `final VoidCallback onTap` | field | _(auto)_ Value passed in by the parent widget. |
| `Widget build(BuildContext context)` | method | _(auto)_ Builds this widget's UI. |

## `link_status_chip.dart`

**Purpose:** App-bar chip that shows the current `LinkStatus` as a coloured dot and label (Live, Connecting, Offline …).

Source: [`lib/ui/widgets/link_status_chip.dart`](../../../../lib/ui/widgets/link_status_chip.dart)

- **Uses:** `lib/domain/telemetry.dart`
- **Used by:** `lib/ui/pages/dashboard_page.dart`

### `class LinkStatusChip extends StatelessWidget`

| Member | Kind | What it does |
|---|---|---|
| `const LinkStatusChip({super.key, required this.status})` | constructor | _(auto)_ Takes the dependencies / values listed as named parameters. |
| `final LinkStatus status` | field | _(auto)_ Value passed in by the parent widget. |
| `Widget build(BuildContext context)` | method | _(auto)_ Builds this widget's UI. |

## `sparkline.dart`

**Purpose:** fl_chart line chart of a reading series; compact by default, with axis, grid, touch and a dashed alert-limit line when `showAxis` is true.

Source: [`lib/ui/widgets/sparkline.dart`](../../../../lib/ui/widgets/sparkline.dart)

- **Uses:** `lib/domain/telemetry.dart`
- **Used by:** `lib/ui/pages/device_detail_page.dart`, `lib/ui/widgets/device_card.dart`

### `class Sparkline extends StatelessWidget`

| Member | Kind | What it does |
|---|---|---|
| `const Sparkline({ super.key, required this.readings, required this.color, this.showAxis = false, })` | constructor | _(auto)_ Takes the dependencies / values listed as named parameters. |
| `final List<SensorReading> readings` | field | _(auto)_ Value passed in by the parent widget. |
| `final Color color` | field | _(auto)_ Value passed in by the parent widget. |
| `final bool showAxis` | field | _(auto)_ Value passed in by the parent widget. |
| `Widget build(BuildContext context)` | method | _(auto)_ Builds this widget's UI. |

