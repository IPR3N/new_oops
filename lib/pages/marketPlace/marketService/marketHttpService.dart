import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const String apiUrl = 'http://localhost:3000/oopsfarm/api';
// const String apiUrl =
//     'https://oopsfarmback-b3823d9a75eb.herokuapp.com/oopsfarm/api';
// const String apiUrl =
//     'https://ipren-backend-4ece0558c6a1.herokuapp.com/oopsfarm/api';

class MarketHttpService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<String?> token() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  Future<List<dynamic>> getMarketItems() async {
    final token = await this.token();
    final response = await http.get(
      Uri.parse('$apiUrl/marketplace'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load market items');
    }
  }

  Future<Map<String, dynamic>> getMarketItemById(int id) async {
    final token = await this.token();
    final response = await http.get(
      Uri.parse('$apiUrl/marketplace/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load market item');
    }
  }

  // Future<bool> addMarketItem(int projectId) async {
  //   final item = {
  //     'projectId': projectId,
  //   };

  Future<bool> addMarketItem(int projectId, {int? quantity}) async {
    final item = {
      'projectId': projectId,
      if (quantity != null) 'quantity': quantity, // Quantity est optionnel
    };

    try {
      // print('item: $item');
      final authToken = await token();
      final response = await http.post(
        Uri.parse('$apiUrl/marketplace/'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $authToken',
          'Content-Type': 'application/json'
        },
        body: json.encode(item),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // print('Response body: ${response.body}');
        return true;
      } else {
        print('Failed to add market item: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception: $e');
      return false;
    }
  }

  Future<void> updateMarketItem(int id, Map<String, dynamic> item) async {
    final authToken = await token();
    final response = await http.put(
      Uri.parse('$apiUrl/marketplace/$id'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $authToken',
        'Content-Type': 'application/json'
      },
      body: json.encode(item),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update market item');
    }
  }

  Future<void> deleteMarketItem(int id) async {
    final authToken = await token();
    final response = await http.delete(
      Uri.parse('$apiUrl/marketplace/$id'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $authToken',
        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete market item');
    }
  }

  Future<bool> createSellerNeed({
    required int productId,
    required int quantity,
  }) async {
    final item = {
      'produictId': productId, // Match the backend field name from the entity
      'quantity': quantity,
    };

    try {
      final authToken = await token();
      final response = await http.post(
        Uri.parse('$apiUrl/seller-need'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(item),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('Failed to create seller need: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception in createSellerNeed: $e');
      return false;
    }
  }

  Future<List<dynamic>> getSellerNeeds() async {
    final token = await this.token();
    final response = await http.get(
      Uri.parse('$apiUrl/seller-need'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load seller needs');
    }
  }
}
