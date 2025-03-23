// api_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl;
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';

  ApiService(this.baseUrl);

  // Helper method to get auth headers
  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Generic error handler
  dynamic _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        try {
          return jsonDecode(response.body);
        } catch (e) {
          print('Error decoding JSON: ${response.body}');
          throw Exception('Failed to decode JSON: ${response.body}');
        }
      case 400:
        throw Exception('Bad request: ${response.body}');
      case 401:
        throw Exception('Unauthorized: Please login again');
      case 403:
        throw Exception('Forbidden: ${response.body}');
      case 404:
        throw Exception('Resource not found');
      case 500:
        throw Exception('Server error: ${response.body}');
      default:
        throw Exception('Request failed with status: ${response.statusCode}');
    }
  }

  /// Authentication Methods
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        body: jsonEncode({'email': email, 'password': password}),
        headers: {'Content-Type': 'application/json'},
      );

      final data = _handleResponse(response);
      // Save token and user ID
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, data['token']);
      await prefs.setInt(
          _userIdKey, data['user']['user_id']); // Access user_id from response
      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> register(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        body: jsonEncode(userData),
        headers: {'Content-Type': 'application/json'},
      );
      _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout(int userId) async {
    // Pass userId to logout
    try {
      final prefs = await SharedPreferences.getInstance();
      final headers = await _getAuthHeaders();

      final response = await http.post(
        Uri.parse('$baseUrl/users/$userId/logout'),
        headers: headers,
      );

      _handleResponse(response);

      // Clear local storage
      await prefs.remove(_tokenKey);
      await prefs.remove(_userIdKey);
    } catch (e) {
      rethrow;
    }
  }

  /// User Profile Methods
  Future<Map<String, dynamic>> getCurrentUser(int userId) async {
    // Pass userId
    try {
      final headers = await _getAuthHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId'),
        headers: headers,
      );

      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUserSettings(
      int userId, Map<String, dynamic> updates) async {
    // Pass userId
    try {
      final headers = await _getAuthHeaders();

      final response = await http.put(
        Uri.parse('$baseUrl/users/$userId/settings'),
        headers: headers,
        body: jsonEncode(updates),
      );

      _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<String> uploadProfilePicture(int userId, File imageFile) async {
    // Pass userId
    try {
      final headers = await _getAuthHeaders();
      final mimeType = lookupMimeType(imageFile.path);

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/users/$userId/profile-picture'), // Correct endpoint
      )
        ..headers.addAll(headers)
        ..files.add(await http.MultipartFile.fromPath(
          'profileImage', // Change to match backend expectation
          imageFile.path,
          contentType: mimeType != null ? MediaType.parse(mimeType) : null,
        ));

      final response = await request.send();
      final responseData = await http.Response.fromStream(response);
      final jsonResponse = _handleResponse(responseData);
      return jsonResponse['profilePictureUrl'];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> changePassword(int userId, String newPassword) async {
    try {
      final headers = await _getAuthHeaders();

      final response = await http.put(
        Uri.parse('$baseUrl/users/$userId/password'),
        headers: headers,
        body: jsonEncode({'newPassword': newPassword}),
      );

      _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAccount(int userId) async {
    try {
      final headers = await _getAuthHeaders();

      final response = await http.delete(
        Uri.parse('$baseUrl/users/$userId'),
        headers: headers,
      );

      _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Workout Methods
  Future<List<dynamic>> getWorkouts({String? category}) async {
    try {
      final headers = await _getAuthHeaders();
      final endpoint = category != null
          ? '$baseUrl/workouts?category=$category'
          : '$baseUrl/workouts';

      final response = await http.get(Uri.parse(endpoint), headers: headers);
      return _handleResponse(response)['results'];
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createWorkout(
      Map<String, dynamic> workout) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/workouts'),
        headers: headers,
        body: jsonEncode(workout),
      );
      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Social Features
  Future<List<dynamic>> getPendingFriendRequests(int userId) async {
    // Pass userId
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse(
            '$baseUrl/users/$userId/friend-requests/pending'), // Correct Endpoint
        headers: headers,
      );
      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendFriendRequest(String targetUserId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/friend-requests'),
        headers: headers,
        body: jsonEncode({'receiverId': targetUserId}),
      );
      _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> acceptFriendRequestById(int requestId) async {
    // Pass requestId
    try {
      final headers = await _getAuthHeaders();
      final response = await http.put(
        // Using PUT request
        Uri.parse('$baseUrl/friend-requests/$requestId/accept'),
        headers: headers,
      );
      _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> rejectFriendRequestById(int requestId) async {
    // Pass requestId
    try {
      final headers = await _getAuthHeaders();
      final response = await http.put(
        // Using PUT request
        Uri.parse('$baseUrl/friend-requests/$requestId/reject'),
        headers: headers,
      );
      _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> generateMealSuggestions(
      List<String> ingredients) async {
    try {
      final headers = await _getAuthHeaders();
      headers['Content-Type'] = 'application/json';

      print('Requesting meals with: ${ingredients.join(', ')}');

      final response = await http.post(
        Uri.parse('$baseUrl/meals/suggestions'),
        headers: headers,
        body: jsonEncode({'ingredients': ingredients}),
      );

      print('Response status: ${response.statusCode}');

      final responseData = _handleResponse(response);
      return (responseData['matches'] as List?) ?? [];
    } catch (e) {
      print('Meal suggestion error: ${e.toString()}');
      throw Exception('Failed to get suggestions: ${e.toString()}');
    }
  }

  Future<void> saveMealToPlan(DateTime date, dynamic meal) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt(_userIdKey);

      if (userId == null) throw Exception("User not authenticated");

      // Proper JSON formatting for PostgreSQL JSONB
      final ingredientsJson = jsonEncode(meal['ingredients']
          .map((ing) => ing.toString().replaceAll("'", "\""))
          .toList());

      final mealData = {
        'user_id': userId,
        'meal_date': date.toIso8601String().split('T')[0],
        'meal_name': meal['meal'],
        'ingredients': ingredientsJson, // Proper JSONB format
        'meal_type': meal['type'] ?? 'main',
        'calories': (meal['calories'] ?? 0.0).toString(),
        'prep_time': meal['details']['prepTime'] ?? '',
        'cook_time': meal['details']['cookTime'] ?? '',
        'meal_image_url': meal['details']['url'] ?? ''
      };

      final headers = await _getAuthHeaders();
      headers['Content-Type'] = 'application/json';

      final response = await http.post(
        Uri.parse('$baseUrl/meal-plans'), // Must match backend route
        headers: headers,
        body: jsonEncode(mealData),
      );

      _handleResponse(response);
    } catch (e) {
      print('Save Meal Error: $e');
      throw Exception('Failed to save meal: ${e.toString()}');
    }
  }

  Future<List<dynamic>> getSavedMeals(DateTime date) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt(_userIdKey);
      final headers = await _getAuthHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/meal_plans?'
            'date=${date.toIso8601String().split('T')[0]}&'
            'user_id=$userId'),
        headers: headers,
      );

      return _handleResponse(response) as List<dynamic>;
    } catch (e) {
      print('Get meals error: ${e.toString()}');
      throw Exception('Failed to load meals: ${e.toString()}');
    }
  }
}
