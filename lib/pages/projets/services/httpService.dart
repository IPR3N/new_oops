import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:new_oppsfarm/pages/marketPlace/models/product-model.dart';
import 'package:new_oppsfarm/pages/projets/services/models/project-model.dart';
import 'package:new_oppsfarm/pages/view/models/opps-model.dart';

// const String apiUrl = 'http://167.99.121.244//oopsfarm/api';

const String apiUrl = 'http://localhost:3000/oopsfarm/api';

// const String apiUrl =
//     'https://oopsfarmback-b3823d9a75eb.herokuapp.com/oopsfarm/api';

class HttpService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Helper method to get auth token
  Future<String?> _getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  // Project Section
  Future<List<Project>> getProjects() async {
    try {
      final authToken = await _getToken();
      if (authToken == null) throw Exception('No authentication token found');

      final response = await http.get(
        Uri.parse('$apiUrl/project'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Project.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to fetch projects: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      throw Exception('Network or internal error: $error');
    }
  }

  Future<List<ProjectModel>> getUserProject(int id) async {
    try {
      final authToken = await _getToken();
      if (authToken == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('$apiUrl/project/user/$id'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ProjectModel.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to fetch user projects: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      print('Error fetching user projects: $error');
      throw Exception('Network or internal error: $error');
    }
  }

  Future<String> createProject({
    String? nom,
    String? description,
    String? startDate,
    String? endDate,
    String? status,
    int? owner,
    int? cropId,
    int? cropVarietyId,
    String? memberShip,
    String? progress,
    String? estimatedQuantityProduced,
    String? basePrice,
  }) async {
    final body = {
      if (nom != null) 'nom': nom,
      if (description != null) 'description': description,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (status != null) 'status': status,
      if (owner != null) 'owner': owner,
      if (cropId != null) 'crop_id': cropId,
      if (cropVarietyId != null) 'cropVariety_id': cropVarietyId,
      if (memberShip != null) 'memberShip': memberShip,
      if (progress != null) 'progress': progress,
      if (estimatedQuantityProduced != null)
        'estimated_quantity_produced': estimatedQuantityProduced,
      if (basePrice != null) 'base_price': basePrice,
    };

    try {
      final authToken = await _getToken();
      if (authToken == null) throw Exception('No authentication token found');

      final response = await http.post(
        Uri.parse('$apiUrl/project'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return responseData['message'] ?? 'Project created successfully';
      } else {
        throw Exception(
            'Failed to create project: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      throw Exception('Network or internal error: $error');
    }
  }

  Future<String> updateProject({
    required String id,
    String? nom,
    String? description,
    String? startDate,
    String? endDate,
    String? status,
    String? owner,
    String? cropId,
    String? memberShip,
    String? estimatedQuantityProduced,
    String? basePrice,
  }) async {
    final body = {
      if (nom != null) 'nom': nom,
      if (description != null) 'description': description,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (status != null) 'status': status,
      if (owner != null) 'owner': owner,
      if (cropId != null) 'crop_id': cropId,
      if (memberShip != null) 'memberShip': memberShip,
      if (estimatedQuantityProduced != null)
        'estimated_quantity_produced': estimatedQuantityProduced,
      if (basePrice != null) 'base_price': basePrice,
    };

    try {
      final authToken = await _getToken();
      if (authToken == null) throw Exception('No authentication token found');

      final response = await http.put(
        Uri.parse('$apiUrl/project/$id'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['message'] ?? 'Project updated successfully';
      } else {
        throw Exception(
            'Failed to update project: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      throw Exception('Network or internal error: $error');
    }
  }

  Future<String> deleteProject(int id) async {
    try {
      final authToken = await _getToken();
      if (authToken == null) throw Exception('No authentication token found');

      final response = await http.delete(
        Uri.parse('$apiUrl/project/$id'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return 'Project deleted successfully';
      } else {
        throw Exception(
            'Failed to delete project: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      throw Exception('Network or internal error: $error');
    }
  }

  // Crop Section
  Future<List<Map<String, dynamic>>> getCrop() async {
    try {
      final authToken = await _getToken();
      if (authToken == null) throw Exception('No authentication token found');

      final response = await http.get(
        Uri.parse('$apiUrl/crop'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception(
            'Failed to fetch crops: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      throw Exception('Network or internal error: $error');
    }
  }

  // User Section
  Future<List<Map<String, dynamic>>> getUser() async {
    try {
      final authToken = await _getToken();
      if (authToken == null) throw Exception('No authentication token found');

      final response = await http.get(
        Uri.parse('$apiUrl/user'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception(
            'Failed to fetch users: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      throw Exception('Network or internal error: $error');
    }
  }

  // Task Section
  Future<List<Map<String, dynamic>>> getTasks() async {
    try {
      final authToken = await _getToken();
      if (authToken == null) throw Exception('No authentication token found');

      final response = await http.get(
        Uri.parse('$apiUrl/task'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception(
            'Failed to fetch tasks: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      throw Exception('Network or internal error: $error');
    }
  }

  Future<List<Task>> getTasksByProject(int projectId) async {
    try {
      final authToken = await _getToken();
      if (authToken == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('$apiUrl/task?project=$projectId'), // Query parameter
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Task.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to fetch tasks for project $projectId from $apiUrl/tasks?project=$projectId: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (error) {
      throw Exception('Error fetching tasks for project $projectId: $error');
    }
  }

  Future<String> createTask({
    required String? titre,
    required String? description,
    required String? startDate,
    required String? endDate,
    required String? priority,
    required String? status,
    required String? project,
    required String? taskOwner,
  }) async {
    final body = {
      if (titre != null) 'titre': titre,
      if (description != null) 'description': description,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (priority != null) 'priority': priority,
      if (status != null) 'status': status,
      if (project != null) 'project': project,
      if (taskOwner != null) 'taskOwner': taskOwner,
    };

    try {
      final authToken = await _getToken();
      if (authToken == null) throw Exception('No authentication token found');

      final response = await http.post(
        Uri.parse('$apiUrl/task'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return responseData['message'] ?? 'Task created successfully';
      } else {
        throw Exception(
            'Failed to create task: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      throw Exception('Network or internal error: $error');
    }
  }

  Future<String> updateTask({
    required String id,
    String? titre,
    String? description,
    String? startDate,
    String? endDate,
    String? priority,
    String? status,
    String? project,
    String? taskOwner,
    required int taskId,
  }) async {
    final body = {
      if (titre != null) 'titre': titre,
      if (description != null) 'description': description,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (priority != null) 'priority': priority,
      if (status != null) 'status': status,
      if (project != null) 'project': project,
      if (taskOwner != null) 'taskOwner': taskOwner,
    };

    try {
      final authToken = await _getToken();
      if (authToken == null) throw Exception('No authentication token found');

      final response = await http.put(
        Uri.parse('$apiUrl/task/$id'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['message'] ?? 'Task updated successfully';
      } else {
        throw Exception(
            'Failed to update task: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      throw Exception('Network or internal error: $error');
    }
  }

  Future<String> deleteTask(int id) async {
    try {
      final authToken = await _getToken();
      if (authToken == null) throw Exception('No authentication token found');

      final response = await http.delete(
        Uri.parse('$apiUrl/task/$id'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return 'Task deleted successfully';
      } else {
        throw Exception(
            'Failed to delete task: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      throw Exception('Network or internal error: $error');
    }
  }

  // Membership Section
  Future<List<Map<String, dynamic>>> getMemberships() async {
    try {
      final authToken = await _getToken();
      if (authToken == null) throw Exception('No authentication token found');

      final response = await http.get(
        Uri.parse('$apiUrl/membership'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception(
            'Failed to fetch memberships: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      throw Exception('Network or internal error: $error');
    }
  }

  Future<String> createMembership({
    required int project,
    required int user,
    required String role,
  }) async {
    final body = {
      'project': project,
      'user': user,
      'role': role,
    };

    try {
      final authToken = await _getToken();
      if (authToken == null) throw Exception('No authentication token found');

      final response = await http.post(
        Uri.parse('$apiUrl/project-member-ship'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return 'Member added successfully';
      } else {
        throw Exception(
            'Failed to add member: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      throw Exception('Network or internal error: $error');
    }
  }

  Future<List<Membership>> getMemberByProject({required int projectId}) async {
    try {
      final authToken = await _getToken();
      if (authToken == null) throw Exception('No authentication token found');

      final response = await http.get(
        Uri.parse('$apiUrl/project-member-ship/project/$projectId'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Membership.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to fetch project members: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      throw Exception('Network or internal error: $error');
    }
  }

  // Oops Post Section
  Future<List<dynamic>> getPostByConnectUser(int userId) async {
    try {
      final authToken = await _getToken();
      if (authToken == null) throw Exception('No authentication token found');

      final response = await http.get(
        Uri.parse('$apiUrl/oops/user/$userId'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as List<dynamic>;
      } else {
        throw Exception(
            'Failed to fetch user posts: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      throw Exception('Network or internal error: $error');
    }
  }

  Future<List<dynamic>> getOopsPost() async {
    try {
      final authToken = await _getToken();
      if (authToken == null) throw Exception('No authentication token found');

      final response = await http.get(
        Uri.parse('$apiUrl/oops'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as List<dynamic>;
      } else {
        throw Exception(
            'Failed to fetch posts: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      throw Exception('Network or internal error: $error');
    }
  }

  Future<bool> likePost(String postId, int userId, bool like) async {
    try {
      final authToken = await _getToken();
      if (authToken == null) throw Exception('No authentication token found');

      final response = await http.post(
        Uri.parse('$apiUrl/oops-like'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'oops': postId,
          'userId': userId,
          'isLiked': like,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception(
            'Failed to like/unlike post: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      throw Exception('Network or internal error: $error');
    }
  }

  Future<String> createPost({
    required int user,
    String? content,
    required String image,
  }) async {
    final body = {
      'user': user,
      'image': image,
      if (content != null) 'content': content,
    };

    try {
      final authToken = await _getToken();
      if (authToken == null) throw Exception('No authentication token found');

      final response = await http.post(
        Uri.parse('$apiUrl/oops'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return responseData['message'] ?? 'Post created successfully';
      } else {
        throw Exception(
            'Failed to create post: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      throw Exception('Network or internal error: $error');
    }
  }

  Future<String?> uploadImage(File imageFile) async {
    try {
      final authToken = await _getToken();
      if (authToken == null) throw Exception('No authentication token found');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$apiUrl/oops/upload'),
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
    } catch (error) {
      throw Exception('Network or internal error: $error');
    }
  }

  Future<Map<String, dynamic>> createComment({
    required int oops,
    required int user,
    String? content,
  }) async {
    final body = {
      'oops': oops,
      'userId': user,
      if (content != null) 'content': content,
    };

    try {
      final authToken = await _getToken();
      if (authToken == null) throw Exception('No authentication token found');

      final response = await http.post(
        Uri.parse('$apiUrl/oops-comment'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(
            'Failed to create comment: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      throw Exception('Network or internal error: $error');
    }
  }

  Future<List<Map<String, dynamic>>> getComments() async {
    try {
      final authToken = await _getToken();
      if (authToken == null) throw Exception('No authentication token found');

      final response = await http.get(
        Uri.parse('$apiUrl/oops-comment'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception(
            'Failed to fetch comments: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      throw Exception('Network or internal error: $error');
    }
  }

  Future<bool> shareOops(int oopsId, String? customMessage) async {
    try {
      final authToken = await _getToken();
      if (authToken == null) throw Exception('No authentication token found');

      final response = await http.post(
        Uri.parse('$apiUrl/oops/$oopsId/share'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'message': customMessage}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception(
            'Failed to share post: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      throw Exception('Network or internal error: $error');
    }
  }

  Future<bool> editPost(int postId, String newContent,
      {String? newImageUrl}) async {
    try {
      final authToken = await _getToken();
      if (authToken == null) throw Exception('No authentication token found');

      final response = await http.put(
        Uri.parse('$apiUrl/oops/$postId'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'content': newContent,
          if (newImageUrl != null) 'image': newImageUrl,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(
            'Failed to update post: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      throw Exception('Network or internal error: $error');
    }
  }

  Future<bool> deletePost(int postId) async {
    try {
      final authToken = await _getToken();
      if (authToken == null) throw Exception('No authentication token found');

      final response = await http.delete(
        Uri.parse('$apiUrl/oops/$postId'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        throw Exception(
            'Failed to delete post: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      throw Exception('Network or internal error: $error');
    }
  }
}
