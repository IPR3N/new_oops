// class Message {
//   final int id;
//   final String content;
//   final int senderId;
//   final int receiverId;
//   final String? senderName;
//   final String? receiverName;
//   final DateTime createdAt;

//   Message({
//     required this.id,
//     required this.content,
//     required this.senderId,
//     required this.receiverId,
//     this.senderName,
//     this.receiverName,
//     required this.createdAt,
//   });

//   factory Message.fromJson(Map<String, dynamic> json) {
//     return Message(
//       id: json['id'],
//       content: json['content'] as String,
//       senderId: (json['sender']['id'] as int),
//       receiverId: (json['receiver']['id'] as int),
//       senderName: json['sender']['username'] as String?,
//       receiverName: json['receiver']['username'] as String?,
//       createdAt: DateTime.parse(json['createdAt'] as String),
//     );
//   }
// }

// class Conversation {
//   final int otherUserId;
//   final String otherUserName;
//   final String lastMessage;
//   final DateTime lastMessageTime;

//   Conversation({
//     required this.otherUserId,
//     required this.otherUserName,
//     required this.lastMessage,
//     required this.lastMessageTime,
//   });

//   factory Conversation.fromJson(Map<String, dynamic> json) {
//     return Conversation(
//       otherUserId: (json['otherUserId'] as int),
//       otherUserName: json['otherUserName'] as String,
//       lastMessage: json['lastMessage'] as String,
//       lastMessageTime: DateTime.parse(json['lastMessageTime'] as String),
//     );
//   }
// }

// class User {
//   final int id;
//   final String username;

//   User({required this.id, required this.username});

//   factory User.fromJson(Map<String, dynamic> json) {
//     return User(
//       id: (json['id'] as int),
//       username: json['username'] as String,
//     );
//   }
// }
class Message {
  final int id;
  final String content;
  final int senderId;
  final int receiverId;
  final String? senderName;
  final String? receiverName;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.content,
    required this.senderId,
    required this.receiverId,
    this.senderName,
    this.receiverName,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] is String ? int.parse(json['id']) : json['id'] as int,
      content: json['content'] as String,
      senderId: json.containsKey('senderId')
          ? (json['senderId'] is String
              ? int.parse(json['senderId'])
              : json['senderId'] as int)
          : (json['sender']['id'] is String
              ? int.parse(json['sender']['id'])
              : json['sender']['id'] as int),
      receiverId: json.containsKey('receiverId')
          ? (json['receiverId'] is String
              ? int.parse(json['receiverId'])
              : json['receiverId'] as int)
          : (json['receiver']['id'] is String
              ? int.parse(json['receiver']['id'])
              : json['receiver']['id'] as int),
      senderName: json.containsKey('sender')
          ? json['sender']['username'] as String?
          : null,
      receiverName: json.containsKey('receiver')
          ? json['receiver']['username'] as String?
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  String toString() {
    return 'Message(id: $id, content: $content, senderId: $senderId, receiverId: $receiverId, createdAt: $createdAt)';
  }
}

class Conversation {
  final int otherUserId;
  final String otherUserName;
  final String lastMessage;
  final DateTime lastMessageTime;

  Conversation({
    required this.otherUserId,
    required this.otherUserName,
    required this.lastMessage,
    required this.lastMessageTime,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      otherUserId: json['otherUserId'] is String
          ? int.parse(json['otherUserId'])
          : json['otherUserId'] as int,
      otherUserName: json['otherUserName'] as String,
      lastMessage: json['lastMessage'] as String,
      lastMessageTime: DateTime.parse(json['lastMessageTime'] as String),
    );
  }

  @override
  String toString() {
    return 'Conversation(otherUserId: $otherUserId, otherUserName: $otherUserName, lastMessage: $lastMessage, lastMessageTime: $lastMessageTime)';
  }
}

class User {
  final int id;
  final String username;

  User({required this.id, required this.username});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is String ? int.parse(json['id']) : json['id'] as int,
      username: json['username'] as String,
    );
  }
}
