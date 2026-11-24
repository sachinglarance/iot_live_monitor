# `lib/state/`

**Purpose:** Riverpod providers and notifiers: connection settings, the active telemetry source, and the dashboard state the UI watches.

> Generated from the code by the `codebase-map` skill (synced at ``). Edit the **Purpose** lines by hand; everything else comes from the source and its `///` comments.

Up: [`lib/`](../README.md)

## Files

| File | Purpose |
|---|---|
| [`connection_providers.dart`](#connection_providersdart) | Connection settings (transport, MQTT host, WebSocket URL), their notifier, and `telemetrySourceProvider` that builds the matching `TelemetrySource`. |
| [`dashboard_controller.dart`](#dashboard_controllerdart) | Dashboard state (per-device rolling history, alerts, link status, message count) and the `DashboardController` that feeds it from the telemetry source. |

## `connection_providers.dart`

**Purpose:** Connection settings (transport, MQTT host, WebSocket URL), their notifier, and `telemetrySourceProvider` that builds the matching `TelemetrySource`.

Source: [`lib/state/connection_providers.dart`](../../../lib/state/connection_providers.dart)

- **Uses:** `lib/data/sources/mqtt_source.dart`, `lib/data/sources/simulated_source.dart`, `lib/data/sources/telemetry_source.dart`, `lib/data/sources/websocket_source.dart`
- **Used by:** `lib/state/dashboard_controller.dart`, `lib/ui/pages/dashboard_page.dart`

### `enum Transport`

> Connection settings (transport, MQTT host, WebSocket URL), their notifier,
> and `telemetrySourceProvider` that builds the matching `TelemetrySource`.

| Member | Kind | What it does |
|---|---|---|
| `simulated('Simulator (offline)')` | value | _(auto)_ Enum value. |
| `mqtt('MQTT broker')` | value | _(auto)_ Enum value. |
| `websocket('WebSocket server')` | value | _(auto)_ Enum value. |
| `const Transport(this.label)` | constructor | _(auto)_ Creates an instance. |
| `final String label` | field | Human-readable name shown in the dashboard's data-source popup menu and status line. |

### `class ConnectionSettings`

| Member | Kind | What it does |
|---|---|---|
| `const ConnectionSettings({ this.transport = Transport.simulated, this.mqttHost = 'broker.hivemq.com', // 10.0.2.2 is the host machine as seen from the Android emulator. this.wsU…` | constructor | _(auto)_ Creates an instance. |
| `final Transport transport` | field | Which data source to use; defaults to the offline simulator. Changing it makes `telemetrySourceProvider` rebuild the source. |
| `final String mqttHost` | field | MQTT broker host passed to `MqttSource`; defaults to `broker.hivemq.com`, editable in the settings dialog. |
| `final String wsUrl` | field | WebSocket server URL parsed into the `WebSocketSource` URI; defaults to `ws://10.0.2.2:8080` (the host machine from the Android emulator). |
| `ConnectionSettings copyWith({ Transport? transport, String? mqttHost, String? wsUrl, })` | method | Returns a copy with the given fields replaced; used by the dashboard when the transport or settings dialog values change. |

### variable `final connectionSettingsProvider = NotifierProvider<ConnectionSettingsController, ConnectionSettings>(ConnectionSettingsController.new)`

### `class ConnectionSettingsController extends Notifier<ConnectionSettings>`

| Member | Kind | What it does |
|---|---|---|
| `ConnectionSettings build()` | method | Returns the default `ConnectionSettings` (simulator transport); settings are not persisted between launches. |
| `void update(ConnectionSettings Function(ConnectionSettings) change)` | method | Replaces the state with `change(state)`; called by `DashboardPage` for the transport menu and settings dialog, which rebuilds the telemetry source. |

### variable `final telemetrySourceProvider = …`

> Rebuilt (old one disposed) whenever the settings change.

## `dashboard_controller.dart`

**Purpose:** Dashboard state (per-device rolling history, alerts, link status, message count) and the `DashboardController` that feeds it from the telemetry source.

Source: [`lib/state/dashboard_controller.dart`](../../../lib/state/dashboard_controller.dart)

- **Uses:** `lib/domain/telemetry.dart`, `lib/state/connection_providers.dart`
- **Used by:** `lib/ui/pages/dashboard_page.dart`, `lib/ui/pages/device_detail_page.dart`, `lib/ui/widgets/device_card.dart`

### `class DeviceSnapshot`

| Member | Kind | What it does |
|---|---|---|
| `const DeviceSnapshot({ required this.id, required this.history, required this.lastSeen, })` | constructor | _(auto)_ Takes the dependencies / values listed as named parameters. |
| `final String id` | field | Device id from the readings (e.g. `pump-01`); used as the card title, sort key and detail-page key. |
| `final Map<Metric, List<SensorReading>> history` | field | Rolling per-metric reading history, capped at `DashboardController.historyLength` entries; feeds the sparklines. |
| `final DateTime lastSeen` | field | Timestamp of the most recent reading ingested for this device. |
| `SensorReading? latest(Metric m)` | method | Returns the newest reading for metric `m`, or null if the device has never reported it. |
| `bool get hasAlert` | getter | True when the latest reading of any metric is above its alert limit; `DeviceCard` uses it for the red border and warning icon. |

### `class DashboardState`

| Member | Kind | What it does |
|---|---|---|
| `const DashboardState({ this.devices = const {}, this.alerts = const [], this.link = LinkStatus.disconnected, this.messageCount = 0, })` | constructor | _(auto)_ Creates an instance. |
| `final Map<String, DeviceSnapshot> devices` | field | All devices seen so far, keyed by device id; the dashboard sorts them by id for the grid. |
| `final List<Alert> alerts` | field | Recent alerts, newest first, capped at `DashboardController.maxAlerts`; shown in the dashboard alerts list. |
| `final LinkStatus link` | field | Current connection state mirrored from the source's `status` stream; shown by `LinkStatusChip`. |
| `final int messageCount` | field | Number of reading batches ingested since the source was (re)built; shown in the dashboard status line. |
| `DashboardState copyWith({ Map<String, DeviceSnapshot>? devices, List<Alert>? alerts, LinkStatus? link, int? messageCount, })` | method | Returns a copy with the given fields replaced; used by `DashboardController` for every state update. |

### variable `final dashboardProvider = …`

### `class DashboardController extends Notifier<DashboardState>`

| Member | Kind | What it does |
|---|---|---|
| `static const historyLength = 60` | field | _(auto)_ Constant; the value is in the signature. |
| `static const maxAlerts = 20` | field | _(auto)_ Constant; the value is in the signature. |
| `DashboardState build()` | method | Watches `telemetrySourceProvider`, subscribes to its readings (into `ingest`) and status streams, starts `connect()` without awaiting, and returns an empty state with `connecting` link. Re-runs (fresh state) whenever the source is rebuilt; subscriptions are cancelled on dispose. |
| `void ingest(List<SensorReading> readings)` | method | Adds readings to a rolling window per device and metric. Alerts are edge-triggered: one alert when a value crosses its limit, not one per reading while it stays high. |
| `void clearAlerts()` | method | Empties the alerts list; wired to the Clear button in the dashboard alerts header. |
| `Future<void> sendCommand(String deviceId, String command)` | method | Forwards a command to the current telemetry source; called from the device detail page buttons. What happens depends on the transport (no-op for the simulator). |

