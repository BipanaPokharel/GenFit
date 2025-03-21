import 'package:flutter/material.dart';
import 'package:fyp/utils/api_service.dart';
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

  @override
  void initState() {
    super.initState();
    _loadUserSettings();
  }

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
      });
    } catch (e) {
      print('Error loading user settings: $e');
    }
  }

  Future<void> _updateUserSettings() async {
    try {
      if (widget.userId == null) {
        print('User ID is null in Settings widget');
        return;
      }

      final updatedSettings = {
        'emailNotifications': _emailNotifications,
        'pushNotifications': _pushNotifications,
      };

      await widget.apiService
          .updateUserSettings(widget.userId!, updatedSettings);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Settings updated successfully')));
    } catch (e) {
      print('Error updating user settings: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to update settings')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundImage: _profilePic.isNotEmpty
                  ? NetworkImage(_profilePic)
                  : AssetImage('assets/default_profile.png') as ImageProvider,
              radius: 50,
            ),
            SizedBox(height: 16),
            Text('Username: $_username', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Email: $_email', style: TextStyle(fontSize: 16)),
            SizedBox(height: 24),
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
