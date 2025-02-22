import 'package:flutter/material.dart';
import 'package:fyp/features/workout/presentation/mealplanner.dart';
import 'package:fyp/utils/api_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

enum NavigationItem { library, workouts, settings, mealPlanner }

class FriendRequest {
  final int id;
  final int senderId;
  final int receiverId;
  final String status;
  final DateTime createdAt;

  FriendRequest({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.status,
    required this.createdAt,
  });
}

class DashboardScreen extends StatefulWidget {
  final Function() onLogout;
  const DashboardScreen({Key? key, required this.onLogout}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  NavigationItem _selectedItem = NavigationItem.library;
  bool _isSidebarExpanded = true;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  ThemeMode _selectedTheme = ThemeMode.light;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  List<FriendRequest> pendingRequests = [];
  int? userId;
  String? token;
  static const double _mobileBreakpoint = 600;
  static const double _tabletBreakpoint = 900;

  late final ApiService _apiService;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService("http://localhost:3000/api");
    _loadUserData();
    _loadUserSettings();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('userId');
      token = prefs.getString('token');
    });
    _loadPendingFriendRequests();
  }

  Future<void> _loadUserSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('user_name') ?? 'User';
      _emailController.text = prefs.getString('user_email') ?? '';
      _phoneController.text = prefs.getString('user_phone') ?? '';
      _emailNotifications = prefs.getBool('email_notifications') ?? true;
      _pushNotifications = prefs.getBool('push_notifications') ?? true;
      _selectedTheme = ThemeMode.values[prefs.getInt('theme_mode') ?? 0];
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
        await _uploadProfilePicture();
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image');
    }
  }

  Future<void> _uploadProfilePicture() async {
    if (_profileImage == null) return;
    try {
      await _apiService.uploadProfilePicture(userId!, _profileImage!);
      _showSuccessSnackBar('Profile picture updated successfully');
    } catch (e) {
      _showErrorSnackBar('Failed to upload profile picture');
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Save user settings to SharedPreferences
      await prefs.setString('user_name', _nameController.text);
      await prefs.setString('user_email', _emailController.text);
      await prefs.setString('user_phone', _phoneController.text);
      await prefs.setBool('email_notifications', _emailNotifications);
      await prefs.setBool('push_notifications', _pushNotifications);
      await prefs.setInt('theme_mode', _selectedTheme.index);

      // Update user settings on the server
      await _apiService.updateUserSettings(
        userId!,
        {
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'emailNotifications': _emailNotifications,
          'pushNotifications': _pushNotifications,
          'themeMode': _selectedTheme.index,
        },
      );

      _showSuccessSnackBar('Settings saved successfully');
    } catch (e) {
      _showErrorSnackBar('Failed to save settings');
    }
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        title: Text(
          'Change Password',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge!.color,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'New Password',
                labelStyle: TextStyle(color: Theme.of(context).hintColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                prefixIcon:
                    Icon(Icons.lock, color: Theme.of(context).iconTheme.color),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                labelStyle: TextStyle(color: Theme.of(context).hintColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                prefixIcon:
                    Icon(Icons.lock, color: Theme.of(context).iconTheme.color),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).textTheme.bodyLarge!.color,
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: _changePassword,
            child: const Text('Change', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Future<void> _changePassword() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorSnackBar('Passwords do not match');
      return;
    }

    try {
      await _apiService.changePassword(
        userId!,
        _passwordController.text,
      );
      Navigator.pop(context);
      _showSuccessSnackBar('Password changed successfully');
      _passwordController.clear();
      _confirmPasswordController.clear();
    } catch (e) {
      _showErrorSnackBar('Failed to change password');
    }
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        title: Text(
          'Delete Account',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red[700],
          ),
        ),
        content: Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).textTheme.bodyLarge!.color,
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: _deleteAccount,
            child: const Text('Delete',
                style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    try {
      await _apiService.deleteAccount(userId!);
      Navigator.pop(context);
      widget.onLogout();
    } catch (e) {
      _showErrorSnackBar('Failed to delete account');
    }
  }

  Future<void> _loadPendingFriendRequests() async {
    if (userId == null) return;
    try {
      final requests = await _apiService.getPendingFriendRequests(userId!);
      setState(() {
        pendingRequests = requests
            .map((item) => FriendRequest(
                  id: item['id'],
                  senderId: item['sender_id'],
                  receiverId: item['receiver_id'],
                  status: item['status'],
                  createdAt: DateTime.parse(item['created_at']),
                ))
            .toList();
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load friend requests');
    }
  }

  Future<void> _acceptFriendRequest(int requestId) async {
    try {
      await _apiService.acceptFriendRequestById(requestId);
      _loadPendingFriendRequests();
      _showSuccessSnackBar('Friend request accepted');
    } catch (e) {
      _showErrorSnackBar('Failed to accept friend request');
    }
  }

  Future<void> _rejectFriendRequest(int requestId) async {
    try {
      await _apiService.rejectFriendRequestById(requestId);
      _loadPendingFriendRequests();
      _showSuccessSnackBar('Friend request rejected');
    } catch (e) {
      _showErrorSnackBar('Failed to reject friend request');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _logout() async {
    try {
      await _apiService.logout(userId!);
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      widget.onLogout();
    } catch (e) {
      _showErrorSnackBar('Failed to logout');
    }
  }

  String _getPageTitle() {
    switch (_selectedItem) {
      case NavigationItem.library:
        return 'Library';
      case NavigationItem.workouts:
        return 'Workouts';
      case NavigationItem.settings:
        return 'Settings'; // Corrected this line
      case NavigationItem.mealPlanner:
        return 'Meal Planner';
    }
  }

  Widget _buildNavigation(bool isDesktop) {
    return Container(
      width: isDesktop ? 250 : null,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildNavigationItem(NavigationItem.library, Icons.book, 'Library'),
            _buildNavigationItem(
                NavigationItem.workouts, Icons.fitness_center, 'Workouts'),
            _buildNavigationItem(
                NavigationItem.settings, Icons.settings, 'Settings'),
            _buildNavigationItem(NavigationItem.mealPlanner,
                Icons.restaurant_menu, 'Meal Planner'),
            const SizedBox(height: 20),
            const Divider(),
            ListTile(
              leading: Icon(Icons.exit_to_app, color: Colors.red[400]),
              title: Text('Logout',
                  style: TextStyle(
                      fontWeight: FontWeight.w500, color: Colors.red[400])),
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationItem(
      NavigationItem item, IconData icon, String title) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: _selectedItem == item
            ? Theme.of(context).primaryColor.withOpacity(0.2)
            : Colors.transparent,
      ),
      child: ListTile(
        leading: Icon(icon,
            color: _selectedItem == item
                ? Theme.of(context).primaryColor
                : Colors.grey[600]),
        title: Text(title,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: _selectedItem == item
                  ? Theme.of(context).primaryColor
                  : Colors.grey[800],
            )),
        selected: _selectedItem == item,
        onTap: () {
          setState(() {
            _selectedItem = item;
          });
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildContent(bool isDesktop) {
    switch (_selectedItem) {
      case NavigationItem.library:
        return _buildPlaceholderContent('Library Content');
      case NavigationItem.workouts:
        return _buildPlaceholderContent('Workouts Content');
      case NavigationItem.settings:
        return _buildSettingsContent(isDesktop);
      case NavigationItem.mealPlanner:
        return const MealPlanner();
      default:
        return _buildPlaceholderContent('Unknown Content');
    }
  }

  Widget _buildPlaceholderContent(String text) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).textTheme.bodyLarge!.color),
        ),
      ),
    );
  }

  Widget _buildSettingsContent(bool isDesktop) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'User Profile',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge!.color,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 70,
                  backgroundColor: Theme.of(context).highlightColor,
                  backgroundImage:
                      _profileImage != null ? FileImage(_profileImage!) : null,
                  child: _profileImage == null
                      ? Icon(Icons.person,
                          size: 70, color: Theme.of(context).iconTheme.color)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Name',
              labelStyle: TextStyle(color: Theme.of(context).hintColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).inputDecorationTheme.fillColor,
              prefixIcon:
                  Icon(Icons.person, color: Theme.of(context).iconTheme.color),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              labelStyle: TextStyle(color: Theme.of(context).hintColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).inputDecorationTheme.fillColor,
              prefixIcon:
                  Icon(Icons.email, color: Theme.of(context).iconTheme.color),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'Phone',
              labelStyle: TextStyle(color: Theme.of(context).hintColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).inputDecorationTheme.fillColor,
              prefixIcon:
                  Icon(Icons.phone, color: Theme.of(context).iconTheme.color),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(Icons.notifications,
                  color: Theme.of(context).iconTheme.color),
              const SizedBox(width: 10),
              Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge!.color,
                ),
              ),
            ],
          ),
          SwitchListTile(
            title: Text(
              'Email Notifications',
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge!.color),
            ),
            value: _emailNotifications,
            onChanged: (bool value) {
              setState(() {
                _emailNotifications = value;
              });
            },
            secondary:
                Icon(Icons.email, color: Theme.of(context).iconTheme.color),
            tileColor: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
          ),
          SwitchListTile(
            title: Text(
              'Push Notifications',
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge!.color),
            ),
            value: _pushNotifications,
            onChanged: (bool value) {
              setState(() {
                _pushNotifications = value;
              });
            },
            secondary:
                Icon(Icons.message, color: Theme.of(context).iconTheme.color),
            tileColor: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(Icons.color_lens, color: Theme.of(context).iconTheme.color),
              const SizedBox(width: 10),
              Text(
                'Theme',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge!.color,
                ),
              ),
            ],
          ),
          RadioListTile<ThemeMode>(
            title: Text(
              'Light',
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge!.color),
            ),
            value: ThemeMode.light,
            groupValue: _selectedTheme,
            onChanged: (ThemeMode? value) {
              setState(() {
                _selectedTheme = value!;
              });
            },
            secondary:
                Icon(Icons.wb_sunny, color: Theme.of(context).iconTheme.color),
            tileColor: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
          ),
          RadioListTile<ThemeMode>(
            title: Text(
              'Dark',
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge!.color),
            ),
            value: ThemeMode.dark,
            groupValue: _selectedTheme,
            onChanged: (ThemeMode? value) {
              setState(() {
                _selectedTheme = value!;
              });
            },
            secondary: Icon(Icons.brightness_3,
                color: Theme.of(context).iconTheme.color),
            tileColor: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              onPressed: _saveSettings,
              child:
                  const Text('Save Settings', style: TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(height: 20),
          const Divider(),
          ListTile(
            leading: Icon(Icons.lock, color: Theme.of(context).iconTheme.color),
            title: Text(
              'Change Password',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodyLarge!.color,
              ),
            ),
            onTap: _showChangePasswordDialog,
          ),
          ListTile(
            leading: Icon(Icons.delete_forever, color: Colors.red[700]),
            title: Text(
              'Delete Account',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.red[700],
              ),
            ),
            onTap: _showDeleteAccountDialog,
          ),
          const SizedBox(height: 20),
          if (!isDesktop) _buildFriendRequestsSection(),
        ],
      ),
    );
  }

  Widget _buildFriendRequestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Friend Requests',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge!.color,
          ),
        ),
        const SizedBox(height: 10),
        if (pendingRequests.isEmpty)
          Text(
            'No pending friend requests.',
            style:
                TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: pendingRequests.length,
            itemBuilder: (context, index) {
              final request = pendingRequests[index];
              return Card(
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: ListTile(
                  leading: const Icon(Icons.person_add, color: Colors.blue),
                  title: Text('Request from User ${request.senderId}',
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge!.color)),
                  subtitle: Text('Sent on ${request.createdAt.toString()}',
                      style: TextStyle(color: Theme.of(context).hintColor)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon:
                            const Icon(Icons.check_circle, color: Colors.green),
                        onPressed: () => _acceptFriendRequest(request.id),
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: () => _rejectFriendRequest(request.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > _tabletBreakpoint;

    return Theme(
      data: ThemeData(
        brightness: _selectedTheme == ThemeMode.dark
            ? Brightness.dark
            : Brightness.light,
        primarySwatch: Colors.blue,
        dialogBackgroundColor:
            _selectedTheme == ThemeMode.dark ? Colors.grey[800] : Colors.white,
        cardColor:
            _selectedTheme == ThemeMode.dark ? Colors.grey[700] : Colors.white,
        highlightColor: _selectedTheme == ThemeMode.dark
            ? Colors.grey[600]
            : Colors.grey[200],
        hintColor: _selectedTheme == ThemeMode.dark
            ? Colors.grey[400]
            : Colors.grey[600],
        iconTheme: IconThemeData(
            color:
                _selectedTheme == ThemeMode.dark ? Colors.white : Colors.black),
        textTheme: TextTheme(
          titleLarge: TextStyle(
              color: _selectedTheme == ThemeMode.dark
                  ? Colors.white
                  : Colors.black),
          bodyLarge: TextStyle(
              color: _selectedTheme == ThemeMode.dark
                  ? Colors.white
                  : Colors.black),
        ),
        inputDecorationTheme: InputDecorationTheme(
          fillColor: _selectedTheme == ThemeMode.dark
              ? Colors.grey[900]
              : Colors.grey[100],
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(_getPageTitle()),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: Row(
          children: [
            if (isDesktop) _buildNavigation(true),
            Expanded(
              child: _buildContent(isDesktop),
            ),
            if (isDesktop)
              SizedBox(
                width: 300,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildFriendRequestsSection(),
                ),
              ),
          ],
        ),
        drawer: isDesktop
            ? null
            : Drawer(
                child: _buildNavigation(false),
              ),
      ),
    );
  }
}
