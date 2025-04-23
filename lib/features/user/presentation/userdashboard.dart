import 'package:flutter/material.dart';
import 'package:fyp/features/communityfeed/presentation/bmi.dart';
import 'package:fyp/features/communityfeed/presentation/community.dart';
import 'package:fyp/features/communityfeed/presentation/friendmanagement.dart';
import 'package:fyp/features/communityfeed/firstpage.dart';
import 'package:fyp/features/communityfeed/secondpage.dart';
import 'package:fyp/features/communityfeed/presentation/notification.dart';
import 'package:fyp/features/presentation/login/login.dart';
import 'package:fyp/features/presentation/onboarding/onboarding.dart';
import 'package:fyp/features/presentation/password/password.dart';
import 'package:fyp/features/presentation/signup/signup.dart';
import 'package:fyp/features/workout/journaling.dart';
import 'package:fyp/features/workout/presentation/equipment_listing.dart';
import 'package:fyp/features/workout/presentation/mealplanner.dart';
import 'package:fyp/features/workout/presentation/workout.dart';
import 'package:fyp/features/user/presentation/chat.dart';
import 'package:fyp/utils/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fyp/features/workout/presentation/setting.dart';

enum NavigationItem {
  library,
  workouts,
  settings,
  mealPlanner,
  chat,
  equipment,
  community,
  friendRequest,
  notifications,
  bmi,
  initial,
  secondPage,
  login,
  signup,
  reset,
  onboarding,
  journal
}

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
  final VoidCallback onLogout;

  const DashboardScreen({Key? key, required this.onLogout}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  NavigationItem _selectedItem = NavigationItem.library;
  bool _isSidebarExpanded = true;
  bool _isLoading = true;

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
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final loadedUserId = prefs.getInt('user_id');
      final loadedToken = prefs.getString('auth_token');

      setState(() {
        userId = loadedUserId;
        token = loadedToken;
        _isLoading = false;
      });

      print('User ID: $userId, Token: $token');
      if (userId == null || token == null) {
        print("User id or token is null");
      }
    } catch (e) {
      print('Error loading user data: $e');
      _showErrorSnackBar('Failed to load user data.');
      setState(() => _isLoading = false);
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
                  senderId: item['senderId'],
                  receiverId: item['receiverId'],
                  status: item['status'],
                  createdAt: DateTime.parse(item['createdAt']),
                ))
            .toList();
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load friend requests');
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
    if (userId == null) return;
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
        return 'Settings';
      case NavigationItem.mealPlanner:
        return 'Meal Planner';
      case NavigationItem.chat:
        return 'Chat';
      case NavigationItem.equipment:
        return 'Equipment';
      case NavigationItem.community:
        return 'Community';
      case NavigationItem.friendRequest:
        return 'Friend Requests';
      case NavigationItem.notifications:
        return 'Notifications';
      case NavigationItem.bmi:
        return 'BMI Calculator';
      case NavigationItem.initial:
        return 'Initial Screen';
      case NavigationItem.secondPage:
        return 'Second Page';
      case NavigationItem.login:
        return 'Login';
      case NavigationItem.signup:
        return 'Signup';
      case NavigationItem.reset:
        return 'Reset Password';
      case NavigationItem.onboarding:
        return 'Onboarding';
      case NavigationItem.journal:
        return 'Journal';
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
            _buildNavigationItem(NavigationItem.chat, Icons.chat, 'Chat'),
            _buildNavigationItem(
                NavigationItem.equipment, Icons.fitness_center, 'Equipment'),
            _buildNavigationItem(
                NavigationItem.community, Icons.people, 'Community'),
            _buildNavigationItem(NavigationItem.friendRequest, Icons.group_add,
                'Friend Requests'),
            _buildNavigationItem(NavigationItem.notifications,
                Icons.notifications, 'Notifications'),
            _buildNavigationItem(
                NavigationItem.bmi, Icons.calculate, 'BMI Calculator'),
            _buildNavigationItem(
                NavigationItem.initial, Icons.home, 'Initial Screen'),
            _buildNavigationItem(
                NavigationItem.secondPage, Icons.pages, 'Second Page'),
            _buildNavigationItem(NavigationItem.login, Icons.login, 'Login'),
            _buildNavigationItem(
                NavigationItem.signup, Icons.person_add, 'Signup'),
            _buildNavigationItem(
                NavigationItem.reset, Icons.restore, 'Reset Password'),
            _buildNavigationItem(
                NavigationItem.onboarding, Icons.info, 'Onboarding'),
            _buildNavigationItem(NavigationItem.journal, Icons.book, 'Journal'),
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
        return const Workout();
      case NavigationItem.settings:
        return userId != null
            ? Settings(userId: userId!, apiService: _apiService)
            : const Center(child: Text('Loading Settings...'));
      case NavigationItem.mealPlanner:
        return const MealPlanner();
      case NavigationItem.chat:
        return ChatScreen(userId: userId!, receiverId: 2);
      case NavigationItem.equipment:
        return const DailyWorkoutsPage(username: 'bipana');
      case NavigationItem.community:
        return const CommunityFeed();
      case NavigationItem.friendRequest:
        return FriendRequestsScreen();
      case NavigationItem.notifications:
        return const Notifications();
      case NavigationItem.bmi:
        return const BMICalculator();
      case NavigationItem.initial:
        return const Initial();
      case NavigationItem.secondPage:
        return const Second();
      case NavigationItem.login:
        return const Login();
      case NavigationItem.signup:
        return const SignUp();
      case NavigationItem.reset:
        return const ForgotPasswordPage();
      case NavigationItem.onboarding:
        return const FitnessOnBoard();
      case NavigationItem.journal:
        return const JournalPage();
    }
  }

  Widget _buildPlaceholderContent(String content) {
    return Center(
      child: Text(content,
          style: TextStyle(
              fontSize: 24,
              color: Theme.of(context).textTheme.bodyLarge!.color)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > _tabletBreakpoint;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (userId == null || token == null) {
      return const Scaffold(
        body: Center(child: Text('User not authenticated.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(_getPageTitle())),
      body: Row(
        children: [
          if (isDesktop || _isSidebarExpanded) _buildNavigation(isDesktop),
          Expanded(child: _buildContent(isDesktop)),
        ],
      ),
    );
  }
}
