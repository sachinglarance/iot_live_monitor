import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../../domain/telemetry.dart';
import '../../domain/telemetry_codec.dart';
import 'telemetry_source.dart';

typedef ChannelFactory = WebSocketChannel Function(Uri uri);

/// Streams telemetry over a WebSocket and reconnects with exponential back-off
/// (1s, 2s, 4s … max 30s) when the socket drops.
class WebSocketSource implements TelemetrySource {
  WebSocketSource({required this.uri, ChannelFactory? channelFactory})
    : _factory = channelFactory ?? WebSocketChannel.connect;

  final Uri uri;
  final ChannelFactory _factory;
  final _readings = StreamController<List<SensorReading>>.broadcast();
  final _status = StreamController<LinkStatus>.broadcast();

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _sub;
  Timer? _retryTimer;
  int _attempt = 0;
  bool _disposed = false;

  @override
  Stream<List<SensorReading>> get readings => _readings.stream;

  @override
  Stream<LinkStatus> get status => _status.stream;

  static Duration retryDelay(int attempt) =>
      Duration(seconds: min(30, pow(2, attempt).toInt()));

  @override
  Future<void> connect() async {
    if (_disposed) return;
    _status.add(
      _attempt == 0 ? LinkStatus.connecting : LinkStatus.reconnecting,
    );
    try {
      final channel = _channel = _factory(uri);
      await channel.ready;
      _attempt = 0;
      _status.add(LinkStatus.connected);
      _sub = channel.stream.listen(
        (data) {
          if (data is! String) return;
          final decoded = TelemetryCodec.decode(data);
          if (decoded.isNotEmpty) _readings.add(decoded);
        },
        onDone: _scheduleReconnect,
        onError: (_) => _scheduleReconnect(),
        cancelOnError: true,
      );
    } catch (_) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    _sub?.cancel();
    _status.add(LinkStatus.reconnecting);
    _retryTimer?.cancel();
    _retryTimer = Timer(retryDelay(_attempt++), connect);
  }

  @override
  Future<void> sendCommand(String deviceId, String command) async => _channel
      ?.sink
      .add(jsonEncode({'deviceId': deviceId, 'command': command}));

  @override
  Future<void> dispose() async {
    _disposed = true;
    _retryTimer?.cancel();
    await _sub?.cancel();
    await _channel?.sink.close();
    await _readings.close();
    await _status.close();
  }
}
