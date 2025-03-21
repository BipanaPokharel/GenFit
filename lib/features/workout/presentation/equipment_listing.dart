import 'package:flutter/material.dart';
import 'package:fyp/features/workout/presentation/mealplanner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fyp/utils/api_service.dart';
import 'package:fyp/features/user/presentation/userdashboard.dart'; // Import DashboardScreen

class DailyWorkoutsPage extends StatefulWidget {
  final String username;

  const DailyWorkoutsPage({Key? key, required this.username}) : super(key: key);

  @override
  State<DailyWorkoutsPage> createState() => _DailyWorkoutsPageState();
}

class _DailyWorkoutsPageState extends State<DailyWorkoutsPage> {
  int currentIndex = 0; // Tracks the selected tab index
  String selectedCategory = 'Yoga';
  List<Map<String, dynamic>> recommendedVideos = [];
  bool isLoading = false;
  final ApiService apiService = ApiService('https://wger.de/api/v2/exercise/');

  final List<Map<String, dynamic>> categories = [
    {'icon': '🧘', 'name': 'Yoga', 'searchTerm': 'yoga'},
    {'icon': '🏃', 'name': 'Treadmill', 'searchTerm': 'treadmill'},
    {'icon': '🚲', 'name': 'Cycling', 'searchTerm': 'cycling'},
    {'icon': '🏃‍♂️', 'name': 'Running', 'searchTerm': 'running'},
  ];

  void onTabTapped(int index) {
    setState(() {
      currentIndex = index; // Updates the selected tab index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Daily Workouts',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: IndexedStack(
        index: currentIndex,
        children: [
          buildHomeScreen(),
          buildFavoritesScreen(),
          const MealPlanner(), // Navigates to Meal Planner
          buildSettingsScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget buildHomeScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserHeader(),
          const SizedBox(height: 24),
          Text(
            'Categories',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          // Add category grid or other content here
        ],
      ),
    );
  }

  Widget _buildUserHeader() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardScreen(onLogout: () {}),
          ),
        );
      },
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(
                'https://via.placeholder.com/150'), // Placeholder image
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome Back, ${widget.username}!',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                'We wish you have a good day',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: currentIndex, // Tracks the selected tab index
      onTap: onTabTapped, // Calls the defined onTabTapped function
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.purple,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
        BottomNavigationBarItem(icon: Icon(Icons.food_bank), label: 'Meal'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    );
  }

  Widget buildFavoritesScreen() =>
      const Center(child: Text('Favorites Screen'));

  Widget buildSettingsScreen() => const Center(child: Text('Settings Screen'));
}
