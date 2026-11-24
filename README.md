# IoT Live Monitor: real-time MQTT and WebSocket dashboard (Flutter)

A real-time monitoring dashboard for field devices such as pumps, tanks and generators. It
streams telemetry over **MQTT** or **WebSocket**, draws live charts, raises threshold alerts,
and sends remote commands back to devices.

The data source can be switched at runtime between:

| Source | Use it for |
|---|---|
| **Simulator** (default) | Works offline, with no setup |
| **MQTT broker** | Subscribes to `iotlive/demo/+/telemetry` on a public broker (HiveMQ by default) |
| **WebSocket server** | Connects to any server that sends the same JSON format (a mock server is included) |

## Features

- **MQTT** with `mqtt_client`: wildcard subscription, keep-alive, auto-reconnect, re-subscribe after reconnect, and **QoS 1** for commands
- **WebSocket** with `web_socket_channel`: reconnects with **exponential back-off** (1s, 2s, 4s, up to 30s)
- Every source implements one `TelemetrySource` interface, so the dashboard does not know which one it is using
- Live line charts with `fl_chart`, with a rolling window of 60 readings for each metric and a dashed threshold line
- **Edge-triggered alerts**: one alert when a value crosses its limit, instead of one for every reading while it stays high
- Malformed messages are dropped safely. One bad device cannot break the stream for the others.
- `ref.watch(provider.select(...))` keeps rebuilds limited to the device being viewed
- Responsive grid with dark-mode Material 3

## Try it with real MQTT

```bash
# terminal 1: publish fake devices to the public broker
dart run tool/mqtt_device_simulator.dart

# terminal 2
flutter run      # then switch the data source to "MQTT broker"
```

When you send a command from a device page (`relay:on`, `reboot`), it is printed by the simulator.

## Try it with WebSocket

```bash
dart run tool/ws_mock_server.dart
flutter run      # switch to "WebSocket server"
                 # Android emulator: ws://10.0.2.2:8080 · iOS simulator: ws://localhost:8080
```

## Message format

```json
{ "deviceId": "pump-01", "ts": 1700000000000,
  "metrics": { "temperature": 31.2, "humidity": 64.0, "power": 298.5 } }
```

## Architecture

```
lib/
├── domain/        # Metric, SensorReading, LinkStatus, Alert, TelemetryCodec (wire format)
├── data/
│   ├── sources/   # TelemetrySource interface + MQTT, WebSocket and simulated implementations
│   └── simulator/ # TelemetryGenerator (pure Dart, also used by tool/)
├── state/         # Riverpod: connection settings → source provider → DashboardController
└── ui/            # dashboard, device detail, sparkline, status chip
tool/              # MQTT device simulator, WebSocket mock server
```

When the user changes the data source, `telemetrySourceProvider` is rebuilt. Riverpod disposes
the old connection, and `DashboardController` subscribes to the new one.

## Tests

```bash
flutter test
```

- **Codec**: round-trip encoding, and malformed or partial payloads never throw
- **DashboardController**: rolling history limit, edge-triggered alerts, status from the stream, commands sent to the source (with a fake source)
- **WebSocketSource**: tested against a **real local WebSocket server**. It receives data, detects the drop and switches to reconnecting. The back-off curve is also tested.

**Tech:** Flutter · Dart 3 · Riverpod 3 · mqtt_client · web_socket_channel · fl_chart · GitHub Actions
