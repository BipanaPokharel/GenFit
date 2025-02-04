import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  Map<String, dynamic>? userProfile;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      final response = await http.get(Uri.parse(
          'http://localhost:3000/api/user/profile/22')); // Replace with your actual backend URL

      if (response.statusCode == 200) {
        setState(() {
          userProfile = json.decode(response.body);
        });
      } else {
        print(
            'Failed to load user profile: ${response.statusCode} ${response.body}');
        throw Exception('Failed to load user profile');
      }
    } catch (error) {
      print('Error fetching user profile: $error');
      throw Exception('Failed to load user profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userProfile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(userProfile!['profile_pic']),
            ),
            const SizedBox(height: 16),
            Text(
              userProfile!['username'],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            const SizedBox(height: 8),
            Text('Email: ${userProfile!['email']}'),
            const SizedBox(height: 8),
            Text('Fitness Goal: ${userProfile!['fitness_goal']}'),
          ],
        ),
      ),
    );
  }
}
