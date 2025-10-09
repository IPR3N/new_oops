import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:new_oppsfarm/pages/auth/services/auth_service.dart';

class ProjectChatService {
  static final ProjectChatService _instance = ProjectChatService._internal();
  factory ProjectChatService() => _instance;
  ProjectChatService._internal();

  IO.Socket? socket;
  final String baseUrl = 'http://localhost:3000/oopsfarm/api';
  final String socketUrl = 'http://localhost:3000';
  final AuthService _authService = AuthService();

  Future<void> initSocket(int userId, int projectId,
      Function(Map<String, dynamic>) onMessageReceived) async {
    final token = await _authService.readToken();
    if (token == null) {
      print('Erreur : Aucun jeton trouvé');
      throw Exception('Aucun jeton trouvé');
    }

    socket = IO.io(
      socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setQuery({
            'userId': userId.toString(),
            'projectId': projectId.toString(),
          })
          .setAuth({'token': token})
          .setPath('/socket.io/')
          .build(),
    );

    socket!.connect();

    socket!.onConnect((_) {
      print('Connecté au WebSocket');
      socket!.emit('joinConversation', {'projectId': projectId.toString()});
      print('Rejoint la salle du projet : project-$projectId');
    });

    socket!.on('previousMessages', (data) {
      print('Raw previousMessages: $data');
      try {
        final List<dynamic> dataList;
        if (data is String) {
          dataList = jsonDecode(data) as List<dynamic>;
        } else if (data is List) {
          dataList = data;
        } else {
          print('Format inattendu pour previousMessages: $data');
          return;
        }
        print('Nombre d\'éléments dans previousMessages: ${dataList.length}');
        final messages = dataList
            .where((item) => item != null)
            .map((json) {
              final jsonData = json is Map<String, dynamic>
                  ? json
                  : jsonDecode(json.toString()) as Map<String, dynamic>;
              // Filtre content vide
              if ((jsonData['content'] as String?)?.trim().isEmpty ?? true) {
                print('Message ignoré (content vide): $jsonData');
                return null;
              }
              return jsonData;
            })
            .where((msg) => msg != null)
            .toList();
        print('Messages parsés (sans model): ${messages.length}');
        for (var message in messages) {
          onMessageReceived(message as Map<String, dynamic>);
        }
      } catch (e) {
        print('Erreur parsing previousMessages: $e');
      }
    });

    socket!.on('newMessage', (data) {
      print('Raw newMessage: $data');
      try {
        if (data == null) {
          print('newMessage null ignoré');
          return;
        }
        final json = data is String ? jsonDecode(data) : data;
        if (json is! Map<String, dynamic>) {
          print('Format inattendu pour newMessage: $data');
          return;
        }
        // Filtre content vide
        if ((json['content'] as String?)?.trim().isEmpty ?? true) {
          print('Nouveau message ignoré (content vide): $json');
          return;
        }
        onMessageReceived(json);
      } catch (e) {
        print('Erreur parsing newMessage: $e');
      }
    });

    socket!.on('error', (data) => print('Erreur serveur WebSocket: $data'));
    socket!.onConnectError(
        (error) => print('Erreur de connexion WebSocket: $error'));
    socket!.onDisconnect((_) => print('Déconnecté du WebSocket'));
  }

  void sendMessage(int userId, int projectId, String content) {
    if (socket == null || !socket!.connected) {
      print('WebSocket non connecté, tentative via HTTP');
      sendMessageHttp(userId, projectId, content).catchError((e) {
        print('Échec de l\'envoi HTTP: $e');
      });
      return;
    }

    final message = {'projectId': projectId, 'content': content};
    print('Envoi du message via WebSocket : $message');
    socket!.emit('sendMessage', message);
  }

  Future<Map<String, dynamic>> sendMessageHttp(
      int userId, int projectId, String content) async {
    final token = await _authService.readToken();
    if (token == null) throw Exception('Aucun jeton trouvé');

    final body = jsonEncode({'projectId': projectId, 'content': content});
    print('Envoi de la requête POST HTTP : $body');

    final response = await http.post(
      Uri.parse('$baseUrl/project-messages'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    print('Réponse API : ${response.statusCode} - ${response.body}');

    if (response.statusCode == 201 || response.statusCode == 200) {
      try {
        if (response.body.isEmpty) {
          print('Réponse API vide');
          throw Exception('Réponse API vide');
        }
        final json = jsonDecode(response.body);
        if (json == null || json is! Map<String, dynamic>) {
          print('JSON décodé invalide: $json');
          throw Exception('Réponse API invalide: ${response.body}');
        }
        // Filtre content vide (au cas où)
        if ((json['content'] as String?)?.trim().isEmpty ?? true) {
          print('Nouveau message ignoré (content vide): $json');
          throw Exception('Message vide non autorisé');
        }
        return json;
      } catch (e) {
        print('Erreur de parsing JSON : $e');
        print('Données brutes: ${response.body}');
        throw Exception('Erreur de parsing JSON: $e');
      }
    } else {
      print(
          'Échec de l\'envoi du message : ${response.statusCode} - ${response.body}');
      throw Exception(
          'Échec de l\'envoi du message : ${response.statusCode} - ${response.body}');
    }
  }

  Future<List<Map<String, dynamic>>> getProjectMessages(int projectId) async {
    final token = await _authService.readToken();
    if (token == null) throw Exception('Aucun jeton trouvé');

    print('Envoi de la requête GET pour les messages du projet $projectId');
    final response = await http.get(
      Uri.parse('$baseUrl/project-messages/project/$projectId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print(
        'Réponse des messages du projet : ${response.statusCode} - ${response.body}');

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        if (data is! List) {
          print('Format inattendu pour les messages: $data');
          throw Exception('Réponse API attendue sous forme de liste');
        }
        final validData = data
            .where((item) => item != null)
            .cast<Map<String, dynamic>>()
            .where((json) =>
                (json['content'] as String?)?.trim().isNotEmpty ?? false)
            .toList();
        print(
            'Nombre d\'éléments valides après filtre (sans vide): ${validData.length}');
        return validData;
      } catch (e) {
        print('Erreur parsing messages: $e');
        print('Données brutes: ${response.body}');
        return []; // Retourne vide au lieu de rethrow pour éviter crash
      }
    } else if (response.statusCode == 404) {
      print('Aucun message trouvé pour le projet $projectId');
      return [];
    } else {
      throw Exception(
          'Échec du chargement des messages : ${response.statusCode} - ${response.body}');
    }
  }

  void dispose() {
    socket?.disconnect();
    socket?.dispose();
    socket = null;
  }
}
