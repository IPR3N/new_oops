import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:new_oppsfarm/maessages/services/model.dart';
import 'package:new_oppsfarm/pages/auth/services/auth_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  IO.Socket? socket;
  final String baseUrl = 'http://localhost:3000/oopsfarm/api';
  final String socketUrl = 'http://localhost:3000';

  // final String baseUrl =
  //     'https://oopsfarmback-b3823d9a75eb.herokuapp.com/oopsfarm/api';
  // final String socketUrl = 'https://oopsfarmback-b3823d9a75eb.herokuapp.com';
  final AuthService _authService = AuthService();

  void initSocket(int userId, Function(Message) onMessageReceived) {
    socket = IO.io(socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket!.connect();
    socket!.onConnect((_) {
      print('Connecté au WebSocket');
      socket!.emit('joinConversation', userId);
    });

    socket!.on('receiveMessage', (data) {
      print('Message reçu : $data');
      final message = Message.fromJson(data);
      onMessageReceived(message);
    });

    socket!.onDisconnect((_) => print('Déconnecté du WebSocket'));
  }

  void sendMessage(int senderId, int receiverId, String content) {
    socket!.emit('sendMessage', {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
    });
  }

  Future<Message> sendMessageHttp(
      int senderId, int receiverId, String content) async {
    final token = await _authService.readToken();
    if (token == null) throw Exception('Aucun jeton trouvé');

    final body = jsonEncode({
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
    });
    print('Envoi de la requête POST avec : $body');

    final response = await http.post(
      Uri.parse('$baseUrl/messages/message'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    print('Réponse API : ${response.statusCode} - ${response.body}');

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Message.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
          'Échec de l\'envoi du message : ${response.statusCode} - ${response.body}');
    }
  }

  // Future<Message> sendMessageHttp(
  //     int senderId, int receiverId, String content) async {
  //   final token = await _authService.readToken();
  //   if (token == null) throw Exception('Aucun jeton trouvé');

  //   final response = await http.post(
  //     Uri.parse('$baseUrl/messages/message'),
  //     headers: {
  //       'Authorization': 'Bearer $token',
  //       'Content-Type': 'application/json',
  //     },
  //     body: jsonEncode({
  //       'senderId': senderId,
  //       'receiverId': receiverId,
  //       'content': content,
  //     }),
  //   );

  //   if (response.statusCode == 201 || response.statusCode == 200) {
  //     return Message.fromJson(jsonDecode(response.body));
  //   } else {
  //     throw Exception(
  //         'Échec de l\'envoi du message : ${response.statusCode} - ${response.body}');
  //   }
  // }

  Future<List<Message>> getConversation(
      int currentUserId, int otherUserId) async {
    final token = await _authService.readToken();
    if (token == null) throw Exception('Aucun jeton trouvé');

    final response = await http.get(
      Uri.parse('$baseUrl/messages/conversation/$otherUserId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Message.fromJson(json)).toList();
    } else if (response.statusCode == 404) {
      return []; // Conversation inexistante
    } else {
      throw Exception(
          'Échec du chargement de la conversation : ${response.statusCode} - ${response.body}');
    }
  }

  Future<List<Conversation>> getConversations() async {
    final token = await _authService.readToken();
    if (token == null) throw Exception('Aucun jeton trouvé');

    final response = await http.get(
      Uri.parse('$baseUrl/messages/conversations'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    print(
        'Réponse des conversations : ${response.statusCode} ${response.body}');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Conversation.fromJson(json)).toList();
    } else {
      throw Exception(
          'Échec du chargement des conversations : ${response.statusCode} - ${response.body}');
    }
  }

  Future<List<User>> getAvailableUsers() async {
    final token = await _authService.readToken();
    if (token == null) throw Exception('Aucun jeton trouvé');

    final response = await http.get(
      Uri.parse('$baseUrl/users'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception(
          'Échec du chargement des utilisateurs : ${response.statusCode} - ${response.body}');
    }
  }

  void dispose() {
    socket?.disconnect();
    socket?.dispose();
  }
}
