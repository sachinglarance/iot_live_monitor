# `lib/domain/`

**Purpose:** Plain-Dart telemetry model (metrics, readings, alerts, link status) and the JSON/topic wire codec shared by all sources.

> Generated from the code by the `codebase-map` skill (synced at ``). Edit the **Purpose** lines by hand; everything else comes from the source and its `///` comments.

Up: [`lib/`](../README.md)

## Files

| File | Purpose |
|---|---|
| [`telemetry.dart`](#telemetrydart) | Core telemetry model: the `Metric` enum with alert limits, `SensorReading`, `Alert` and the `LinkStatus` connection states. |
| [`telemetry_codec.dart`](#telemetry_codecdart) | Wire format shared by the MQTT topic, the WebSocket feed and the tools: `{"deviceId":"pump-01","ts":1700000000000,"metrics":{"temperature":31.2}}` |

## `telemetry.dart`

**Purpose:** Core telemetry model: the `Metric` enum with alert limits, `SensorReading`, `Alert` and the `LinkStatus` connection states.

Source: [`lib/domain/telemetry.dart`](../../../lib/domain/telemetry.dart)

- **Uses:** —
- **Used by:** `lib/data/simulator/telemetry_generator.dart`, `lib/data/sources/mqtt_source.dart`, `lib/data/sources/simulated_source.dart`, `lib/data/sources/telemetry_source.dart`, `lib/data/sources/websocket_source.dart`, `lib/domain/telemetry_codec.dart`, `lib/state/dashboard_controller.dart`, `lib/ui/pages/device_detail_page.dart`, `lib/ui/widgets/device_card.dart`, `lib/ui/widgets/link_status_chip.dart`, `lib/ui/widgets/sparkline.dart`

### `enum Metric`

> Core telemetry model: the `Metric` enum with alert limits, `SensorReading`,
> `Alert` and the `LinkStatus` connection states.

| Member | Kind | What it does |
|---|---|---|
| `temperature('Temperature', '°C', 35)` | value | _(auto)_ Enum value. |
| `humidity('Humidity', '%', 85)` | value | _(auto)_ Enum value. |
| `power('Power', 'W', 450)` | value | _(auto)_ Enum value. |
| `const Metric(this.label, this.unit, this.alertAbove)` | constructor | _(auto)_ Creates an instance. |
| `final String label` | field | Display name of the metric (e.g. `Temperature`) used in cards, detail page and alert messages. |
| `final String unit` | field | Unit suffix (`°C`, `%`, `W`) appended to displayed values and alert messages. |
| `final double alertAbove` | field | Readings above this raise an alert on the dashboard. |

### `class SensorReading`

| Member | Kind | What it does |
|---|---|---|
| `const SensorReading({ required this.deviceId, required this.metric, required this.value, required this.timestamp, })` | constructor | _(auto)_ Takes the dependencies / values listed as named parameters. |
| `final String deviceId` | field | Id of the device that sent the reading; the dashboard groups readings by it. |
| `final Metric metric` | field | Which metric this value measures. |
| `final double value` | field | Measured value in the metric's unit. |
| `final DateTime timestamp` | field | When the reading was taken (from the message `ts`, or receive time if missing). |
| `bool get isAlert` | getter | True when `value` is strictly above `metric.alertAbove`; drives alert creation and red highlighting. |

### `enum LinkStatus`

> State of the link to the broker or server, shown as a chip in the app bar.

| Member | Kind | What it does |
|---|---|---|
| `disconnected` | value | _(auto)_ Enum value. |
| `connecting` | value | _(auto)_ Enum value. |
| `connected` | value | _(auto)_ Enum value. |
| `reconnecting` | value | _(auto)_ Enum value. |
| `error` | value | _(auto)_ Enum value. |

### `class Alert`

| Member | Kind | What it does |
|---|---|---|
| `const Alert(this.reading)` | constructor | _(auto)_ Creates an instance. |
| `final SensorReading reading` | field | The reading that crossed its metric's limit and triggered this alert. |
| `String get message` | getter | Human-readable text like `pump-01: Temperature 36.2°C (limit 35°C)`, shown in the dashboard alerts list. |

## `telemetry_codec.dart`

**Purpose:** Wire format shared by the MQTT topic, the WebSocket feed and the tools: `{"deviceId":"pump-01","ts":1700000000000,"metrics":{"temperature":31.2}}`

Source: [`lib/domain/telemetry_codec.dart`](../../../lib/domain/telemetry_codec.dart)

- **Uses:** `lib/domain/telemetry.dart`
- **Used by:** `lib/data/sources/mqtt_source.dart`, `lib/data/sources/websocket_source.dart`

### `abstract final class TelemetryCodec`

> Wire format shared by the MQTT topic, the WebSocket feed and the tools:
> `{"deviceId":"pump-01","ts":1700000000000,"metrics":{"temperature":31.2}}`

| Member | Kind | What it does |
|---|---|---|
| `static const topicPrefix = 'iotlive/demo'` | field | _(auto)_ Constant; the value is in the signature. |
| `static String telemetryTopic(String deviceId)` | method | Returns the MQTT topic a device publishes telemetry to: `iotlive/demo/<deviceId>/telemetry`. |
| `static String commandTopic(String deviceId)` | method | Returns the MQTT topic a device listens on for commands: `iotlive/demo/<deviceId>/cmd`; used by `MqttSource.sendCommand`. |
| `static const telemetryWildcard = '$topicPrefix/+/telemetry'` | field | _(auto)_ Constant; the value is in the signature. |
| `static List<SensorReading> decode(String raw)` | method | Returns an empty list for malformed messages instead of throwing, so one bad device can't break the stream for everyone. |
| `static String encode(String deviceId, DateTime ts, Map<Metric, double> metrics)` | method | Builds the JSON wire message from a device id, timestamp and metric values, rounding values to 2 decimals; used by the simulator tools to publish data. |

