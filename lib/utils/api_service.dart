import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io'; // Import dart:io

class ApiService {
  final String baseUrl;

  ApiService(this.baseUrl);

  /// Fetch meal recommendations based on ingredients
  Future<List<Map<String, dynamic>>> fetchMealRecommendations(
      List<String> ingredients) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/recommendations'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'ingredients': ingredients}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data as List)
            .map((meal) => <String, dynamic>{
                  'meal': meal['title'],
                  'ingredients': (meal['usedIngredients'] as List)
                      .map((ing) => ing['name'])
                      .toList(),
                })
            .toList();
      } else {
        print(
            'Failed to fetch meal recommendations. Status code: ${response.statusCode}');
        throw Exception('Failed to fetch meal recommendations');
      }
    } catch (e) {
      print('Error fetching meal recommendations: $e');
      rethrow;
    }
  }

  /// Fetch workouts (optionally filtered by category)
  Future<List<Map<String, dynamic>>> fetchWorkouts([String? category]) async {
    try {
      String url = baseUrl + '/workouts';
      if (category != null) {
        url += '?category=$category';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['results'] as List)
            .map((workout) => <String, dynamic>{
                  'id': workout['id'],
                  'title': workout['name'],
                  'thumbnail': workout['image'],
                  'duration': workout.containsKey('duration')
                      ? workout['duration']
                      : 'N/A',
                  'calories': workout.containsKey('calories')
                      ? workout['calories']
                      : 'N/A',
                })
            .toList();
      } else {
        print('Failed to fetch workouts. Status code: ${response.statusCode}');
        throw Exception('Failed to fetch workouts');
      }
    } catch (e) {
      print('Error fetching workouts: $e');
      rethrow;
    }
  }

  /// Send a friend request
  Future<void> sendFriendRequest(int senderId, int receiverId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/friendrequests/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'senderId': senderId, 'receiverId': receiverId}),
      );

      if (response.statusCode != 201) {
        print(
            'Failed to send friend request. Status code: ${response.statusCode}');
        throw Exception('Failed to send friend request');
      }
    } catch (e) {
      print('Error sending friend request: $e');
      rethrow;
    }
  }

  /// Accept a friend request by ID
  Future<void> acceptFriendRequestById(int requestId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/friendrequests/accept/$requestId'),
      );

      if (response.statusCode != 200) {
        print(
            'Failed to accept friend request. Status code: ${response.statusCode}');
        throw Exception('Failed to accept friend request');
      }
    } catch (e) {
      print('Error accepting friend request: $e');
      rethrow;
    }
  }

  /// Reject a friend request by ID
  Future<void> rejectFriendRequestById(int requestId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/friendrequests/reject/$requestId'),
      );

      if (response.statusCode != 200) {
        print(
            'Failed to reject friend request. Status code: ${response.statusCode}');
        throw Exception('Failed to reject friend request');
      }
    } catch (e) {
      print('Error rejecting friend request: $e');
      rethrow;
    }
  }

  /// Get pending friend requests for a user
  Future<List<Map<String, dynamic>>> getPendingFriendRequests(
      int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/friendrequests/pending/$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data as List)
            .map((item) => <String, dynamic>{
                  'id': item['id'],
                  'sender_id': item['sender_id'],
                  'receiver_id': item['receiver_id'],
                  'status': item['status'],
                  'created_at': DateTime.parse(item['created_at']).toString(),
                })
            .toList();
      } else {
        print(
            'Failed to fetch pending requests. Status code: ${response.statusCode}');
        throw Exception('Failed to fetch pending requests');
      }
    } catch (e) {
      print('Error fetching pending requests: $e');
      rethrow;
    }
  }

  /// Upload Profile Picture
  Future<void> uploadProfilePicture(int userId, File imageFile) async {
    try {
      final uri = Uri.parse('$baseUrl/users/$userId/profile-picture');
      final request = http.MultipartRequest('POST', uri);
      request.files.add(
        await http.MultipartFile.fromPath(
          'profile_picture',
          imageFile.path,
        ),
      );
      final response = await request.send();

      if (response.statusCode != 200) {
        print(
            'Failed to upload profile picture. Status code: ${response.statusCode}');
        throw Exception('Failed to upload profile picture');
      }
    } catch (e) {
      print('Error uploading profile picture: $e');
      rethrow;
    }
  }

  /// Update User Settings
  Future<void> updateUserSettings(
      int userId, Map<String, dynamic> settings) async {
    try {
      final uri = Uri.parse('$baseUrl/users/$userId/settings');
      final response = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(settings),
      );

      if (response.statusCode != 200) {
        print(
            'Failed to update user settings. Status code: ${response.statusCode}');
        throw Exception('Failed to update user settings');
      }
    } catch (e) {
      print('Error updating user settings: $e');
      rethrow;
    }
  }

  /// Change Password
  Future<void> changePassword(int userId, String newPassword) async {
    try {
      final uri = Uri.parse('$baseUrl/users/$userId/password');
      final response = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'newPassword': newPassword}),
      );

      if (response.statusCode != 200) {
        print('Failed to change password. Status code: ${response.statusCode}');
        throw Exception('Failed to change password');
      }
    } catch (e) {
      print('Error changing password: $e');
      rethrow;
    }
  }

  /// Delete Account
  Future<void> deleteAccount(int userId) async {
    try {
      final uri = Uri.parse('$baseUrl/users/$userId');
      final response = await http.delete(uri);

      if (response.statusCode != 200) {
        print('Failed to delete account. Status code: ${response.statusCode}');
        throw Exception('Failed to delete account');
      }
    } catch (e) {
      print('Error deleting account: $e');
      rethrow;
    }
  }

  /// Logout
  Future<void> logout(int userId) async {
    try {
      final uri = Uri.parse('$baseUrl/users/$userId/logout');
      final response = await http.post(uri);

      if (response.statusCode != 200) {
        print('Failed to logout. Status code: ${response.statusCode}');
        throw Exception('Failed to logout');
      }
    } catch (e) {
      print('Error logging out: $e');
      rethrow;
    }
  }
}
