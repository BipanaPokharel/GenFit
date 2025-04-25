import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

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
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
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
      ).timeout(Duration(seconds: 10));

      final data = _handleResponse(response);
      // Save token and user ID
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, data['token']);
      await prefs.setInt(_userIdKey, data['user']['user_id'] as int);
      return data;
    } on SocketException catch (e) {
      print('SocketException: $e');
      throw Exception(
          'Network error occurred. Please check your internet connection.');
    } on TimeoutException catch (e) {
      print('TimeoutException: $e');
      throw Exception('Request timed out. Please try again.');
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
      ).timeout(Duration(seconds: 10));
      _handleResponse(response);
    } on SocketException catch (e) {
      print('SocketException: $e');
      throw Exception(
          'Network error occurred. Please check your internet connection.');
    } on TimeoutException catch (e) {
      print('TimeoutException: $e');
      throw Exception('Request timed out. Please try again.');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout(int userId) async {
    // Pass userId to logout
    try {
      final prefs = await SharedPreferences.getInstance();
      final headers = await _getAuthHeaders();

      final response = await http
          .post(
            Uri.parse('$baseUrl/users/$userId/logout'),
            headers: headers,
          )
          .timeout(Duration(seconds: 10));

      _handleResponse(response);

      // Clear local storage
      await prefs.remove(_tokenKey);
      await prefs.remove(_userIdKey);
    } on SocketException catch (e) {
      print('SocketException: $e');
      throw Exception(
          'Network error occurred. Please check your internet connection.');
    } on TimeoutException catch (e) {
      print('TimeoutException: $e');
      throw Exception('Request timed out. Please try again.');
    } catch (e) {
      rethrow;
    }
  }

  /// User Profile Methods
  Future<Map<String, dynamic>> getCurrentUser(int userId) async {
    // Pass userId
    try {
      final headers = await _getAuthHeaders();

      final response = await http
          .get(
            Uri.parse('$baseUrl/users/$userId'),
            headers: headers,
          )
          .timeout(Duration(seconds: 10));

      return _handleResponse(response);
    } on SocketException catch (e) {
      print('SocketException: $e');
      throw Exception(
          'Network error occurred. Please check your internet connection.');
    } on TimeoutException catch (e) {
      print('TimeoutException: $e');
      throw Exception('Request timed out. Please try again.');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUserSettings(
      int userId, Map<String, dynamic> updates) async {
    try {
      final headers = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl/users/$userId/settings');

      // Log request details for debugging
      print('Updating user settings for userId: $userId');
      print('Request URL: $url');
      print('Request body: ${jsonEncode(updates)}');
      print('Headers: $headers');

      final response = await http
          .put(url, headers: headers, body: jsonEncode(updates))
          .timeout(Duration(seconds: 10));

      _handleResponse(response);
    } on SocketException catch (e) {
      print('SocketException: $e');
      throw Exception(
          'Network error occurred. Please check your internet connection.');
    } on TimeoutException catch (e) {
      print('TimeoutException: $e');
      throw Exception('Request timed out. Please try again.');
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  /// Upload Profile Picture
  Future<void> uploadProfilePicture(int userId, File imageFile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token is missing');
      }

      final uri = Uri.parse('$baseUrl/users/$userId/profile-picture');

      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['user_id'] = userId.toString()
        ..files.add(await http.MultipartFile.fromPath('image', imageFile.path,
            contentType: MediaType('image', 'jpeg')));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Profile picture uploaded successfully');
      } else {
        throw Exception('Failed to upload profile picture: ${response.body}');
      }
    } on SocketException catch (e) {
      print('SocketException: $e');
      throw Exception(
          'Network error occurred. Please check your internet connection.');
    } on TimeoutException catch (e) {
      print('TimeoutException: $e');
      throw Exception('Request timed out. Please try again.');
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  /// Get Posts from the Community
  Future<List<dynamic>> getPosts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      Map<String, String> headers = {'Content-Type': 'application/json'};

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      print('Fetching posts from: $baseUrl/posts');

      final response = await http
          .get(Uri.parse('$baseUrl/posts'), headers: headers)
          .timeout(Duration(seconds: 10));

      print('Posts response status: ${response.statusCode}');
      print('Posts response body: ${response.body}');

      final data = _handleResponse(response);

      if (data is List) {
        return data;
      } else if (data is Map && data.containsKey('posts')) {
        return data['posts'] as List<dynamic>;
      } else if (data is Map && data.containsKey('results')) {
        return data['results'] as List<dynamic>;
      } else {
        return data is List ? data : [data];
      }
    } on SocketException catch (e) {
      print('SocketException: $e');
      throw Exception(
          'Network error occurred. Please check your internet connection.');
    } on TimeoutException catch (e) {
      print('TimeoutException: $e');
      throw Exception('Request timed out. Please try again.');
    } catch (e) {
      print('Error getting posts: $e');
      rethrow;
    }
  }

  /// Change User Password
  Future<void> changePassword(int userId, String newPassword) async {
    try {
      final headers = await _getAuthHeaders();

      final response = await http
          .put(
            Uri.parse('$baseUrl/users/$userId/password'),
            headers: headers,
            body: jsonEncode({'newPassword': newPassword}),
          )
          .timeout(Duration(seconds: 10));

      _handleResponse(response);
    } on SocketException catch (e) {
      print('SocketException: $e');
      throw Exception(
          'Network error occurred. Please check your internet connection.');
    } on TimeoutException catch (e) {
      print('TimeoutException: $e');
      throw Exception('Request timed out. Please try again.');
    } catch (e) {
      rethrow;
    }
  }

  /// Delete User Account
  Future<void> deleteAccount(int userId) async {
    try {
      final headers = await _getAuthHeaders();

      final response = await http
          .delete(
            Uri.parse('$baseUrl/users/$userId'),
            headers: headers,
          )
          .timeout(Duration(seconds: 10));

      _handleResponse(response);
    } on SocketException catch (e) {
      print('SocketException: $e');
      throw Exception(
          'Network error occurred. Please check your internet connection.');
    } on TimeoutException catch (e) {
      print('TimeoutException: $e');
      throw Exception('Request timed out. Please try again.');
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

      final response = await http
          .get(Uri.parse(endpoint), headers: headers)
          .timeout(Duration(seconds: 10));
      return _handleResponse(response)['results'] as List<dynamic>;
    } on SocketException catch (e) {
      print('SocketException: $e');
      throw Exception(
          'Network error occurred. Please check your internet connection.');
    } on TimeoutException catch (e) {
      print('TimeoutException: $e');
      throw Exception('Request timed out. Please try again.');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createWorkout(
      Map<String, dynamic> workout) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http
          .post(
            Uri.parse('$baseUrl/workouts'),
            headers: headers,
            body: jsonEncode(workout),
          )
          .timeout(Duration(seconds: 10));
      return _handleResponse(response);
    } on SocketException catch (e) {
      print('SocketException: $e');
      throw Exception(
          'Network error occurred. Please check your internet connection.');
    } on TimeoutException catch (e) {
      print('TimeoutException: $e');
      throw Exception('Request timed out. Please try again.');
    } catch (e) {
      rethrow;
    }
  }

  /// Social Features
  Future<List<dynamic>> getPendingFriendRequests(int userId) async {
    // Pass userId
    try {
      final headers = await _getAuthHeaders();
      final response = await http
          .get(
            Uri.parse('$baseUrl/users/$userId/friend-requests/pending'),
            headers: headers,
          )
          .timeout(Duration(seconds: 10));
      return _handleResponse(response) as List<dynamic>;
    } on SocketException catch (e) {
      print('SocketException: $e');
      throw Exception(
          'Network error occurred. Please check your internet connection.');
    } on TimeoutException catch (e) {
      print('TimeoutException: $e');
      throw Exception('Request timed out. Please try again.');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendFriendRequest(String targetUserId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http
          .post(
            Uri.parse('$baseUrl/friend-requests'),
            headers: headers,
            body: jsonEncode({'receiverId': targetUserId}),
          )
          .timeout(Duration(seconds: 10));
      _handleResponse(response);
    } on SocketException catch (e) {
      print('SocketException: $e');
      throw Exception(
          'Network error occurred. Please check your internet connection.');
    } on TimeoutException catch (e) {
      print('TimeoutException: $e');
      throw Exception('Request timed out. Please try again.');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> acceptFriendRequestById(int requestId) async {
    // Pass requestId
    try {
      final headers = await _getAuthHeaders();
      final response = await http
          .put(
            // Using PUT request
            Uri.parse('$baseUrl/friend-requests/$requestId/accept'),
            headers: headers,
          )
          .timeout(Duration(seconds: 10));
      _handleResponse(response);
    } on SocketException catch (e) {
      print('SocketException: $e');
      throw Exception(
          'Network error occurred. Please check your internet connection.');
    } on TimeoutException catch (e) {
      print('TimeoutException: $e');
      throw Exception('Request timed out. Please try again.');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> rejectFriendRequestById(int requestId) async {
    // Pass requestId
    try {
      final headers = await _getAuthHeaders();
      final response = await http
          .put(
            // Using PUT request
            Uri.parse('$baseUrl/friend-requests/$requestId/reject'),
            headers: headers,
          )
          .timeout(Duration(seconds: 10));
      _handleResponse(response);
    } on SocketException catch (e) {
      print('SocketException: $e');
      throw Exception(
          'Network error occurred. Please check your internet connection.');
    } on TimeoutException catch (e) {
      print('TimeoutException: $e');
      throw Exception('Request timed out. Please try again.');
    } catch (e) {
      rethrow;
    }
  }

  /// Meal Suggestion Methods
  Future<List<dynamic>> generateMealSuggestions(
      List<String> ingredients) async {
    try {
      final headers = await _getAuthHeaders();
      headers['Content-Type'] = 'application/json';

      print('Requesting meals with: ${ingredients.join(', ')}');

      final response = await http
          .post(
            Uri.parse('$baseUrl/meals/suggestions'),
            headers: headers,
            body: jsonEncode({'ingredients': ingredients}),
          )
          .timeout(Duration(seconds: 10));

      print('Response status: ${response.statusCode}');

      final responseData = _handleResponse(response);
      return (responseData['matches'] as List?) ?? [];
    } on SocketException catch (e) {
      print('SocketException: $e');
      throw Exception(
          'Network error occurred. Please check your internet connection.');
    } on TimeoutException catch (e) {
      print('TimeoutException: $e');
      throw Exception('Request timed out. Please try again.');
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
        'ingredients': ingredientsJson,
        'meal_type': meal['type'] ?? 'main',
        'calories': (meal['calories'] ?? 0.0).toString(),
        'prep_time': meal['details']['prepTime'] ?? '',
        'cook_time': meal['details']['cookTime'] ?? '',
        'meal_image_url': meal['details']['url'] ?? ''
      };

      final headers = await _getAuthHeaders();
      headers['Content-Type'] = 'application/json';

      final response = await http
          .post(
            Uri.parse('$baseUrl/meal-plans'),
            headers: headers,
            body: jsonEncode(mealData),
          )
          .timeout(Duration(seconds: 10));

      _handleResponse(response);
    } on SocketException catch (e) {
      print('SocketException: $e');
      throw Exception(
          'Network error occurred. Please check your internet connection.');
    } on TimeoutException catch (e) {
      print('TimeoutException: $e');
      throw Exception('Request timed out. Please try again.');
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

      final response = await http
          .get(
            Uri.parse('$baseUrl/meal_plans?'
                'date=${date.toIso8601String().split('T')[0]}&'
                'user_id=$userId'),
            headers: headers,
          )
          .timeout(Duration(seconds: 10));

      return _handleResponse(response) as List<dynamic>;
    } on SocketException catch (e) {
      print('SocketException: $e');
      throw Exception(
          'Network error occurred. Please check your internet connection.');
    } on TimeoutException catch (e) {
      print('TimeoutException: $e');
      throw Exception('Request timed out. Please try again.');
    } catch (e) {
      print('Get meals error: ${e.toString()}');
      throw Exception('Failed to load meals: ${e.toString()}');
    }
  }
}
