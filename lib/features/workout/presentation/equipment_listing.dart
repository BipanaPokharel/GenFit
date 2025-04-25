import 'package:flutter/material.dart';
import 'package:fyp/features/workout/presentation/mealplanner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fyp/utils/api_service.dart';
import 'package:fyp/features/workout/presentation/setting.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fyp/features/presentation/login/login.dart';
import 'package:fyp/features/user/presentation/userdashboard.dart';

class DailyWorkoutsPage extends StatefulWidget {
  final String username;
  const DailyWorkoutsPage({Key? key, required this.username}) : super(key: key);
  @override
  State<DailyWorkoutsPage> createState() => _DailyWorkoutsPageState();
}

class _DailyWorkoutsPageState extends State<DailyWorkoutsPage> {
  int currentIndex = 0;
  String selectedCategory = 'Yoga';
  List<Map<String, dynamic>> recommendedVideos = [];
  bool isLoading = false;
  final ApiService apiService = ApiService('https://wger.de/api/v2/exercise/');
  final ApiService userApiService = ApiService('http://localhost:3000/api');
  final List<Map<String, dynamic>> categories = [
    {'icon': '🧘', 'name': 'Yoga', 'searchTerm': 'yoga'},
    {'icon': '🏃', 'name': 'Treadmill', 'searchTerm': 'treadmill'},
    {'icon': '🚲', 'name': 'Cycling', 'searchTerm': 'cycling'},
    {'icon': '🏃‍♂️', 'name': 'Running', 'searchTerm': 'running'}
  ];
  void onTabTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
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
          title: Text('Daily Workouts',
              style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w600)),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.black),
              onPressed: () {},
            )
          ],
        ),
        body: IndexedStack(
          index: currentIndex,
          children: [
            buildHomeScreen(),
            buildFavoritesScreen(),
            const MealPlanner(),
            buildSettingsScreen()
          ],
        ),
        bottomNavigationBar: _buildBottomNavBar());
  }

  Widget buildHomeScreen() {
    return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildUserHeader(),
          const SizedBox(height: 24),
          Text('Categories',
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          _buildCategories(),
          const SizedBox(height: 24),
          _buildRecommendedSection()
        ]));
  }

  Widget _buildUserHeader() {
    return GestureDetector(
        onTap: () async {
          final userId = await _getUserId();
          if (userId != null && mounted) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DashboardScreen(
                          userId: userId,
                          apiService: userApiService,
                        )));
          } else {
            // Navigate to Login screen if userId is null
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Login()),
            );
          }
        },
        child: Row(children: [
          const CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(
                'https://www.shutterstock.com/image-vector/cute-man-lifting-barbell-gym-260nw-2209370613.jpg'),
          ),
          const SizedBox(width: 16),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Welcome Back, ${widget.username}!',
                style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            Text('We wish you have a good day',
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey))
          ]),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          )
        ]));
  }

  Widget _buildCategories() {
    return SizedBox(
        height: 100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = selectedCategory == category['name'];
            return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedCategory = category['name'];
                  });
                },
                child: Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.purple.shade100
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16)),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(category['icon'],
                              style: const TextStyle(fontSize: 24)),
                          const SizedBox(height: 8),
                          Text(
                            category['name'],
                            style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal),
                          )
                        ])));
          },
        ));
  }

  Widget _buildRecommendedSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Recommended for You',
            style:
                GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
        TextButton(
          onPressed: () {},
          child: Text('See All',
              style: GoogleFonts.poppins(
                  color: Colors.purple, fontWeight: FontWeight.w500)),
        )
      ]),
      const SizedBox(height: 16),
      isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildWorkoutCards()
    ]);
  }

  Widget _buildWorkoutCards() {
    final workouts = [
      {
        'title': 'Morning Yoga',
        'duration': '15 min',
        'image': 'https://via.placeholder.com/150'
      },
      {
        'title': 'HIIT Session',
        'duration': '20 min',
        'image': 'https://via.placeholder.com/150'
      },
      {
        'title': 'Core Workout',
        'duration': '10 min',
        'image': 'https://via.placeholder.com/150'
      }
    ];
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: workouts.length,
      itemBuilder: (context, index) {
        final workout = workouts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                workout['image']!,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(
              workout['title']!,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              'Duration: ${workout['duration']}',
              style: GoogleFonts.poppins(),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.play_circle_fill, color: Colors.purple),
              onPressed: () {},
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTabTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.food_bank), label: 'Meal'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings')
        ]);
  }

  Widget buildFavoritesScreen() =>
      const Center(child: Text('Favorites Screen'));
  Widget buildSettingsScreen() => const Center(child: Text('Settings Screen'));
}
