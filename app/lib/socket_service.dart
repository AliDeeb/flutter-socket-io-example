import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  SocketService._internal();
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;

  IO.Socket? socket;
  final uri = 'http://10.0.2.2:3000';
  Function(dynamic data)? onJoinSession;
  Function(dynamic data)? onHomeWidgetsReceived;

  void connectAndListen() {
    debugPrint('trying to connect to $uri');

    socket ??= IO.io(
      uri,
      IO.OptionBuilder().setTransports(['websocket']).build(),
    );

    try {
      socket!.onConnect((_) => debugPrint("Connected to Socket $uri"));
      socket!.onError((data) => debugPrint(data.toString()));
      socket!.on('session-join', (data) => onJoinSession?.call(data));
      socket!.on('home-widgets', (data) => onHomeWidgetsReceived?.call(data));
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void joinSession(String userId) {
    socket?.emit('user-join', userId);
  }

  void dispose() {
    if (socket != null) {
      socket!.disconnect();
      socket = null;
    }
  }
}
