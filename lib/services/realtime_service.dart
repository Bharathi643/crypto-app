import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class RealtimeService {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  final _controller = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get stream => _controller.stream;
  bool connected = false;

  void connect() {
    close();
    final url = dotenv.env['WS_URL'] ?? 'ws://localhost:5000/ws';
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _subscription = _channel!.stream.listen(
        (message) {
          connected = true;
          try {
            final decoded = jsonDecode(message.toString());
            if (decoded is Map<String, dynamic>) _controller.add(decoded);
          } catch (_) {}
        },
        onError: (_) {
          connected = false;
          _controller.add({'type': 'connection', 'status': 'disconnected'});
          _reconnect();
        },
        onDone: () {
          connected = false;
          _controller.add({'type': 'connection', 'status': 'disconnected'});
          _reconnect();
        },
      );
    } catch (_) {
      connected = false;
      _reconnect();
    }
  }

  Timer? _timer;
  void _reconnect() {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 3), connect);
  }

  void close() {
    _timer?.cancel();
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close();
    _channel = null;
    connected = false;
  }

  void dispose() {
    close();
    _controller.close();
  }
}
