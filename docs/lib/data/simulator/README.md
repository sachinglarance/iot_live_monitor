# `lib/data/simulator/`

**Purpose:** Pure-Dart fake telemetry generator used by the offline simulator source and the `tool/` scripts.

> Generated from the code by the `codebase-map` skill (synced at ``). Edit the **Purpose** lines by hand; everything else comes from the source and its `///` comments.

Up: [`lib/data/`](../README.md)

## Files

| File | Purpose |
|---|---|
| [`telemetry_generator.dart`](#telemetry_generatordart) | Produces believable sensor values (slow drift + noise + rare spikes). |

## `telemetry_generator.dart`

**Purpose:** Produces believable sensor values (slow drift + noise + rare spikes).

Source: [`lib/data/simulator/telemetry_generator.dart`](../../../../lib/data/simulator/telemetry_generator.dart)

- **Uses:** `lib/domain/telemetry.dart`
- **Used by:** `lib/data/sources/simulated_source.dart`

### `class TelemetryGenerator`

> Produces believable sensor values (slow drift + noise + rare spikes).
> Pure Dart, so it's shared by the in-app simulator and the `tool/` scripts.

| Member | Kind | What it does |
|---|---|---|
| `TelemetryGenerator({ this.deviceIds = const ['pump-01', 'pump-02', 'tank-01', 'gen-01'], int? seed, }) : _random = Random(seed)` | constructor | _(auto)_ Creates an instance. |
| `final List<String> deviceIds` | field | Ids of the simulated devices; `SimulatedSource` emits one reading batch per id each tick. |
| `final Random _random` | field | _(auto)_ Injected dependency / private state. |
| `final Map<String, Map<Metric, double>> _last = {}` | field | Last generated value per device and metric, so each new value drifts from the previous one instead of jumping. |
| `static const _base = …` | field | _(auto)_ Constant; long value, see the source. |
| `static const _noise = …` | field | _(auto)_ Constant; long value, see the source. |
| `Map<Metric, double> next(String deviceId)` | method | Returns the next value for every metric of the device: previous value pulled 5% back towards baseline plus random noise, with a 1% chance of a large spike that triggers alerts. Starts unknown devices at baseline. |

