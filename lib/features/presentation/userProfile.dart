import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    const userId = '25'; // Replace with the actual user ID
    final response = await http.get(
      Uri.parse('http://localhost:3000/api/user/profile/$userId'),
      headers: {
        'x-auth-token': 'your-jwt-token', // Replace with actual token
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _nameController.text =
            data['username']; // Ensure the correct field is used
        _emailController.text = data['email'];
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      // Handle error
    }
  }

  Future<void> _updateUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.put(
      Uri.parse('http://localhost:3000/api/user/profile/25'),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjI1LCJlbWFpbCI6Im5ld3VzZXJAZXhhbXBsZS5jb20iLCJpYXQiOjE3Mzg2NjcyMjcsImV4cCI6MTczODY3MDgyN30.__stLZ-tsKXI_Rq5v19wqEtXrYyAXAcmJ92Gnh3R3Ew',
      },
      body: json.encode({
        'name': _nameController.text,
        'email': _emailController.text,
      }),
    );

    if (response.statusCode == 200) {
      // Handle success
    } else {
      // Handle error
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _updateUserProfile,
                    child: const Text('Update Profile'),
                  ),
                ],
              ),
            ),
    );
  }
}
