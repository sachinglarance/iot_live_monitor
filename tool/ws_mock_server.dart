// Local WebSocket server that streams fake telemetry, for the app's
// "WebSocket server" mode.
//
//   dart run tool/ws_mock_server.dart
//   Android emulator URL: ws://10.0.2.2:8080   iOS simulator: ws://localhost:8080
import 'dart:async';
import 'dart:io';

import 'package:iot_live_monitor/data/simulator/telemetry_generator.dart';
import 'package:iot_live_monitor/domain/telemetry_codec.dart';

Future<void> main() async {
  final server = await HttpServer.bind(InternetAddress.anyIPv4, 8080);
  stdout.writeln('WebSocket mock server on ws://0.0.0.0:8080');

  await for (final request in server) {
    if (!WebSocketTransformer.isUpgradeRequest(request)) {
      request.response
        ..statusCode = HttpStatus.badRequest
        ..close();
      continue;
    }
    final socket = await WebSocketTransformer.upgrade(request);
    stdout.writeln('Client connected');
    final gen = TelemetryGenerator();
    final timer = Timer.periodic(const Duration(seconds: 1), (_) {
      for (final id in gen.deviceIds) {
        socket.add(TelemetryCodec.encode(id, DateTime.now(), gen.next(id)));
      }
    });
    socket.listen(
      (cmd) => stdout.writeln('⇠ $cmd'),
      onDone: () {
        timer.cancel();
        stdout.writeln('Client disconnected');
      },
    );
  }
}
