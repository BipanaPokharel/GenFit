import 'package:flutter/material.dart';
import 'package:fyp/features/workout/presentation/mealplanner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DailyWorkoutsPage extends StatefulWidget {
  const DailyWorkoutsPage({super.key});

  @override
  _DailyWorkoutsPageState createState() => _DailyWorkoutsPageState();
}

class _DailyWorkoutsPageState extends State<DailyWorkoutsPage> {
  int currentIndex = 0;
  String selectedCategory = 'Yoga';
  List<Map<String, dynamic>> recommendedVideos = [];
  final String API_KEY = 'YOUR_YOUTUBE_API_KEY';

  final List<Map<String, dynamic>> categories = [
    {'icon': '🧘', 'name': 'Yoga', 'searchTerm': 'yoga workout'},
    {'icon': '🏃', 'name': 'Treadmill', 'searchTerm': 'treadmill workout'},
    {'icon': '🚲', 'name': 'Cycling', 'searchTerm': 'indoor cycling workout'},
    {'icon': '🏃‍♂️', 'name': 'Running', 'searchTerm': 'running workout guide'},
  ];

  @override
  void initState() {
    super.initState();
    fetchYoutubeVideos('yoga workout');
  }

  Future<void> fetchYoutubeVideos(String searchQuery) async {
    try {
      final response = await http.get(Uri.parse(
          'https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=5'
          '&q=$searchQuery&type=video&key=$API_KEY'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          recommendedVideos = (data['items'] as List)
              .map((video) => {
                    'id': video['id']['videoId'],
                    'title': video['snippet']['title'],
                    'thumbnail': video['snippet']['thumbnails']['high']['url'],
                    'channelTitle': video['snippet']['channelTitle'],
                    'duration': '15 min',
                    'calories': '346 kcal',
                  })
              .toList();
        });
      }
    } catch (e) {
      print('Error fetching YouTube videos: $e');
    }
  }

  void onCategorySelected(String category, String searchTerm) {
    setState(() {
      selectedCategory = category;
    });
    fetchYoutubeVideos(searchTerm);
  }

  void onTabTapped(int index) {
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MealPlanner()),
      );
    } else {
      setState(() {
        currentIndex = index;
      });
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTabTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.food_bank),
            label: 'Meal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget buildHomeScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                    'Good Morning, Bipana!',
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
          const SizedBox(height: 24),
          Text(
            'Categories',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: categories
                .map((category) => GestureDetector(
                      onTap: () => onCategorySelected(
                          category['name'], category['searchTerm']),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: selectedCategory == category['name']
                                  ? const Color(0xFF7367F0)
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              category['icon'],
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            category['name'],
                            style: TextStyle(
                              color: selectedCategory == category['name']
                                  ? const Color(0xFF7367F0)
                                  : Colors.grey[600],
                              fontSize: 12,
                              fontWeight: selectedCategory == category['name']
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 24),
          Text(
            'Recommended $selectedCategory Workouts',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          if (recommendedVideos.isEmpty)
            const Center(child: CircularProgressIndicator())
          else
            Column(
              children: recommendedVideos
                  .map((video) => Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      video['title'],
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      video['channelTitle'],
                                      style:
                                          const TextStyle(color: Colors.grey),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.timer,
                                            size: 16, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(
                                          video['duration'],
                                          style: const TextStyle(
                                              color: Colors.grey),
                                        ),
                                        const SizedBox(width: 16),
                                        const Icon(Icons.local_fire_department,
                                            size: 16, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(
                                          video['calories'],
                                          style: const TextStyle(
                                              color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                WorkoutVideoPlayer(
                                              videoId: video['id'],
                                              title: video['title'],
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.play_arrow),
                                      label: const Text('Play'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.black,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  video['thumbnail'],
                                  height: 120,
                                  width: 120,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget buildFavoritesScreen() {
    return const Center(child: Text('Favorites Screen'));
  }

  Widget buildMealScreen() {
    return const Center(child: Text('Meal Screen'));
  }

  Widget buildSettingsScreen() {
    return const Center(child: Text('Settings Screen'));
  }
}

class WorkoutVideoPlayer extends StatelessWidget {
  final String videoId;
  final String title;

  const WorkoutVideoPlayer(
      {super.key, required this.videoId, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: YoutubePlayer(
          controller: YoutubePlayerController(
            initialVideoId: videoId,
            flags: const YoutubePlayerFlags(autoPlay: false),
          ),
        ),
      ),
    );
  }
}
