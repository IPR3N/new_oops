import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:new_oppsfarm/notification_page/services/notification_sse_model.dart';

class NotificationClient {
  // final String baseUrl = 'http://167.99.121.244/oopsfarm/api/notifications';
  final String baseUrl = 'http://localhost:3000/oopsfarm/api/notifications';
  // final String baseUrl =
  //     'https://ipren-backend-4ece0558c6a1.herokuapp.com/oopsfarm/api/notifications';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<String?> token() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  Future<List<NotificationModel>> fetchNotifications(int userId) async {
    final authToken = await token();
    if (authToken == null) {
      throw Exception('Aucun token trouvé, veuillez vous connecter');
    }

    final response = await http.get(
      Uri.parse('$baseUrl?userId=$userId'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      final List<dynamic> data = jsonResponse['notifications'] ?? [];
      return data.map((json) => NotificationModel.fromJson(json)).toList();
    } else {
      throw Exception(
          'Erreur lors de la récupération des notifications: ${response.statusCode}');
    }
  }

  Stream<NotificationModel> streamNotifications(int userId) async* {
    final authToken = await token();
    if (authToken == null) {
      throw Exception('Aucun token trouvé, veuillez vous connecter');
    }

    final request =
        http.Request('GET', Uri.parse('$baseUrl/sse?userId=$userId'));
    request.headers[HttpHeaders.authorizationHeader] = 'Bearer $authToken';
    request.headers['Accept'] = 'text/event-stream';
    request.headers['Cache-Control'] = 'no-cache';

    final client = http.Client();
    final response = await client.send(request);

    if (response.statusCode != 200) {
      client.close();
      throw Exception('Erreur de connexion SSE: ${response.statusCode}');
    }

    await for (final data in response.stream.transform(utf8.decoder)) {
      if (data.startsWith('data: ')) {
        try {
          final jsonData = data.substring(6).trim();
          print('SSE Data reçue : $jsonData');
          final parsedData = jsonDecode(jsonData);
          yield NotificationModel(
            id: parsedData['id'] as int?,
            message: parsedData['message'] as String? ?? 'Message inconnu',
            createdAt: DateTime.parse(
                parsedData['createdAt'] ?? DateTime.now().toIso8601String()),
            isRead: parsedData['isRead'] as bool? ?? false,
          );
        } catch (e) {
          print('Erreur lors du parsing SSE: $e');
          continue;
        }
      }
    }
    client.close();
    print('Stream SSE terminé');
  }

  Future<void> markAsRead(int? notificationId, int userId) async {
    final authToken = await token();
    if (authToken == null || notificationId == null) {
      throw Exception('Token ou ID de notification manquant');
    }

    final response = await http.patch(
      Uri.parse('$baseUrl/$notificationId/read?userId=$userId'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Erreur lors de la mise à jour de la notification: ${response.statusCode}');
    }
  }
}
