# `lib/data/sources/`

**Purpose:** The `TelemetrySource` interface and its MQTT, WebSocket and simulator implementations; picked by `telemetrySourceProvider`.

> Generated from the code by the `codebase-map` skill (synced at ``). Edit the **Purpose** lines by hand; everything else comes from the source and its `///` comments.

Up: [`lib/data/`](../README.md)

## Files

| File | Purpose |
|---|---|
| [`mqtt_source.dart`](#mqtt_sourcedart) | Subscribes to `iotlive/demo/+/telemetry` on an MQTT broker. |
| [`simulated_source.dart`](#simulated_sourcedart) | Offline `TelemetrySource` that emits generated readings for every simulated device once per interval; no network needed. |
| [`telemetry_source.dart`](#telemetry_sourcedart) | A live feed of sensor readings. |
| [`websocket_source.dart`](#websocket_sourcedart) | Streams telemetry over a WebSocket and reconnects with exponential back-off (1s, 2s, 4s … max 30s) when the socket drops. |

## `mqtt_source.dart`

**Purpose:** Subscribes to `iotlive/demo/+/telemetry` on an MQTT broker.

Source: [`lib/data/sources/mqtt_source.dart`](../../../../lib/data/sources/mqtt_source.dart)

- **Uses:** `lib/data/sources/telemetry_source.dart`, `lib/domain/telemetry.dart`, `lib/domain/telemetry_codec.dart`
- **Used by:** `lib/state/connection_providers.dart`

### `class MqttSource implements TelemetrySource`

> Subscribes to `iotlive/demo/+/telemetry` on an MQTT broker.
> Uses the client's built-in auto-reconnect and re-subscribes on reconnect.

| Member | Kind | What it does |
|---|---|---|
| `MqttSource({ this.host = 'broker.hivemq.com', this.port = 1883, MqttServerClient? client, }) : _client = client ?? MqttServerClient.withPort(host, 'iotlive-${DateTime.now().mill…` | constructor | _(auto)_ Creates an instance. |
| `final String host` | field | Broker host name to connect to; defaults to the public `broker.hivemq.com`. |
| `final int port` | field | Broker TCP port; defaults to 1883 (plain MQTT). |
| `final MqttServerClient _client` | field | _(auto)_ Injected dependency / private state. |
| `final _readings = StreamController<List<SensorReading>>.broadcast()` | field | Broadcast controller behind `readings`; gets one decoded batch per incoming publish message. |
| `final _status = StreamController<LinkStatus>.broadcast()` | field | Broadcast controller behind `status`; fed from the client's connect, disconnect and auto-reconnect callbacks. |
| `StreamSubscription<List<MqttReceivedMessage<MqttMessage>>>? _updates` | field | Subscription to the client's incoming message stream; cancelled in `dispose`. |
| `Stream<List<SensorReading>> get readings` | getter | Stream of decoded reading batches from the telemetry wildcard topic; malformed messages are dropped. |
| `Stream<LinkStatus> get status` | getter | Stream of link state changes (connecting, connected, reconnecting, disconnected, error). |
| `Future<void> connect()` | method | Configures keep-alive and auto-reconnect callbacks, connects to the broker and subscribes to the telemetry wildcard at QoS 0. On connect failure emits `error`, disconnects and returns without retrying. |
| `Future<void> sendCommand(String deviceId, String command)` | method | Commands use QoS 1 so they are delivered at least once. |
| `Future<void> dispose()` | method | Cancels the message subscription, turns off auto-reconnect, disconnects and closes both streams; called when `telemetrySourceProvider` rebuilds. |

## `simulated_source.dart`

**Purpose:** Offline `TelemetrySource` that emits generated readings for every simulated device once per interval; no network needed.

Source: [`lib/data/sources/simulated_source.dart`](../../../../lib/data/sources/simulated_source.dart)

- **Uses:** `lib/data/simulator/telemetry_generator.dart`, `lib/data/sources/telemetry_source.dart`, `lib/domain/telemetry.dart`
- **Used by:** `lib/state/connection_providers.dart`

### `class SimulatedSource implements TelemetrySource`

| Member | Kind | What it does |
|---|---|---|
| `SimulatedSource({ TelemetryGenerator? generator, this.interval = const Duration(seconds: 1), }) : _generator = generator ?? TelemetryGenerator()` | constructor | _(auto)_ Creates an instance. |
| `final TelemetryGenerator _generator` | field | _(auto)_ Injected dependency / private state. |
| `final Duration interval` | field | How often a batch is generated for every device; defaults to 1 second. |
| `final _readings = StreamController<List<SensorReading>>.broadcast()` | field | Broadcast controller behind `readings`; receives one batch per device per tick. |
| `final _status = StreamController<LinkStatus>.broadcast()` | field | Broadcast controller behind `status`; only ever emits `connected`. |
| `Timer? _timer` | field | Periodic timer started by `connect` that drives generation; cancelled in `dispose`. |
| `Stream<List<SensorReading>> get readings` | getter | Stream of generated reading batches, one per simulated device each interval. |
| `Stream<LinkStatus> get status` | getter | Stream of link state; emits `connected` as soon as `connect` runs. |
| `Future<void> connect()` | method | Emits `connected` and starts a periodic timer that asks the generator for every device's next values and emits them as readings stamped with the current time. |
| `Future<void> sendCommand(String deviceId, String command)` | method | No-op: simulated devices ignore commands. |
| `Future<void> dispose()` | method | Stops the timer and closes both streams. |

## `telemetry_source.dart`

**Purpose:** A live feed of sensor readings.

Source: [`lib/data/sources/telemetry_source.dart`](../../../../lib/data/sources/telemetry_source.dart)

- **Uses:** `lib/domain/telemetry.dart`
- **Used by:** `lib/data/sources/mqtt_source.dart`, `lib/data/sources/simulated_source.dart`, `lib/data/sources/websocket_source.dart`, `lib/state/connection_providers.dart`

### `abstract interface class TelemetrySource`

> A live feed of sensor readings. Implemented by MQTT, WebSocket and an
> offline simulator, so the dashboard doesn't care where data comes from.

| Member | Kind | What it does |
|---|---|---|
| `Stream<List<SensorReading>> get readings` | getter | Broadcast stream of reading batches (usually one device's metrics per batch); `DashboardController` feeds it into `ingest`. |
| `Stream<LinkStatus> get status` | getter | Broadcast stream of connection state changes, mirrored into `DashboardState.link`. |
| `Future<void> connect()` | method | Starts the feed (opens the connection or timer); called once by `DashboardController.build`. |
| `Future<void> sendCommand(String deviceId, String command)` | method | Sends a command string to a device over the transport; implementations may silently skip it when not connected. |
| `Future<void> dispose()` | method | Stops the feed and closes the streams; called by `telemetrySourceProvider` when settings change. |

## `websocket_source.dart`

**Purpose:** Streams telemetry over a WebSocket and reconnects with exponential back-off (1s, 2s, 4s … max 30s) when the socket drops.

Source: [`lib/data/sources/websocket_source.dart`](../../../../lib/data/sources/websocket_source.dart)

- **Uses:** `lib/data/sources/telemetry_source.dart`, `lib/domain/telemetry.dart`, `lib/domain/telemetry_codec.dart`
- **Used by:** `lib/state/connection_providers.dart`

### `typedef ChannelFactory = WebSocketChannel Function(Uri uri)`

### `class WebSocketSource implements TelemetrySource`

> Streams telemetry over a WebSocket and reconnects with exponential back-off
> (1s, 2s, 4s … max 30s) when the socket drops.

| Member | Kind | What it does |
|---|---|---|
| `WebSocketSource({required this.uri, ChannelFactory? channelFactory}) : _factory = channelFactory ?? WebSocketChannel.connect` | constructor | _(auto)_ Takes the dependencies / values listed as named parameters. |
| `final Uri uri` | field | WebSocket server address to connect (and reconnect) to. |
| `final ChannelFactory _factory` | field | _(auto)_ Injected dependency / private state. |
| `final _readings = StreamController<List<SensorReading>>.broadcast()` | field | Broadcast controller behind `readings`; receives decoded batches from text frames. |
| `final _status = StreamController<LinkStatus>.broadcast()` | field | Broadcast controller behind `status`; emits connecting, connected and reconnecting. |
| `WebSocketChannel? _channel` | field | Current socket channel; replaced on each connect attempt and used by `sendCommand`. |
| `StreamSubscription<dynamic>? _sub` | field | Subscription to the current channel's messages; cancelled before reconnecting and on dispose. |
| `Timer? _retryTimer` | field | Pending reconnect timer; cancelled when a new one is scheduled or on dispose. |
| `int _attempt = 0` | field | Consecutive failed attempts, used for the back-off delay; reset to 0 after a successful connect. |
| `bool _disposed = false` | field | Set by `dispose` so pending connects and reconnects stop instead of reopening the socket. |
| `Stream<List<SensorReading>> get readings` | getter | Stream of decoded reading batches; non-text frames and malformed messages are dropped. |
| `Stream<LinkStatus> get status` | getter | Stream of link state changes across connects and reconnects. |
| `static Duration retryDelay(int attempt)` | method | Returns the back-off delay for an attempt number: 2^attempt seconds, capped at 30s (1s, 2s, 4s … 30s). |
| `Future<void> connect()` | method | Emits `connecting` (first try) or `reconnecting`, opens the channel and waits for it to be ready, then emits `connected` and listens for frames. Any failure, error or socket close schedules a reconnect; does nothing after dispose. |
| `void _scheduleReconnect()` | method | Cancels the current subscription, emits `reconnecting` and starts a timer to call `connect` after `retryDelay`, incrementing the attempt count. Skipped once disposed. |
| `Future<void> sendCommand(String deviceId, String command)` | method | Sends `{"deviceId","command"}` JSON over the current socket; silently does nothing if no channel exists yet. |
| `Future<void> dispose()` | method | Marks the source disposed, cancels the retry timer and subscription, closes the socket and both streams. |

