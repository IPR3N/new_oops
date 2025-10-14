import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
// import 'package:new_oppsfarm/messagerie/services/chat_settings_service.dart';
import 'dart:convert';
import 'dart:io';

// const String apiUrl = 'http://localhost:3000/oopsfarm/api';

const String apiUrl =
    'https://oopsfarmback-b3823d9a75eb.herokuapp.com/oopsfarm/api';

class ProfileHttpService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  // final SettingsService _settingsService = SettingsService();

  // Helper method to get auth token
  Future<String?> _getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  // Get user profile
  Future<String?> getProfile() async {
    final authToken = await _getToken();
    if (authToken == null) throw Exception('No authentication token found');

    final response = await http.get(
      Uri.parse('$apiUrl/profile'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(
          'Failed to load profile: ${response.statusCode} - ${response.body}');
    }
  }

  // Create a new profile
  Future<String> createProfile({
    required int user,
    required String bio,
    String? location,
    required String username,
    required String dob,
    String? photoProfile,
    String? photoCouverture,
  }) async {
    final authToken = await _getToken();
    if (authToken == null) throw Exception('No authentication token found');

    final response = await http.post(
      Uri.parse('$apiUrl/profile'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'user': user,
        'bio': bio,
        'location': location,
        'username': username,
        'dob': dob,
        'photoProfile': photoProfile,
        'photoCouverture': photoCouverture,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return 'Profile created';
    } else {
      throw Exception(
          'Failed to create profile: ${response.statusCode} - ${response.body}');
    }
  }

  // Update an existing profile
  Future<String> updateProfile({
    required int id,
    required String bio,
    String? location,
    required String username,
    required String dob,
    String? photoProfile,
    String? photoCouverture,
    required int user,
  }) async {
    final authToken = await _getToken();
    if (authToken == null) throw Exception('No authentication token found');

    final response = await http.put(
      Uri.parse('$apiUrl/profile/$id'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'bio': bio,
        'location': location,
        'username': username,
        'dob': dob,
        'photoProfile': photoProfile,
        'photoCouverture': photoCouverture,
        'user': user,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return 'Profile updated';
    } else {
      throw Exception(
          'Failed to update profile: ${response.statusCode} - ${response.body}');
    }
  }

  // Upload an image
  Future<String?> uploadImage(File imageFile) async {
    final authToken = await _getToken();
    if (authToken == null) throw Exception('No authentication token found');

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$apiUrl/profile/upload'),
    );

    request.headers[HttpHeaders.authorizationHeader] = 'Bearer $authToken';
    request.files
        .add(await http.MultipartFile.fromPath('image', imageFile.path));

    final response = await request.send();
    final responseData = await response.stream.bytesToString();

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = json.decode(responseData);
      return jsonResponse['imageUrl'] as String?;
    } else {
      throw Exception(
          'Failed to upload image: ${response.statusCode} - $responseData');
    }
  }

  // Send a friend request
  Future<String> sendFriendRequest({
    required int requesterId,
    required int receiverId,
  }) async {
    final authToken = await _getToken();
    if (authToken == null) throw Exception('No authentication token found');

    final response = await http.post(
      Uri.parse('$apiUrl/frienship/send'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'requesterId': requesterId,
        'receiverId': receiverId,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return 'Friend request sent successfully';
    } else {
      throw Exception(
          'Failed to send friend request: ${response.statusCode} - ${response.body}');
    }
  }

  // Accept a friend request
  Future<String> acceptFriendRequest({
    required int requesterId,
    required int receiverId,
  }) async {
    final authToken = await _getToken();
    if (authToken == null) throw Exception('No authentication token found');

    final response = await http.post(
      Uri.parse('$apiUrl/frienship/accept'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'requesterId': requesterId,
        'receiverId': receiverId,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return 'Friend request accepted';
    } else {
      throw Exception(
          'Failed to accept friend request: ${response.statusCode} - ${response.body}');
    }
  }

  // Decline a friend request
  Future<String> declineFriendRequest({
    required int requesterId,
    required int receiverId,
  }) async {
    final authToken = await _getToken();
    if (authToken == null) throw Exception('No authentication token found');

    final response = await http.post(
      Uri.parse('$apiUrl/frienship/decline'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'requesterId': requesterId,
        'receiverId': receiverId,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return 'Friend request declined';
    } else {
      throw Exception(
          'Failed to decline friend request: ${response.statusCode} - ${response.body}');
    }
  }

  // Get list of friends
  Future<String> getFriends({required int userId}) async {
    final authToken = await _getToken();
    if (authToken == null) throw Exception('No authentication token found');

    final response = await http.get(
      Uri.parse('$apiUrl/frienship/friends/$userId'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(
          'Failed to load friends: ${response.statusCode} - ${response.body}');
    }
  }

  // Get friend suggestions
  Future<String> suggestFriends({required int userId}) async {
    final authToken = await _getToken();
    if (authToken == null) throw Exception('No authentication token found');

    final response = await http.get(
      Uri.parse('$apiUrl/frienship/suggestions/$userId'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(
          'Failed to load friend suggestions: ${response.statusCode} - ${response.body}');
    }
  }

  // Get outgoing friend requests
  Future<Map<String, dynamic>> getOutgoingFriendRequests(int userId) async {
    final authToken = await _getToken();
    if (authToken == null) throw Exception('No authentication token found');

    final response = await http.get(
      Uri.parse('$apiUrl/frienship/outgoing?userId=$userId&status=all'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
          'Failed to load outgoing friend requests: ${response.statusCode} - ${response.body}');
    }
  }

  // Get incoming friend requests
  Future<Map<String, dynamic>> getIncomingFriendRequests(int userId) async {
    final authToken = await _getToken();
    if (authToken == null) throw Exception('No authentication token found');

    final response = await http.get(
      Uri.parse('$apiUrl/frienship/incoming?userId=$userId&status=pending'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
          'Failed to load incoming friend requests: ${response.statusCode} - ${response.body}');
    }
  }

  // Cancel a friend request
  Future<void> cancelFriendRequest(int requesterId, int receiverId) async {
    final authToken = await _getToken();
    if (authToken == null) throw Exception('No authentication token found');

    final response = await http.post(
      Uri.parse('$apiUrl/frienship/cancel'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'requesterId': requesterId,
        'receiverId': receiverId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to cancel friend request: ${response.statusCode} - ${response.body}');
    }
  }

  // Get a specific user profile
  Future<String> getUserProfile(int userId) async {
    final authToken = await _getToken();
    if (authToken == null) throw Exception('No authentication token found');

    final response = await http.get(
      Uri.parse('$apiUrl/profile/$userId'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(
          'Failed to load user profile: ${response.statusCode} - ${response.body}');
    }
  }

  // Get messages between two users
  Future<String> getMessagesBetweenUsers(
      String userId, String receiverId) async {
    final authToken = await _getToken();
    if (authToken == null) throw Exception('No authentication token found');

    final response = await http.get(
      Uri.parse('$apiUrl/messages?senderId=$userId&receiverId=$receiverId'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(
          'Failed to load messages: ${response.statusCode} - ${response.body}');
    }
  }

  // Remove a friend
  Future<String> removeFriend({
    required int userId,
    required int friendId,
  }) async {
    final authToken = await _getToken();
    if (authToken == null) throw Exception('No authentication token found');

    final response = await http.post(
      Uri.parse('$apiUrl/frienship/remove'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'userId': userId,
        'friendId': friendId,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return 'Friend removed successfully';
    } else {
      throw Exception(
          'Failed to remove friend: ${response.statusCode} - ${response.body}');
    }
  }

  // Unfollow a user
  Future<String> unfollow({
    required int userId,
    required int followedId,
  }) async {
    final authToken = await _getToken();
    if (authToken == null) throw Exception('No authentication token found');

    final response = await http.post(
      Uri.parse('$apiUrl/frienship/unfollow'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'userId': userId,
        'followedId': followedId,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return 'Unfollowed successfully';
    } else {
      throw Exception(
          'Failed to unfollow: ${response.statusCode} - ${response.body}');
    }
  }




  // Get posts liked by a user
Future<String> getLikedPosts(int userId) async {
  final authToken = await _getToken();
  if (authToken == null) throw Exception('No authentication token found');

  final response = await http.get(
    Uri.parse('$apiUrl/oops/liked/$userId'),
    headers: {
      HttpHeaders.authorizationHeader: 'Bearer $authToken',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    return response.body;
  } else {
    throw Exception(
        'Failed to load liked posts: ${response.statusCode} - ${response.body}');
  }
}
}
