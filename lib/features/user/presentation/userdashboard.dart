import 'package:flutter/material.dart';
import 'package:fyp/features/communityfeed/presentation/community.dart';
import 'package:fyp/features/communityfeed/presentation/notification.dart';
import 'package:fyp/features/presentation/login/login.dart';
import 'package:fyp/features/workout/presentation/mealplanner.dart';
import 'package:fyp/features/workout/presentation/setting.dart';
import 'package:fyp/features/workout/presentation/workout.dart';
import 'package:fyp/features/user/presentation/chat.dart';
import 'package:fyp/utils/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum NavigationItem {
  library,
  workouts,
  settings,
  mealPlanner,
  chat,
  community,
  friendRequest,
  notifications,
  bmi,
}

class DashboardScreen extends StatefulWidget {
  final int? userId;
  final ApiService apiService;
  const DashboardScreen(
      {Key? key, required this.userId, required this.apiService})
      : super(key: key);
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  NavigationItem _selectedItem = NavigationItem.library;
  bool _isLoading = true;
  bool _isRedirectingToLogin = false;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    if (widget.userId == null) {
      // Navigate to login if userId is null
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_isRedirectingToLogin) {
          _isRedirectingToLogin = true;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const Login()),
          );
        }
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    if (widget.userId == null) return;
    try {
      await widget.apiService.logout(widget.userId!);
    } catch (e) {
      debugPrint('Logout error: $e');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const Login()),
        (Route<dynamic> route) => false,
      );
    }
  }

  Widget _buildNavigation() {
    return ListView(
      children: [
        _buildNavigationItem(NavigationItem.library, Icons.book, 'Library'),
        _buildNavigationItem(
            NavigationItem.workouts, Icons.fitness_center, 'Workouts'),
        _buildNavigationItem(
            NavigationItem.settings, Icons.settings, 'Settings'),
        _buildNavigationItem(
            NavigationItem.mealPlanner, Icons.restaurant_menu, 'Meal Planner'),
        _buildNavigationItem(NavigationItem.chat, Icons.chat, 'Chat'),
        _buildNavigationItem(
            NavigationItem.community, Icons.people, 'Community'),
        _buildNavigationItem(
            NavigationItem.friendRequest, Icons.group_add, 'Friend Requests'),
        _buildNavigationItem(
            NavigationItem.notifications, Icons.notifications, 'Notifications'),
        _buildNavigationItem(
            NavigationItem.bmi, Icons.calculate, 'BMI Calculator'),
        const Divider(),
        ListTile(
          leading: Icon(Icons.exit_to_app, color: Colors.red[400]),
          title: Text('Logout', style: TextStyle(color: Colors.red[400])),
          onTap: _logout,
        ),
      ],
    );
  }

  Widget _buildNavigationItem(
      NavigationItem item, IconData icon, String title) {
    final isSelected = _selectedItem == item;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.blue : Colors.grey),
      title: Text(
        title,
        style: TextStyle(color: isSelected ? Colors.blue : Colors.black),
      ),
      onTap: () {
        setState(() {
          _selectedItem = item;
        });
      },
    );
  }

  Widget _buildContent() {
    switch (_selectedItem) {
      case NavigationItem.library:
        return _buildPlaceholderContent('Library Content');
      case NavigationItem.workouts:
        return const Workout();
      case NavigationItem.settings:
        return widget.userId != null
            ? Settings(userId: widget.userId!, apiService: widget.apiService)
            : _buildLoadingContent();
      case NavigationItem.mealPlanner:
        return const MealPlanner();
      case NavigationItem.chat:
        return widget.userId != null
            ? ChatScreen(userId: widget.userId!, receiverId: 2)
            : _buildLoadingContent();
      case NavigationItem.community:
        return const CommunityFeed();
      case NavigationItem.friendRequest:
        return _buildPlaceholderContent('Friend Requests');
      case NavigationItem.notifications:
        return const Notifications();
      case NavigationItem.bmi:
        return _buildPlaceholderContent('BMI Calculator');
      default:
        return _buildPlaceholderContent('Select a menu item');
    }
  }

  Widget _buildPlaceholderContent(String content) {
    return Center(child: Text(content, style: const TextStyle(fontSize: 24)));
  }

  Widget _buildLoadingContent() {
    return const Center(child: CircularProgressIndicator());
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text(_selectedItem.toString().split('.').last)),
      body: Row(
        children: [
          Expanded(flex: 1, child: _buildNavigation()),
          Expanded(flex: 3, child: _buildContent()),
        ],
      ),
    );
  }
}
