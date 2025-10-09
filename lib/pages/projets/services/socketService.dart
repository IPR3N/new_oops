import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  void connect({
    required String serverUrl,
    required int userId,
    required int projectId,
    required Function(dynamic) onPreviousMessages,
    required Function(dynamic) onNewMessage,
    required Function(dynamic) onUserTyping,
    required Function(dynamic) onError,
    Function()? onConnect,
    Function()? onDisconnect,
  }) {
    if (_socket?.connected ?? false) {
      print('⚠️ Socket déjà connecté');
      return;
    }

    _socket = IO.io(
      serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(1000)
          .setExtraHeaders({
            'userId': userId.toString(),
            'projectId': projectId.toString(),
          })
          .setQuery({
            'userId': userId.toString(),
            'projectId': projectId.toString(),
          })
          .build(),
    );

    _socket!.onConnect((_) {
      print('✅ Socket connecté');
      _isConnected = true;
      onConnect?.call();
    });

    _socket!.onDisconnect((_) {
      print('❌ Socket déconnecté');
      _isConnected = false;
      onDisconnect?.call();
    });

    _socket!.on('previousMessages', onPreviousMessages);
    _socket!.on('newMessage', onNewMessage);
    _socket!.on('userTyping', onUserTyping);
    _socket!.on('error', onError);

    _socket!.onConnectError((data) {
      print('❌ Erreur de connexion: $data');
      onError(data);
    });

    _socket!.connect();
  }

  void sendMessage({
    required int projectId,
    required String content,
  }) {
    if (!_isConnected || _socket == null) {
      print('⚠️ Socket non connecté');
      return;
    }

    _socket!.emit('sendMessage', {
      'projectId': projectId,
      'content': content,
    });
  }

  void sendTyping({
    required int projectId,
    required bool isTyping,
  }) {
    if (!_isConnected || _socket == null) return;

    _socket!.emit('typing', {
      'projectId': projectId,
      'isTyping': isTyping,
    });
  }

  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _isConnected = false;
    }
  }

  void dispose() {
    disconnect();
  }
}
