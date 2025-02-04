import 'package:flutter/material.dart';
import 'package:fyp/features/workout/presentation/mealplanner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fyp/utils/api.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class DailyWorkoutsPage extends StatefulWidget {
  final String username; // Accepting username as a parameter

  const DailyWorkoutsPage({super.key, required this.username});

  @override
  State<DailyWorkoutsPage> createState() => _DailyWorkoutsPageState();
}

class _DailyWorkoutsPageState extends State<DailyWorkoutsPage> {
  int currentIndex = 0;
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

  @override
  void initState() {
    super.initState();
    fetchWorkouts(categories.first['searchTerm']);
  }

  Future<void> fetchWorkouts(String searchTerm) async {
    setState(() => isLoading = true);
    try {
      final workouts = await apiService.fetchWorkouts(searchTerm);
      setState(() => recommendedVideos = workouts);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch workouts: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void onCategorySelected(String category, String searchTerm) {
    setState(() => selectedCategory = category);
    fetchWorkouts(searchTerm);
  }

  void onTabTapped(int index) {
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MealPlanner()),
      );
    } else {
      setState(() => currentIndex = index);
    }
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
          const Center(child: Text('Navigating to Meal Planner...')),
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
          _buildCategoryGrid(),
          const SizedBox(height: 24),
          _buildWorkoutRecommendations(),
        ],
      ),
    );
  }

  Widget _buildUserHeader() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage(
              'https://cdn.pixabay.com/photo/2014/12/16/22/25/woman-570883_640.jpg'),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good Morning, ${widget.username}!', // Use dynamic username
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
    );
  }

  Widget _buildCategoryGrid() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: categories
          .map((category) => CategoryCard(
                icon: category['icon'],
                name: category['name'],
                isSelected: selectedCategory == category['name'],
                onTap: () => onCategorySelected(
                    category['name'], category['searchTerm']),
              ))
          .toList(),
    );
  }

  Widget _buildWorkoutRecommendations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommended $selectedCategory Workouts',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else if (recommendedVideos.isEmpty)
          const Center(child: Text('No workouts found'))
        else
          ...recommendedVideos.map((video) => _WorkoutCard(video)).toList(),
      ],
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

class CategoryCard extends StatelessWidget {
  final String icon;
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.icon,
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF7367F0) : Colors.grey[100],
              borderRadius: BorderRadius.circular(12)),
          child: Text(icon, style: const TextStyle(fontSize: 24)),
        ),
        const SizedBox(height: 8),
        Text(name,
            style: TextStyle(
                color: isSelected ? const Color(0xFF7367F0) : Colors.grey[600],
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      ]),
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  final Map<String, dynamic> video;

  const _WorkoutCard(this.video);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
            color: Colors.blue[50], borderRadius: BorderRadius.circular(16)),
        child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(video['title'] ?? 'No Title',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(video['channelTitle'] ?? 'Unknown Channel',
                        style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    Row(children: [
                      const Icon(Icons.timer, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(video['duration'] ?? '0 min',
                          style: const TextStyle(color: Colors.grey)),
                      const SizedBox(width: 16),
                      const Icon(Icons.local_fire_department,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('${video['calories'] ?? "0"} kcal',
                          style: const TextStyle(color: Colors.grey)),
                    ]),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                        onPressed: (() {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => WorkoutVideoPlayer(
                                      videoId: (video['id'] ?? ''),
                                      title: (video['title'] ?? 'No Title'))));
                        }),
                        icon: (const Icon(Icons.play_arrow)),
                        label: (const Text('Play')),
                        style: (ElevatedButton.styleFrom(
                            backgroundColor: (Colors.white),
                            foregroundColor: (Colors.black),
                            shape: (RoundedRectangleBorder(
                                borderRadius: (BorderRadius.circular(8))))))),
                  ])),
              ClipRRect(
                  borderRadius: (BorderRadius.circular(8)),
                  child: (Image.network(video['thumbnail'] ?? '',
                      height: (120),
                      width: (120),
                      fit: (BoxFit.cover),
                      loadingBuilder: (context, child, progress) {
                        return progress == null
                            ? child
                            : Container(
                                height: (120),
                                width: (120),
                                alignment: (Alignment.center),
                                child: (const CircularProgressIndicator()));
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                          height: (120),
                          width: (120),
                          color: (Colors.grey[200]),
                          child: (const Icon(Icons.error))))))
            ])));
  }
}

class WorkoutVideoPlayer extends StatelessWidget {
  final String videoId;
  final String title;

  const WorkoutVideoPlayer({
    super.key,
    required this.videoId,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: YoutubePlayer(
          controller: YoutubePlayerController(
            initialVideoId:
                videoId.isNotEmpty ? videoId : '', // Ensure valid video ID
            flags: const YoutubePlayerFlags(
              autoPlay: false,
              disableDragSeek: true,
            ),
          ),
        ),
      ),
    );
  }
}
