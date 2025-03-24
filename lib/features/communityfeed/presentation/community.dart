import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:fyp/utils/api_service.dart';

class CommunityFeed extends StatefulWidget {
  const CommunityFeed({Key? key}) : super(key: key);

  @override
  _CommunityFeedState createState() => _CommunityFeedState();
}

class _CommunityFeedState extends State<CommunityFeed> {
  List<Map<String, dynamic>> posts = [];
  bool isLoading = true;
  String errorMessage = '';
  bool _mounted = true;

  // Update this with your actual server IP if running on a physical device
  // Instead of localhost, use your computer's IP address
  final ApiService apiService = ApiService(
      "http://10.0.2.2:3000/api"); // Use 10.0.2.2 for Android emulator to access host

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> fetchPosts() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // Add debugging
      print('Attempting to fetch posts');

      final fetchedPosts = await apiService.getPosts();

      // Check if widget is still mounted before continuing
      if (!mounted) return;

      // Add debugging
      print('Fetched ${fetchedPosts.length} posts');

      if (fetchedPosts.isEmpty) {
        if (_mounted) {
          setState(() {
            posts = [];
            isLoading = false;
          });
        }
        return;
      }

      // Print structure of first post to debug
      print('First post structure: ${fetchedPosts.first}');

      // Fetch usernames separately if needed
      List<Map<String, dynamic>> postsWithUsernames = [];
      for (var post in fetchedPosts) {
        // Check if widget is still mounted before each API call
        if (!mounted) return;

        try {
          // Convert post to Map if it's not already
          final postMap = post is Map<String, dynamic>
              ? post
              : Map<String, dynamic>.from(post as Map);

          // Make sure user_id exists and is an integer
          final userId = postMap['user_id'] is int
              ? postMap['user_id']
              : int.tryParse(postMap['user_id'].toString()) ?? 0;

          if (userId <= 0) {
            // Skip posts without valid user IDs
            continue;
          }

          final user = await apiService.getCurrentUser(userId);

          // Check if widget is still mounted after API call
          if (!mounted) return;

          final username = user['username'] ?? 'Unknown User';

          postsWithUsernames.add({
            'post_id': postMap['post_id'],
            'username': username,
            'content': postMap['content'] ?? '',
            'title': postMap['title'] ?? 'No Title',
            'created_at': postMap['created_at'] ?? '',
            'image': postMap['image'] ?? 'https://via.placeholder.com/150',
          });
        } catch (e) {
          print('Error processing post: $e');
          // Continue to next post
        }
      }

      // Final check before setState
      if (!mounted) return;

      if (_mounted) {
        setState(() {
          posts = postsWithUsernames;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Exception in fetchPosts: $e');

      // Check if widget is still mounted before setState
      if (!mounted) return;

      if (_mounted) {
        setState(() {
          errorMessage = 'Failed to fetch posts: $e';
          isLoading = false;
        });
      }
    }
  }

  String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return 'Date not available';
    }
    try {
      DateTime dateTime = DateTime.parse(dateString);
      return DateFormat('MMM d, yyyy, h:mm a').format(dateTime);
    } catch (e) {
      print('Error parsing date: $e');
      return 'Invalid date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Feed'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchPosts,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $errorMessage'),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: fetchPosts,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : posts.isEmpty
                  ? Center(
                      child: Text('No posts available'),
                    )
                  : RefreshIndicator(
                      onRefresh: fetchPosts,
                      child: ListView.builder(
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          return Card(
                            margin: const EdgeInsets.all(8),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: NetworkImage(post[
                                                'image'] ??
                                            'https://via.placeholder.com/150'),
                                        onBackgroundImageError:
                                            (exception, stackTrace) {
                                          // Handle image load error
                                          print(
                                              'Error loading image: $exception');
                                        },
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        post['username'], // Display username
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    post['title'],
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(post['content']),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Posted on ${formatDate(post['created_at'])}',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
