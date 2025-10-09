import 'package:flutter/foundation.dart';
import 'package:new_oppsfarm/pages/view/models/opps-model.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class WebSocketService {
  late IO.Socket socket;
  final Map<String, List<Function>> _eventListeners = {};
  final List<Function> _actionQueue = [];
  bool _isConnected = false;

  WebSocketService() {
    socket = IO.io(
      // 'http://localhost:3000'
      'https://oopsfarmback-b3823d9a75eb.herokuapp.com',
      <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false, // Prevent automatic connection until needed
      },
    );

    // Connection handling
    socket.onConnect((_) {
      _isConnected = true;
      if (kDebugMode) print('Connected to WebSocket');
      // Process any queued actions
      while (_actionQueue.isNotEmpty) {
        _actionQueue.removeAt(0)();
      }
    });

    socket.onConnectError((err) {
      _isConnected = false;
      if (kDebugMode) print('Connection Error: $err');
    });

    socket.onError((err) {
      if (kDebugMode) print('Socket Error: $err');
    });

    socket.onDisconnect((_) {
      _isConnected = false;
      if (kDebugMode) print('Disconnected from WebSocket');
    });

    // Event listeners
    socket.on('likeUpdated', (data) => _notifyListeners('likeUpdated', data));
    socket.on('commentAdded', (data) => _notifyListeners('commentAdded', data));
    socket.on('postShared', (data) => _notifyListeners('postShared', data));
    socket.on(
        'receive_message', (data) => _notifyListeners('receive_message', data));
    socket.on('message_delivered',
        (data) => _notifyListeners('message_delivered', data));
    socket.on('message_read', (data) => _notifyListeners('message_read', data));
    socket.on('user_list', (data) => _notifyListeners('user_list', data));
    socket.on('conversation_list',
        (data) => _notifyListeners('conversation_list', data));
    socket.on('typing', (data) => _notifyListeners('typing', data));

    // Initialize connection
    connect();
  }

  // Connect to the WebSocket server
  void connect() {
    if (!_isConnected) {
      socket.connect();
    }
  }

  // Check connection status
  bool get isConnected => _isConnected;

  // Add an event listener
  void addListener(String event, Function(dynamic) callback) {
    if (!_eventListeners.containsKey(event)) {
      _eventListeners[event] = [];
    }
    if (!_eventListeners[event]!.contains(callback)) {
      _eventListeners[event]!.add(callback);
    }
  }

  // Remove an event listener
  void removeListener(String event, Function callback) {
    _eventListeners[event]?.remove(callback);
    if (_eventListeners[event]?.isEmpty ?? false) {
      _eventListeners.remove(event);
    }
  }

  // Notify all listeners for an event
  void _notifyListeners(String event, dynamic data) {
    if (_eventListeners.containsKey(event)) {
      for (var callback in List.from(_eventListeners[event]!)) {
        try {
          callback(data);
        } catch (e) {
          if (kDebugMode) print('Error in listener for $event: $e');
        }
      }
    }
  }

  // Queue an action if not connected
  void _queueAction(Function action) {
    _actionQueue.add(action);
    if (kDebugMode) print('Action queued due to disconnection');
  }

  // Send a like update
  void sendLikeUpdate(int postId, int newLikesCount, List<int> likedBy) {
    if (_isConnected) {
      socket.emit('likeUpdated', {
        'postId': postId,
        'newLikesCount': newLikesCount,
        'likedBy': likedBy,
      });
      if (kDebugMode) {
        print(
            'Like sent via WebSocket: postId=$postId, likesCount=$newLikesCount, likedBy=$likedBy');
      }
    } else {
      _queueAction(() => sendLikeUpdate(postId, newLikesCount, likedBy));
    }
  }

  // Send a comment update
  void sendCommentUpdate(int postId, Comment newComment) {
    if (_isConnected) {
      socket.emit('commentAdded', {
        'postId': postId,
        'comment': newComment.toJson(),
      });
    } else {
      _queueAction(() => sendCommentUpdate(postId, newComment));
    }
  }

  // Send a share update
  void sendShareUpdate(int postId, int newShareCount) {
    if (_isConnected) {
      socket.emit('postShared', {
        'postId': postId,
        'newShareCount': newShareCount,
      });
    } else {
      _queueAction(() => sendShareUpdate(postId, newShareCount));
    }
  }

  // Connect a user
  void connectUser(String userId) {
    if (_isConnected) {
      socket.emit('connect_user', {'userId': userId});
    } else {
      _queueAction(() => connectUser(userId));
    }
  }

  // Request conversation list
  void requestConversationList(String userId) {
    if (_isConnected) {
      socket.emit('connect_user', {'userId': userId});
    } else {
      _queueAction(() => requestConversationList(userId));
    }
  }

  // Send a message
  void sendMessage(String userId, String? receiverId, String content) {
    if (_isConnected) {
      socket.emit('send_message', {
        'senderId': userId,
        'receiverId': receiverId,
        'content': content,
      });
    } else {
      _queueAction(() => sendMessage(userId, receiverId, content));
    }
  }

  // Mark a message as read
  void markMessageAsRead(String messageId) {
    if (_isConnected) {
      socket.emit('mark_as_read', {'messageId': messageId});
    } else {
      _queueAction(() => markMessageAsRead(messageId));
    }
  }

  // Edit a message
  void editMessage(String messageId, String newContent) {
    if (_isConnected) {
      socket.emit('edit_message', {
        'messageId': messageId,
        'newContent': newContent,
      });
    } else {
      _queueAction(() => editMessage(messageId, newContent));
    }
  }

  // Delete a message
  void deleteMessage(String messageId) {
    if (_isConnected) {
      socket.emit('delete_message', {'messageId': messageId});
    } else {
      _queueAction(() => deleteMessage(messageId));
    }
  }

  // Send typing indicator
  void sendTyping(String? userId, String? receiverId) {
    if (_isConnected) {
      socket.emit('typing', {
        'userId': userId,
        'receiverId': receiverId,
      });
    } else {
      _queueAction(() => sendTyping(userId, receiverId));
    }
  }

  // Clean up resources
  void dispose() {
    socket.disconnect();
    socket.dispose();
    _eventListeners.clear();
    _actionQueue.clear();
    _isConnected = false;
  }
}
