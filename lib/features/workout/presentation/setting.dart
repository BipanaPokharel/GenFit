import 'package:flutter/material.dart';
import 'package:fyp/utils/api_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  final int? userId;
  final ApiService apiService;

  const Settings({Key? key, required this.userId, required this.apiService})
      : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String _username = '';
  String _email = '';
  String _profilePic = '';
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _isLoading = true;
  File? _imageFile;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserSettings();
  }

  // Fetch user settings from API
  Future<void> _loadUserSettings() async {
    try {
      if (widget.userId == null) {
        print('User ID is null in Settings widget');
        return;
      }

      final user = await widget.apiService.getCurrentUser(widget.userId!);

      setState(() {
        _username = user['username'] ?? 'N/A';
        _email = user['email'] ?? 'N/A';
        _profilePic = user['profile_pic'] ?? '';
        _emailNotifications = user['settings']['emailNotifications'] ?? true;
        _pushNotifications = user['settings']['pushNotifications'] ?? true;

        // Initialize controllers with current data
        _usernameController.text = _username;
        _emailController.text = _email;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading user settings: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to load settings')));
    }
  }

  // Pick a new profile picture
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateUserSettings() async {
    try {
      if (widget.userId == null) {
        print('User ID is null in Settings widget');
        return;
      }

      final updatedSettings = {
        'username': _usernameController.text,
        'email': _emailController.text,
        'emailNotifications': _emailNotifications,
        'pushNotifications': _pushNotifications,
      };

      // Upload profile picture if selected
      if (_imageFile != null) {
        await widget.apiService.uploadProfilePicture(
          widget.userId!,
          _imageFile!,
        );
      }

      await widget.apiService
          .updateUserSettings(widget.userId!, updatedSettings);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Settings updated successfully')),
      );
    } catch (e) {
      print('Error updating user settings: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update settings')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator while fetching the user settings
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Settings'),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture Section
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                backgroundImage: _imageFile != null
                    ? FileImage(_imageFile!)
                    : (_profilePic.isNotEmpty
                            ? NetworkImage(_profilePic)
                            : AssetImage('assets/default_profile.png'))
                        as ImageProvider,
                radius: 50,
              ),
            ),
            SizedBox(height: 16),
            Text('Username:', style: TextStyle(fontSize: 18)),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(hintText: 'Enter username'),
            ),
            SizedBox(height: 8),
            Text('Email:', style: TextStyle(fontSize: 16)),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(hintText: 'Enter email'),
            ),
            SizedBox(height: 24),

            // Notifications Settings
            Row(
              children: [
                Text('Email Notifications:'),
                Switch(
                  value: _emailNotifications,
                  onChanged: (value) {
                    setState(() {
                      _emailNotifications = value;
                    });
                  },
                ),
              ],
            ),
            Row(
              children: [
                Text('Push Notifications:'),
                Switch(
                  value: _pushNotifications,
                  onChanged: (value) {
                    setState(() {
                      _pushNotifications = value;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 24),

            // Save Settings Button
            ElevatedButton(
              onPressed: _updateUserSettings,
              child: Text('Save Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
