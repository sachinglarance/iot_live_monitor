# `lib/`

**Purpose:** App root: the `main.dart` entry point plus the data, domain, state and ui layers of the IoT live telemetry dashboard.

> Generated from the code by the `codebase-map` skill (synced at ``). Edit the **Purpose** lines by hand; everything else comes from the source and its `///` comments.

## Folders

- [`data/`](data/README.md) — Data layer: telemetry transports (MQTT, WebSocket, offline simulator) and the generator that fakes sensor values.
- [`domain/`](domain/README.md) — Plain-Dart telemetry model (metrics, readings, alerts, link status) and the JSON/topic wire codec shared by all sources.
- [`state/`](state/README.md) — Riverpod providers and notifiers: connection settings, the active telemetry source, and the dashboard state the UI watches.
- [`ui/`](ui/README.md) — Flutter presentation layer: the dashboard and device detail screens plus the reusable widgets they render.

## Files

| File | Purpose |
|---|---|
| [`main.dart`](#maindart) | App entry point: wraps the app in a Riverpod `ProviderScope` and sets up the dark teal Material 3 theme with `DashboardPage` as home. |

## `main.dart`

**Purpose:** App entry point: wraps the app in a Riverpod `ProviderScope` and sets up the dark teal Material 3 theme with `DashboardPage` as home.

Source: [`lib/main.dart`](../../lib/main.dart)

- **Uses:** `lib/ui/pages/dashboard_page.dart`
- **Used by:** — (entry point, generated-code target, or unused)

### function `void main()`

### `class IotLiveMonitorApp extends StatelessWidget`

| Member | Kind | What it does |
|---|---|---|
| `const IotLiveMonitorApp({super.key})` | constructor | _(auto)_ Creates an instance. |
| `Widget build(BuildContext context)` | method | _(auto)_ Builds this widget's UI. |

