import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String baseUrl;

  ApiService(this.baseUrl);

  Future<List<Map<String, dynamic>>> fetchWorkouts([String? category]) async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['results'] as List)
            .map((workout) => {
                  'id': workout['id'],
                  'title': workout['name'],
                  'thumbnail': workout['image'],
                  'duration': 'N/A',
                  'calories': 'N/A',
                })
            .toList();
      } else {
        print('Error: ${response.body}'); // Log the response body
        throw Exception('Failed to load workouts');
      }
    } catch (e) {
      print('Error fetching workouts: $e');
      return [];
    }
  }
}
