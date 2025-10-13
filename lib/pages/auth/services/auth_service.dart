import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:new_oppsfarm/pages/auth/restaure_password.dart';

// const String apiUrl = 'http://167.99.121.244/oopsfarm/api/authentication';
const String apiUrl =
    'https://oopsfarmback-b3823d9a75eb.herokuapp.com/oopsfarm/api/authentication';

// const String apiUrl =
//     'https://ipren-backend-4ece0558c6a1.herokuapp.com/oopsfarm/api/authentication';

class AuthService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Map<String, dynamic>? decodedToken;

  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  Future<String?> readToken() async {
    try {
      String? token = await _secureStorage.read(key: "auth_token");
      if (token != null) {
        return token;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: 'auth_token');
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/sign-in'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String token = data['accessToken'];

        // Stocker le token de manière sécurisée
        await _secureStorage.write(key: 'auth_token', value: token);

        return {'success': true, 'token': token};
      } else {
        print('Erreur serveur (${response.statusCode}): ${response.body}');
        return {
          'success': false,
          'message':
              json.decode(response.body)['message'] ?? 'Une erreur est survenue'
        };
      }
    } catch (e) {
      print('Erreur de connexion: $e');
      return {'success': false, 'message': 'Problème de connexion'};
    }
  }

  // Future<bool> login({
  //   required String email,
  //   required String password,
  // }) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse('$apiUrl/sign-in'),
  //       headers: {'Content-Type': 'application/json'},
  //       body: json.encode({
  //         'email': email,
  //         'password': password,
  //       }),
  //     );

  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       final String token = data['accessToken'];

  //       await _secureStorage.write(key: 'auth_token', value: token);

  //       return true;
  //     } else {
  //       // print('Erreur: ${response.body}');
  //       return false;
  //     }
  //   } catch (e) {
  //     // print('Erreur de connexion: $e');
  //     return false;
  //   }
  // }

  Future<bool> signUp({
    required String nom,
    required String prenom,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/sign-up'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nom': nom,
          'prenom': prenom,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Si le status code est 201, c'est un nouveau utilisateur qui a été créé
        // Si le status code est 200, c'est un utilisateur existant qui a été connecté

        // final data = json.decode(response.body);
        // final String token = data['accessToken'];

        // await _secureStorage.write(key: 'auth_token', value: token);

        return true;
      } else {
        // print('Erreur: ${response.body}');
        return false;
      }
    } catch (e) {
      // print('Erreur de connexion: $e');
      return false;
    }
  }

  Future<bool> verfyCode({
    required String nom,
    required String prenom,
    required String email,
    required String code,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/verify-code'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'code': code,
          'nom': nom,
          'prenom': prenom,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        // print('Erreur: ${response.body}');
        return false;
      }
    } catch (e) {
      // print('Erreur de connexion: $e');
      return false;
    }
  }

  Future<bool> regenerateCode({required String email}) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/regenerate-code'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
        }),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        // print('Erreur: ${response.body}');
        return false;
      }
    } catch (e) {
      //  print('Erreur de connexion: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> checkEmail({required String email}) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/check-mail'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = json.decode(response.body);
        return {
          'success': true,
          'message': responseBody['message'],
          'user': responseBody['user']
        };
      } else {
        final responseBody = json.decode(response.body);
        print('Erreur: ${responseBody['message']}');
        return {'success': false, 'message': responseBody['message']};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> verifyCodeAndEmail({
    required String email,
    required String code,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/verify-email-and-code'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'code': code,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = json.decode(response.body);
        return {
          'success': true,
          'message': responseBody['message'],
          'user': responseBody['user']
        };
      } else {
        final responseBody = json.decode(response.body);
        print('Erreur: ${responseBody['message']}');
        return {'success': false, 'message': responseBody['message']};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> restaurePassword({
    required String email,
    required newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'newPassword': newPassword,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = json.decode(response.body);
        return {
          'success': true,
          'message': responseBody['message'],
          // 'user': responseBody['user']
        };
      } else {
        final responseBody = json.decode(response.body);
        print('Erreur: ${responseBody['message']}');
        return {'success': false, 'message': responseBody['message']};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Nouvelle méthode pour récupérer l'ID utilisateur à partir du token
  Future<String?> getUserId() async {
    try {
      final String? token = await getToken();
      if (token != null) {
        final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        // Supposons que l'ID utilisateur est dans le champ 'sub' ou 'userId' du token
        return decodedToken['sub']?.toString() ??
            decodedToken['userId']?.toString();
      }
      return null;
    } catch (e) {
      print('Erreur lors du décodage du token: $e');
      return null;
    }
  }
}
