# `lib/data/`

**Purpose:** Data layer: telemetry transports (MQTT, WebSocket, offline simulator) and the generator that fakes sensor values.

> Generated from the code by the `codebase-map` skill (synced at ``). Edit the **Purpose** lines by hand; everything else comes from the source and its `///` comments.

Up: [`lib/`](../README.md)

## Folders

- [`simulator/`](simulator/README.md) — Pure-Dart fake telemetry generator used by the offline simulator source and the `tool/` scripts.
- [`sources/`](sources/README.md) — The `TelemetrySource` interface and its MQTT, WebSocket and simulator implementations; picked by `telemetrySourceProvider`.

